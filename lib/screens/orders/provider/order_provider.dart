import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/order_model.dart';

class OrderProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _ordersSubscription;

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

  OrderProvider() {
    // Check availability status on initialization
    _checkAvailabilityStatus();
  }

  // Check the current availability status of the service provider
  Future<void> _checkAvailabilityStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final docSnapshot =
          await _firestore.collection('users').doc(user.uid).get();
      if (!docSnapshot.exists) return;

      final data = docSnapshot.data()!;
      _isAvailable = data['serviceProviderDetails']?['isAvailable'] ?? false;
      notifyListeners();
    } catch (e) {
      print('Error checking availability status: $e');
    }
  }

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
        _setLoading(false); // Make sure to set loading to false
        return false;
      }

      // Get customer details
      final customerDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (!customerDoc.exists) {
        _setError('Customer profile not found');
        _setLoading(false);
        return false;
      }

      final customerData = customerDoc.data()!;

      // Check if service provider is available
      final serviceProviderDoc =
          await _firestore.collection('users').doc(serviceProviderId).get();
      if (!serviceProviderDoc.exists) {
        _setError('Service provider not found');
        _setLoading(false);
        return false;
      }

      final serviceProviderData = serviceProviderDoc.data()!;
      final isAvailable = serviceProviderData['serviceProviderDetails']
              ?['isAvailable'] ??
          false;

      if (!isAvailable) {
        _setError('Service provider is not available at the moment');
        _setLoading(false);
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

      print('Creating new order for service provider: $serviceProviderId');
      print('Order details: ${newOrder.toMap()}');

      // Add to Firestore
      final docRef =
          await _firestore.collection('orders').add(newOrder.toMap());
      print('Order created with ID: ${docRef.id}');

      // Update local orders list to include the new order
      final createdOrder = OrderModel(
        id: docRef.id,
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

      // If this is the customer creating the order, update their orders list
      if (user.uid != serviceProviderId) {
        _setupCustomerOrdersListener(user.uid);
      }

      // Clear any previous errors
      _errorMessage = null;
      _setLoading(false);
      return true;
    } catch (e) {
      print('Error creating order: $e'); // Add debug print
      _setError('Failed to create order: $e');
      _setLoading(false); // Make sure to set loading to false
      return false;
    }
  }

  // Fetch orders for customer with real-time updates
  Future<void> fetchCustomerOrders() async {
    try {
      _setLoading(true);

      final user = _auth.currentUser;
      if (user == null) {
        _setError('User not authenticated');
        _setLoading(false);
        return;
      }

      // First get the current orders
      final querySnapshot = await _firestore
          .collection('orders')
          .where('customerId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      final orders = querySnapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();

      _newOrders = orders
          .where((order) => order.status == OrderStatus.new_order)
          .toList();
      _ongoingOrders =
          orders.where((order) => order.status == OrderStatus.ongoing).toList();
      _completedOrders = orders
          .where((order) => order.status == OrderStatus.completed)
          .toList();

      // Set up real-time listener for customer orders
      _setupCustomerOrdersListener(user.uid);

      _setLoading(false);
    } catch (e) {
      _setError('Failed to fetch orders: $e');
      _setLoading(false);
    }
  }

  // Fetch orders for service provider with real-time updates
  Future<void> fetchServiceProviderOrders() async {
    try {
      _setLoading(true);

      final user = _auth.currentUser;
      if (user == null) {
        _setError('User not authenticated');
        _setLoading(false);
        return;
      }

      print('Fetching orders for service provider: ${user.uid}');

      // First get the current orders
      final querySnapshot = await _firestore
          .collection('orders')
          .where('serviceProviderId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      print('Found ${querySnapshot.docs.length} orders for service provider');

      final orders = querySnapshot.docs.map((doc) {
        final order = OrderModel.fromFirestore(doc);
        print(
            'Order ID: ${order.id}, Status: ${order.status}, Customer: ${order.customerName}');
        return order;
      }).toList();

      _newOrders = orders
          .where((order) => order.status == OrderStatus.new_order)
          .toList();
      _ongoingOrders =
          orders.where((order) => order.status == OrderStatus.ongoing).toList();
      _completedOrders = orders
          .where((order) => order.status == OrderStatus.completed)
          .toList();

      print(
          'New orders: ${_newOrders.length}, Ongoing: ${_ongoingOrders.length}, Completed: ${_completedOrders.length}');

      // Set up real-time listener for new orders
      _setupOrdersListener(user.uid);

      _setLoading(false);
      notifyListeners(); // Make sure to notify listeners to update UI
    } catch (e) {
      print('Error fetching service provider orders: $e');
      _setError('Failed to fetch orders: $e');
      _setLoading(false);
    }
  }

  // Set up real-time listener for orders

  void _setupOrdersListener(String serviceProviderId) {
    // Cancel any existing subscription
    _ordersSubscription?.cancel();

    print(
        'Setting up real-time listener for service provider: $serviceProviderId');

    // Set up a new subscription
    _ordersSubscription = _firestore
        .collection('orders')
        .where('serviceProviderId', isEqualTo: serviceProviderId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      print('Real-time update received: ${snapshot.docs.length} orders');

      // Process the changes
      final orders = snapshot.docs.map((doc) {
        final order = OrderModel.fromFirestore(doc);
        print(
            'Updated order: ${order.id}, Status: ${order.status}, Customer: ${order.customerName}');
        return order;
      }).toList();

      _newOrders = orders
          .where((order) => order.status == OrderStatus.new_order)
          .toList();
      _ongoingOrders =
          orders.where((order) => order.status == OrderStatus.ongoing).toList();
      _completedOrders = orders
          .where((order) => order.status == OrderStatus.completed)
          .toList();

      print(
          'Updated - New: ${_newOrders.length}, Ongoing: ${_ongoingOrders.length}, Completed: ${_completedOrders.length}');

      // Notify listeners to update the UI
      notifyListeners();
    }, onError: (e) {
      print('Error in real-time orders listener: $e');
      _setError('Error in real-time orders update: $e');
    });
  }

  // Set up real-time listener for customer orders
  void _setupCustomerOrdersListener(String customerId) {
    // Cancel any existing subscription
    _ordersSubscription?.cancel();

    // Set up a new subscription
    _ordersSubscription = _firestore
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      // Process the changes
      final orders =
          snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();

      _newOrders = orders
          .where((order) => order.status == OrderStatus.new_order)
          .toList();
      _ongoingOrders =
          orders.where((order) => order.status == OrderStatus.ongoing).toList();
      _completedOrders = orders
          .where((order) => order.status == OrderStatus.completed)
          .toList();

      // Notify listeners to update the UI
      notifyListeners();
    }, onError: (e) {
      _setError('Error in real-time customer orders update: $e');
    });
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
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

      final docSnapshot =
          await _firestore.collection('users').doc(user.uid).get();

      if (!docSnapshot.exists) {
        _setError('User profile not found');
        return false;
      }

      final data = docSnapshot.data()!;
      final currentAvailability =
          data['serviceProviderDetails']?['isAvailable'] ?? false;

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
  Future<bool> checkServiceProviderAvailability(
      String serviceProviderId) async {
    try {
      final docSnapshot =
          await _firestore.collection('users').doc(serviceProviderId).get();

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
    // Only notify listeners if mounted to prevent errors
    if (!loading || _isLoading != loading) {
      _isLoading = loading;

      // Use Future.microtask to avoid calling notifyListeners during build
      Future.microtask(() {
        try {
          notifyListeners();
        } catch (e) {
          print('Error in notifyListeners: $e');
        }
      });
    }
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
