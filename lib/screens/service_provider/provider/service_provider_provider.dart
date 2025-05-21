import 'dart:async';
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

  // Stream subscription for real-time availability updates
  StreamSubscription<DocumentSnapshot>? _availabilitySubscription;

  Future<void> _loadAvailabilityStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Cancel any existing subscription
      await _availabilitySubscription?.cancel();
      
      // Set up a real-time listener for availability changes
      _availabilitySubscription = _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((docSnapshot) {
        if (!docSnapshot.exists) return;
        
        final data = docSnapshot.data()!;
        if (data['role'] == 'serviceProvider' &&
            data.containsKey('serviceProviderDetails')) {
          _isAvailable = data['serviceProviderDetails']['isAvailable'] ?? true;
          print('Availability status updated in real-time: $_isAvailable');
          notifyListeners();
        }
      }, onError: (e) {
        print('Error in availability listener: $e');
      });
    } catch (e) {
      print('Error setting up availability status listener: $e');
    }
  }

  // Method to toggle service provider availability
  Future<bool> toggleAvailability() async {
    // Store the original value in case we need to revert
    final originalValue = _isAvailable;
    
    try {
      // Toggle availability immediately for UI update without showing loading indicator
      _isAvailable = !_isAvailable;
      notifyListeners(); // Update UI immediately
      
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Revert if no user found
        _isAvailable = originalValue;
        notifyListeners();
        _setError('User not authenticated');
        return false;
      }
      
      // Update in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'serviceProviderDetails.isAvailable': _isAvailable,
      });
      
      // Force update all service providers to ensure real-time updates
      await _updateServiceProviderInAllLists(user.uid);

      print('Availability toggled to: $_isAvailable');
      return true;
    } catch (e) {
      // Revert the availability status if the update fails
      _isAvailable = originalValue;
      notifyListeners();
      
      print('Error toggling availability: $e');
      _setError('Failed to update availability: $e');
      return false;
    }
  }
  
  // Method to update a service provider in all lists when their availability changes
  Future<void> _updateServiceProviderInAllLists(String serviceProviderId) async {
    try {
      // Fetch the updated service provider data
      final docSnapshot = await _firestore.collection('users').doc(serviceProviderId).get();
      
      if (!docSnapshot.exists) return;
      
      final data = docSnapshot.data()!;
      data['id'] = serviceProviderId;
      final updatedProvider = ServiceProviderModel.fromJson(data);
      
      // Update in all lists
      bool updated = false;
      
      // Update in service providers list
      for (int i = 0; i < _serviceProviders.length; i++) {
        if (_serviceProviders[i].id == serviceProviderId) {
          _serviceProviders[i] = updatedProvider;
          updated = true;
        }
      }
      
      // Update in top service providers list
      for (int i = 0; i < _topServiceProviders.length; i++) {
        if (_topServiceProviders[i].id == serviceProviderId) {
          _topServiceProviders[i] = updatedProvider;
          updated = true;
        }
      }
      
      // Update in search results
      for (int i = 0; i < _searchResults.length; i++) {
        if (_searchResults[i].id == serviceProviderId) {
          _searchResults[i] = updatedProvider;
          updated = true;
        }
      }
      
      // Update in favorite service providers
      for (int i = 0; i < _favoriteServiceProviders.length; i++) {
        if (_favoriteServiceProviders[i].id == serviceProviderId) {
          _favoriteServiceProviders[i] = updatedProvider;
          updated = true;
        }
      }
      
      // Update current service provider if it's the same one
      if (_currentServiceProvider?.id == serviceProviderId) {
        _currentServiceProvider = updatedProvider;
        updated = true;
      }
      
      // Notify listeners if any updates were made
      if (updated) {
        print('Service provider $serviceProviderId updated in all lists');
        notifyListeners();
      }
    } catch (e) {
      print('Error updating service provider in lists: $e');
    }
  }

  // Method to refresh all data
  Future<void> refreshData() async {
    try {
      // Refresh all relevant data
      await Future.wait([
        fetchCategories(),
        fetchTopServiceProviders(),
        fetchFavoriteServiceProviders(),
        _loadAvailabilityStatus(),
      ]);

      print('Service provider data refreshed successfully');
    } catch (e) {
      print('Error refreshing data: $e');
      _setError('Failed to refresh data: $e');
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
  // Future<void> refreshData() async {
  //   try {
  //     await fetchCategories();
  //     await fetchTopServiceProviders();
  //     await fetchFavoriteServiceProviders();
  //     await _loadAvailabilityStatus();
  //     notifyListeners();
  //   } catch (e) {
  //     _setError('Failed to refresh data: $e');
  //     rethrow;
  //   }
  // }

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

  // Method to toggle service provider availability
  // Future<bool> toggleAvailability() async {
  //   try {
  //     _setLoading(true);

  //     // Get current user
  //     final user = FirebaseAuth.instance.currentUser;
  //     if (user == null) {
  //       _setError('User not authenticated');
  //       return false;
  //     }

  //     // Toggle availability
  //     _isAvailable = !_isAvailable;

  //     // Update in Firestore - use the correct field path
  //     await _firestore
  //         .collection('users')
  //         .doc(user.uid)
  //         .update({
  //       'serviceProviderDetails.isAvailable': _isAvailable,
  //     });

  //     print('Availability toggled to: $_isAvailable');
  //     notifyListeners();
  //     _setLoading(false);
  //     return true;
  //   } catch (e) {
  //     print('Error toggling availability: $e');
  //     _setError('Failed to update availability: $e');
  //     return false;
  //   }
  // }

  // Map to store availability listeners for different service providers
  final Map<String, StreamSubscription<DocumentSnapshot>> _providerAvailabilityListeners = {};

  // Method to load service provider details with real-time availability updates
  Future<void> loadServiceProviderDetails(String id) async {
    try {
      _setDetailLoading(true);

      // Cancel any existing listener for this provider
      await _providerAvailabilityListeners[id]?.cancel();
      
      // Set up a real-time listener for this service provider
      _providerAvailabilityListeners[id] = _firestore
          .collection('users')
          .doc(id)
          .snapshots()
          .listen((docSnapshot) {
        if (!docSnapshot.exists) {
          _currentServiceProvider = null;
          return;
        }
        
        final data = docSnapshot.data()!;
        data['id'] = docSnapshot.id;
        _currentServiceProvider = ServiceProviderModel.fromJson(data);
        print('Service provider details updated in real-time: ${_currentServiceProvider?.name}');
        notifyListeners();
      }, onError: (e) {
        print('Error in service provider listener: $e');
      });
      
      // Initial load
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
