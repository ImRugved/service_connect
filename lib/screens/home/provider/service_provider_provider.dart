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
  List<ServiceProviderModel> get favoriteServiceProviders => _favoriteServiceProviders;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isDetailLoading => _isDetailLoading;
  bool get isSearching => _isSearching;
  bool get isAvailable => _isAvailable;
  String? get errorMessage => _errorMessage;
  ServiceProviderModel? get currentServiceProvider => _currentServiceProvider;
  bool get currentIsFavorite => _currentIsFavorite;
  
  // Stream subscription for real-time availability updates
  StreamSubscription<QuerySnapshot>? _availabilitySubscription;
  
  ServiceProviderProvider() {
    _init();
    // Set up real-time listener for service provider availability changes
    _setupAvailabilityListener();
  }
  
  @override
  void dispose() {
    _availabilitySubscription?.cancel();
    super.dispose();
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
          .where('userType', isEqualTo: 'service_provider')
          .get();
      
      _serviceProviders = querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            return ServiceProviderModel.fromJson({
              'id': doc.id,
              ...data['serviceProviderDetails'] ?? {},
              'name': data['name'] ?? '',
              'email': data['email'] ?? '',
              'phoneNumber': data['phoneNumber'] ?? '',
              'profileImageUrl': data['profileImageUrl'],
              'address': data['address'],
            });
          })
          .toList();
      
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
          .where('userType', isEqualTo: 'service_provider')
          .orderBy('serviceProviderDetails.rating', descending: true)
          .limit(5)
          .get();
      
      _topServiceProviders = querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            final serviceProviderDetails = data['serviceProviderDetails'] ?? {};
            
            return ServiceProviderModel.fromJson({
              'id': doc.id,
              ...serviceProviderDetails,
              'name': data['name'] ?? '',
              'email': data['email'] ?? '',
              'phoneNumber': data['phoneNumber'] ?? '',
              'profileImageUrl': data['profileImageUrl'],
              'address': data['address'],
            });
          })
          .toList();
      
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
          .where('userType', isEqualTo: 'service_provider')
          .where('serviceProviderDetails.category', isEqualTo: category)
          .get();
      
      _serviceProviders = querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            return ServiceProviderModel.fromJson({
              'id': doc.id,
              ...data['serviceProviderDetails'] ?? {},
              'name': data['name'] ?? '',
              'email': data['email'] ?? '',
              'phoneNumber': data['phoneNumber'] ?? '',
              'profileImageUrl': data['profileImageUrl'],
              'address': data['address'],
            });
          })
          .toList();
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to fetch service providers by category: $e');
    }
  }
  
  Future<void> fetchCategories() async {
    try {
      _setLoading(true);
      
      final querySnapshot = await _firestore
          .collection('categories')
          .get();
      
      _categories = querySnapshot.docs
          .map((doc) => doc['name'] as String)
          .toList();
      
      // If no categories exist, create default ones
      if (_categories.isEmpty) {
        _categories = [
          'Cleaning',
          'Plumbing',
          'Electrical',
          'Carpentry',
          'Painting',
          'Gardening',
          'Moving',
          'Appliance Repair',
          'Beauty & Wellness',
          'Other'
        ];
        
        // Save default categories to Firestore
        for (String category in _categories) {
          await _firestore.collection('categories').add({
            'name': category,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to fetch categories: $e');
    }
  }
  
  Future<void> loadServiceProviderDetails(String id) async {
    try {
      _setDetailLoading(true);
      clearError();
      
      final docSnapshot = await _firestore
          .collection('users')
          .doc(id)
          .get();
      
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
      await checkFavoriteStatus(id);
      
      _setDetailLoading(false);
    } catch (e) {
      _setError('Failed to get service provider: $e');
      _currentServiceProvider = null;
      _setDetailLoading(false);
    }
  }
  
  Future<ServiceProviderModel?> getServiceProviderById(String id) async {
    try {
      // Don't use _setLoading here as it calls notifyListeners() which can cause issues during build
      // Instead, let the UI handle loading state
      
      final docSnapshot = await _firestore
          .collection('users')
          .doc(id)
          .get();
      
      if (!docSnapshot.exists) {
        // Don't call _setError here, return an error message instead
        return null;
      }
      
      final data = docSnapshot.data()!;
      
      if (data['userType'] != 'service_provider') {
        // Don't call _setError here, return an error message instead
        return null;
      }
      
      final serviceProvider = ServiceProviderModel.fromJson({
        'id': docSnapshot.id,
        ...data['serviceProviderDetails'] ?? {},
        'name': data['name'] ?? '',
        'email': data['email'] ?? '',
        'phoneNumber': data['phoneNumber'] ?? '',
        'profileImageUrl': data['profileImageUrl'],
        'address': data['address'],
      });
      
      return serviceProvider;
    } catch (e) {
      // Don't call _setError here, let the UI handle the error
      print('Failed to get service provider: $e');
      return null;
    }
  }
  
  Future<void> searchServiceProviders(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }
    
    try {
      _isSearching = true;
      notifyListeners();
      
      final queryLowerCase = query.toLowerCase();
      
      // Get all service providers
      final querySnapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'service_provider')
          .get();
      
      // Filter locally for more flexible search
      final List<ServiceProviderModel> results = [];
      final Set<String> uniqueIds = {};
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final name = (data['name'] ?? '').toString().toLowerCase();
        final serviceProviderDetails = data['serviceProviderDetails'] ?? {};
        final category = (serviceProviderDetails['category'] ?? '').toString().toLowerCase();
        final services = List<String>.from(serviceProviderDetails['services'] ?? []);
        
        // Check if name contains the query
        final nameMatch = name.contains(queryLowerCase);
        
        // Check if category contains the query
        final categoryMatch = category.contains(queryLowerCase);
        
        // Check if any service contains the query
        final serviceMatch = services.any((service) => 
            service.toLowerCase().contains(queryLowerCase));
        
        // Add to results if any match is found
        if (nameMatch || categoryMatch || serviceMatch) {
          if (!uniqueIds.contains(doc.id)) {
            uniqueIds.add(doc.id);
            
            results.add(ServiceProviderModel.fromJson({
              'id': doc.id,
              ...serviceProviderDetails,
              'name': data['name'] ?? '',
              'email': data['email'] ?? '',
              'phoneNumber': data['phoneNumber'] ?? '',
              'profileImageUrl': data['profileImageUrl'],
              'address': data['address'],
            }));
          }
        }
      }
      
      _searchResults = results;
      _isSearching = false;
      notifyListeners();
    } catch (e) {
      _setError('Failed to search service providers: $e');
      _isSearching = false;
      notifyListeners();
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setDetailLoading(bool loading) {
    _isDetailLoading = loading;
    notifyListeners();
  }
  
  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  Future<void> _loadAvailabilityStatus() async {
    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;
      
      if (user != null) {
        final docSnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (docSnapshot.exists) {
          final data = docSnapshot.data()!;
          final serviceProviderDetails = data['serviceProviderDetails'];
          
          if (serviceProviderDetails != null && 
              serviceProviderDetails['isAvailable'] != null) {
            _isAvailable = serviceProviderDetails['isAvailable'];
            notifyListeners();
          }
        }
      }
    } catch (e) {
      _setError('Failed to load availability status: $e');
    }
  }
  
  Future<bool> toggleAvailability() async {
    try {
      _setLoading(true);
      
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;
      
      if (user == null) {
        _setError('User not authenticated');
        return false;
      }
      
      // Toggle availability
      _isAvailable = !_isAvailable;
      
      // Update in Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({
        'serviceProviderDetails.isAvailable': _isAvailable,
      });
      
      // Update all instances of this service provider in all lists
      _updateServiceProviderAvailabilityInAllLists(user.uid, _isAvailable);
      
      notifyListeners();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update availability: $e');
      return false;
    }
  }
  
  // Helper method to update a service provider's availability in all lists
  void _updateServiceProviderAvailabilityInAllLists(String serviceProviderId, bool isAvailable) {
    // Update in main service providers list
    for (int i = 0; i < _serviceProviders.length; i++) {
      if (_serviceProviders[i].id == serviceProviderId) {
        _serviceProviders[i] = _serviceProviders[i].copyWith(isAvailable: isAvailable);
      }
    }
    
    // Update in top service providers list
    for (int i = 0; i < _topServiceProviders.length; i++) {
      if (_topServiceProviders[i].id == serviceProviderId) {
        _topServiceProviders[i] = _topServiceProviders[i].copyWith(isAvailable: isAvailable);
      }
    }
    
    // Update in search results
    for (int i = 0; i < _searchResults.length; i++) {
      if (_searchResults[i].id == serviceProviderId) {
        _searchResults[i] = _searchResults[i].copyWith(isAvailable: isAvailable);
      }
    }
    
    // Update in favorites
    for (int i = 0; i < _favoriteServiceProviders.length; i++) {
      if (_favoriteServiceProviders[i].id == serviceProviderId) {
        _favoriteServiceProviders[i] = _favoriteServiceProviders[i].copyWith(isAvailable: isAvailable);
      }
    }
    
    // Update current service provider if it's the same one
    if (_currentServiceProvider != null && _currentServiceProvider!.id == serviceProviderId) {
      _currentServiceProvider = _currentServiceProvider!.copyWith(isAvailable: isAvailable);
    }
    
    // Notify listeners to update UI
    notifyListeners();
  }
  
  // Set up real-time listener for service provider availability changes
  void _setupAvailabilityListener() {
    // Cancel any existing subscription
    _availabilitySubscription?.cancel();
    
    // Set up a new subscription to listen for changes to any service provider's availability
    _availabilitySubscription = _firestore
        .collection('users')
        .where('userType', isEqualTo: 'service_provider')
        .snapshots(includeMetadataChanges: true)
        .listen((snapshot) {
      // Process each changed document
      for (var change in snapshot.docChanges) {
        final doc = change.doc;
        final data = doc.data() as Map<String, dynamic>;
        final serviceProviderDetails = data['serviceProviderDetails'] as Map<String, dynamic>?;
        
        if (serviceProviderDetails != null && serviceProviderDetails.containsKey('isAvailable')) {
          final isAvailable = serviceProviderDetails['isAvailable'] as bool;
          // Update this service provider in all lists
          _updateServiceProviderAvailabilityInAllLists(doc.id, isAvailable);
        }
      }
    }, onError: (e) {
      print('Error in real-time availability listener: $e');
    });
  }
  
  // Favorite service providers functionality
  Future<void> fetchFavoriteServiceProviders() async {
    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;
      
      if (user == null) {
        return;
      }
      
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) {
        return;
      }
      
      final userData = userDoc.data();
      final favoriteIds = userData?['favoriteServiceProviders'] as List<dynamic>? ?? [];
      
      if (favoriteIds.isEmpty) {
        _favoriteServiceProviders = [];
        notifyListeners();
        return;
      }
      
      final favoriteProviders = <ServiceProviderModel>[];
      
      for (final id in favoriteIds) {
        final providerDoc = await _firestore.collection('users').doc(id.toString()).get();
        
        if (providerDoc.exists) {
          final data = providerDoc.data()!;
          final serviceProviderDetails = data['serviceProviderDetails'] ?? {};
          
          favoriteProviders.add(ServiceProviderModel.fromJson({
            'id': providerDoc.id,
            ...serviceProviderDetails,
            'name': data['name'] ?? '',
            'email': data['email'] ?? '',
            'phoneNumber': data['phoneNumber'] ?? '',
            'profileImageUrl': data['profileImageUrl'],
            'address': data['address'],
          }));
        }
      }
      
      _favoriteServiceProviders = favoriteProviders;
      notifyListeners();
    } catch (e) {
      print('Error fetching favorite service providers: $e');
    }
  }
  
  Future<bool> toggleFavorite(String serviceProviderId) async {
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
      final favoriteIds = List<String>.from(userData['favoriteServiceProviders'] ?? []);
      
      if (favoriteIds.contains(serviceProviderId)) {
        // Remove from favorites
        favoriteIds.remove(serviceProviderId);
        _currentIsFavorite = false;
      } else {
        // Add to favorites
        favoriteIds.add(serviceProviderId);
        _currentIsFavorite = true;
      }
      
      // Update in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'favoriteServiceProviders': favoriteIds,
      });
      
      // Refresh favorites list
      await fetchFavoriteServiceProviders();
      
      // Notify listeners about the change in favorite status
      notifyListeners();
      
      return true;
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }
  
  Future<void> checkFavoriteStatus(String serviceProviderId) async {
    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;
      
      if (user == null) {
        _currentIsFavorite = false;
        notifyListeners();
        return;
      }
      
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) {
        _currentIsFavorite = false;
        notifyListeners();
        return;
      }
      
      final userData = userDoc.data()!;
      final favoriteIds = List<String>.from(userData['favoriteServiceProviders'] ?? []);
      
      _currentIsFavorite = favoriteIds.contains(serviceProviderId);
      notifyListeners();
    } catch (e) {
      print('Error checking favorite status: $e');
      _currentIsFavorite = false;
      notifyListeners();
    }
  }
  
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
      final favoriteIds = List<String>.from(userData['favoriteServiceProviders'] ?? []);
      
      return favoriteIds.contains(serviceProviderId);
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }
}
