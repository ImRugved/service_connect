import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/order_model.dart';

class OrderProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAvailable = false; // Track service provider availability
  
  // Orders lists by status
  List<OrderModel> _newOrders = [];
  List<OrderModel> _ongoingOrders = [];
  List<OrderModel> _completedOrders = [];
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAvailable => _isAvailable;
  List<OrderModel> get newOrders => _newOrders;
  List<OrderModel> get ongoingOrders => _ongoingOrders;
  List<OrderModel> get completedOrders => _completedOrders;
  
  // Create a new order (booking)
  Future<bool> createOrder({
    required String serviceProviderId,
    required String serviceProviderName,
    required String serviceCategory,
    required List<String> services,
    required String notes,
  }) async {
    try {
      _setLoading(true);
      
      final user = _auth.currentUser;
      if (user == null) {
        _setError('User not authenticated');
        return false;
      }
      
      // Get customer details
      final customerDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!customerDoc.exists) {
        _setError('Customer profile not found');
        return false;
      }
      
      final customerData = customerDoc.data()!;
      
      // Check if service provider is available
      final serviceProviderDoc = await _firestore.collection('users').doc(serviceProviderId).get();
      if (!serviceProviderDoc.exists) {
        _setError('Service provider not found');
        return false;
      }
      
      final serviceProviderData = serviceProviderDoc.data()!;
      final isAvailable = serviceProviderData['serviceProviderDetails']?['isAvailable'] ?? false;
      
      if (!isAvailable) {
        _setError('Service provider is not available at the moment');
        return false;
      }
      
      // Create new order
      final newOrder = OrderModel(
        id: '', // Will be set by Firestore
        customerId: user.uid,
        customerName: customerData['name'] ?? '',
        serviceProviderId: serviceProviderId,
        serviceProviderName: serviceProviderName,
        serviceCategory: serviceCategory,
        services: services,
        address: customerData['address'] ?? '',
        phoneNumber: customerData['phoneNumber'] ?? '',
        notes: notes,
        status: OrderStatus.new_order,
        createdAt: DateTime.now(),
      );
      
      // Add to Firestore
      await _firestore.collection('orders').add(newOrder.toMap());
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to create order: $e');
      return false;
    }
  }
  
  // Fetch orders for customer
  Future<void> fetchCustomerOrders() async {
    try {
      _setLoading(true);
      
      final user = _auth.currentUser;
      if (user == null) {
        _setError('User not authenticated');
        return;
      }
      
      final querySnapshot = await _firestore
          .collection('orders')
          .where('customerId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();
      
      final orders = querySnapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
      
      _newOrders = orders.where((order) => order.status == OrderStatus.new_order).toList();
      _ongoingOrders = orders.where((order) => order.status == OrderStatus.ongoing).toList();
      _completedOrders = orders.where((order) => order.status == OrderStatus.completed).toList();
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to fetch orders: $e');
    }
  }
  
  // Fetch orders for service provider
  Future<void> fetchServiceProviderOrders() async {
    try {
      _setLoading(true);
      
      final user = _auth.currentUser;
      if (user == null) {
        _setError('User not authenticated');
        return;
      }
      
      final querySnapshot = await _firestore
          .collection('orders')
          .where('serviceProviderId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();
      
      final orders = querySnapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
      
      _newOrders = orders.where((order) => order.status == OrderStatus.new_order).toList();
      _ongoingOrders = orders.where((order) => order.status == OrderStatus.ongoing).toList();
      _completedOrders = orders.where((order) => order.status == OrderStatus.completed).toList();
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to fetch orders: $e');
    }
  }
  
  // Start an order (service provider)
  Future<bool> startOrder(String orderId) async {
    try {
      _setLoading(true);
      
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'ongoing',
        'startedAt': Timestamp.now(),
      });
      
      // Refresh orders
      await fetchServiceProviderOrders();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to start order: $e');
      return false;
    }
  }
  
  // Complete an order (service provider)
  Future<bool> completeOrder(String orderId) async {
    try {
      _setLoading(true);
      
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'completed',
        'completedAt': Timestamp.now(),
      });
      
      // Refresh orders
      await fetchServiceProviderOrders();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to complete order: $e');
      return false;
    }
  }
  
  // Toggle service provider availability
  Future<bool> toggleAvailability() async {
    try {
      _setLoading(true);
      
      final user = _auth.currentUser;
      if (user == null) {
        _setError('User not authenticated');
        return false;
      }
      
      final docSnapshot = await _firestore.collection('users').doc(user.uid).get();
      
      if (!docSnapshot.exists) {
        _setError('User profile not found');
        return false;
      }
      
      final data = docSnapshot.data()!;
      final currentAvailability = data['serviceProviderDetails']?['isAvailable'] ?? false;
      
      // Toggle availability
      await _firestore.collection('users').doc(user.uid).update({
        'serviceProviderDetails.isAvailable': !currentAvailability,
      });
      
      // Force a refresh of the top service providers in the ServiceProviderProvider
      // This ensures the availability change is reflected in the customer screen
      try {
        // Create a batch update to refresh the service provider's timestamp
        // This will cause it to be picked up in queries that sort by timestamp
        final batch = _firestore.batch();
        batch.update(_firestore.collection('users').doc(user.uid), {
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        await batch.commit();
      } catch (e) {
        // If this fails, it's not critical, so just log it
        print('Failed to update service provider timestamp: $e');
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to toggle availability: $e');
      return false;
    }
  }
  
  // Check if service provider is available
  Future<bool> checkServiceProviderAvailability(String serviceProviderId) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(serviceProviderId).get();
      
      if (!docSnapshot.exists) {
        return false;
      }
      
      final data = docSnapshot.data()!;
      return data['serviceProviderDetails']?['isAvailable'] ?? false;
    } catch (e) {
      _setError('Failed to check availability: $e');
      return false;
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
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
}
