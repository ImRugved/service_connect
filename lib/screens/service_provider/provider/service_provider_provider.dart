import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/service_provider_model.dart';

class ServiceProviderProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ServiceProviderModel> _serviceProviders = [];
  List<ServiceProviderModel> _topServiceProviders = [];
  List<ServiceProviderModel> _searchResults = [];
  List<ServiceProviderModel> _favoriteServiceProviders = [];
  List<String> _categories = [];
  bool _isLoading = false;
  bool _isDetailLoading = false;
  bool _isSearching = false;
  bool _isAvailable = true; // Default to available
  String? _errorMessage;
  ServiceProviderModel? _currentServiceProvider;
  bool _currentIsFavorite = false;

  // Getters
  List<ServiceProviderModel> get serviceProviders => _serviceProviders;
  List<ServiceProviderModel> get topServiceProviders => _topServiceProviders;
  List<ServiceProviderModel> get searchResults => _searchResults;
  List<ServiceProviderModel> get favoriteServiceProviders =>
      _favoriteServiceProviders;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isDetailLoading => _isDetailLoading;
  bool get isSearching => _isSearching;
  bool get isAvailable => _isAvailable;
  String? get errorMessage => _errorMessage;
  ServiceProviderModel? get currentServiceProvider => _currentServiceProvider;
  bool get currentIsFavorite => _currentIsFavorite;

  ServiceProviderProvider() {
    _init();
  }

  void _init() async {
    await fetchCategories();
    await fetchTopServiceProviders();
    await _loadAvailabilityStatus();
    await fetchFavoriteServiceProviders();
  }

  Future<void> fetchServiceProviders() async {
    try {
      _setLoading(true);

      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'serviceProvider')
          .get();

      _serviceProviders = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ServiceProviderModel.fromJson(data);
      }).toList();

      _setLoading(false);
    } catch (e) {
      _setError('Failed to fetch service providers: $e');
    }
  }

  Future<void> fetchTopServiceProviders() async {
    try {
      _setLoading(true);

      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'serviceProvider')
          .orderBy('rating', descending: true)
          .limit(10)
          .get();

      _topServiceProviders = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ServiceProviderModel.fromJson(data);
      }).toList();

      _setLoading(false);
    } catch (e) {
      _setError('Failed to fetch top service providers: $e');
    }
  }

  Future<void> fetchServiceProvidersByCategory(String category) async {
    try {
      _setLoading(true);

      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'serviceProvider')
          .where('category', isEqualTo: category)
          .get();

      _serviceProviders = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ServiceProviderModel.fromJson(data);
      }).toList();

      _setLoading(false);
    } catch (e) {
      _setError('Failed to fetch service providers by category: $e');
    }
  }

  Future<void> fetchCategories() async {
    try {
      _setLoading(true);

      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'serviceProvider')
          .get();

      final Set<String> uniqueCategories = {};

      for (var doc in querySnapshot.docs) {
        final category = doc.data()['category'] as String?;
        if (category != null && category.isNotEmpty) {
          uniqueCategories.add(category);
        }
      }

      _categories = uniqueCategories.toList();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to fetch categories: $e');
    }
  }

  Future<void> fetchServiceProviderDetail(String id) async {
    try {
      _setDetailLoading(true);

      final docSnapshot = await _firestore.collection('users').doc(id).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        data['id'] = docSnapshot.id;
        _currentServiceProvider = ServiceProviderModel.fromJson(data);

        // Check if this service provider is in favorites
        await _checkIfFavorite(id);
      } else {
        _setError('Service provider not found');
      }

      _setDetailLoading(false);
    } catch (e) {
      _setError('Failed to fetch service provider details: $e');
    }
  }

  Future<void> searchServiceProviders(String query) async {
    try {
      _setSearching(true);

      if (query.isEmpty) {
        _searchResults = [];
        _setSearching(false);
        return;
      }

      // Convert query to lowercase for case-insensitive search
      final lowercaseQuery = query.toLowerCase();

      // Get all service providers
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'serviceProvider')
          .get();

      // Filter locally based on name, category, or services
      _searchResults = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ServiceProviderModel.fromJson(data);
      }).where((provider) {
        final name = provider.name.toLowerCase();
        final category = provider.category.toLowerCase();
        final services =
            provider.services.map((service) => service.toLowerCase()).toList();

        return name.contains(lowercaseQuery) ||
            category.contains(lowercaseQuery) ||
            services.any((service) => service.contains(lowercaseQuery));
      }).toList();

      _setSearching(false);
    } catch (e) {
      _setError('Failed to search service providers: $e');
    }
  }

  Future<void> toggleFavorite(String serviceProviderId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) return;

      List<String> favorites = [];
      if (userDoc.data()!.containsKey('favorites')) {
        favorites = List<String>.from(userDoc.data()!['favorites']);
      }

      if (favorites.contains(serviceProviderId)) {
        // Remove from favorites
        favorites.remove(serviceProviderId);
        _currentIsFavorite = false;
      } else {
        // Add to favorites
        favorites.add(serviceProviderId);
        _currentIsFavorite = true;
      }

      // Update in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'favorites': favorites,
      });

      // Refresh favorites list
      await fetchFavoriteServiceProviders();

      notifyListeners();
    } catch (e) {
      _setError('Failed to toggle favorite: $e');
    }
  }

  Future<void> _checkIfFavorite(String serviceProviderId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _currentIsFavorite = false;
        return;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        _currentIsFavorite = false;
        return;
      }

      List<String> favorites = [];
      if (userDoc.data()!.containsKey('favorites')) {
        favorites = List<String>.from(userDoc.data()!['favorites']);
      }

      _currentIsFavorite = favorites.contains(serviceProviderId);
      notifyListeners();
    } catch (e) {
      _currentIsFavorite = false;
      print('Error checking favorite status: $e');
    }
  }

  Future<void> fetchFavoriteServiceProviders() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _favoriteServiceProviders = [];
        return;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        _favoriteServiceProviders = [];
        return;
      }

      List<String> favorites = [];
      if (userDoc.data()!.containsKey('favorites')) {
        favorites = List<String>.from(userDoc.data()!['favorites']);
      }

      if (favorites.isEmpty) {
        _favoriteServiceProviders = [];
        return;
      }

      // Fetch all favorite service providers
      final List<ServiceProviderModel> providers = [];

      for (String id in favorites) {
        final docSnapshot = await _firestore.collection('users').doc(id).get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data()!;
          data['id'] = docSnapshot.id;
          providers.add(ServiceProviderModel.fromJson(data));
        }
      }

      _favoriteServiceProviders = providers;
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch favorite service providers: $e');
    }
  }

  Future<void> _loadAvailabilityStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final docSnapshot =
          await _firestore.collection('users').doc(user.uid).get();

      if (!docSnapshot.exists) return;

      final data = docSnapshot.data()!;
      if (data['role'] == 'serviceProvider' &&
          data.containsKey('serviceProviderDetails')) {
        _isAvailable = data['serviceProviderDetails']['isAvailable'] ?? true;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading availability status: $e');
    }
  }

  Future<void> toggleAvailability() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Toggle the state locally first for immediate UI update
      _isAvailable = !_isAvailable;
      notifyListeners();

      // Update in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'serviceProviderDetails.isAvailable': _isAvailable,
      });
    } catch (e) {
      // Revert if failed
      _isAvailable = !_isAvailable;
      notifyListeners();
      _setError('Failed to update availability: $e');
    }
  }

  void clearSearch() {
    _searchResults = [];
    _isSearching = false;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setDetailLoading(bool loading) {
    _isDetailLoading = loading;
    notifyListeners();
  }

  void _setSearching(bool searching) {
    _isSearching = searching;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    _isDetailLoading = false;
    _isSearching = false;
    notifyListeners();

    // Clear error after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _errorMessage = null;
      notifyListeners();
    });
  }

  /// Refreshes all data for the service provider
  Future<void> refreshData() async {
    try {
      await fetchCategories();
      await fetchTopServiceProviders();
      await fetchFavoriteServiceProviders();
      await _loadAvailabilityStatus();
      notifyListeners();
    } catch (e) {
      _setError('Failed to refresh data: $e');
      rethrow;
    }
  }

  // Method to check if a service provider is in favorites
  Future<bool> isFavorite(String serviceProviderId) async {
    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;

      if (user == null) {
        return false;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        return false;
      }

      final userData = userDoc.data()!;
      final favoriteIds =
          List<String>.from(userData['favoriteServiceProviders'] ?? []);

      return favoriteIds.contains(serviceProviderId);
    } catch (e) {
      print('Error checking if favorite: $e');
      return false;
    }
  }

  // Method to load service provider details
  Future<void> loadServiceProviderDetails(String id) async {
    try {
      _setDetailLoading(true);

      final docSnapshot = await _firestore.collection('users').doc(id).get();

      if (!docSnapshot.exists) {
        _currentServiceProvider = null;
        _setDetailLoading(false);
        return;
      }

      final data = docSnapshot.data()!;

      if (data['userType'] != 'service_provider') {
        _currentServiceProvider = null;
        _setDetailLoading(false);
        return;
      }

      _currentServiceProvider = ServiceProviderModel.fromJson({
        'id': docSnapshot.id,
        ...data['serviceProviderDetails'] ?? {},
        'name': data['name'] ?? '',
        'email': data['email'] ?? '',
        'phoneNumber': data['phoneNumber'] ?? '',
        'profileImageUrl': data['profileImageUrl'],
        'address': data['address'],
      });

      // Check if this service provider is in favorites
      await _checkIfFavorite(id);

      _setDetailLoading(false);
    } catch (e) {
      _setError('Failed to get service provider: $e');
      _currentServiceProvider = null;
      _setDetailLoading(false);
    }
  }
}
