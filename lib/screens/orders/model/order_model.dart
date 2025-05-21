import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  new_order,
  ongoing,
  completed,
  cancelled,
}

class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String serviceProviderId;
  final String serviceProviderName;
  final String serviceCategory;
  final List<String> services;
  final String address;
  final String phoneNumber;
  final String notes;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.serviceProviderId,
    required this.serviceProviderName,
    required this.serviceCategory,
    required this.services,
    required this.address,
    required this.phoneNumber,
    required this.notes,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      serviceProviderId: data['serviceProviderId'] ?? '',
      serviceProviderName: data['serviceProviderName'] ?? '',
      serviceCategory: data['serviceCategory'] ?? '',
      services: List<String>.from(data['services'] ?? []),
      address: data['address'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      notes: data['notes'] ?? '',
      status: _getOrderStatus(data['status']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      startedAt: data['startedAt'] != null ? (data['startedAt'] as Timestamp).toDate() : null,
      completedAt: data['completedAt'] != null ? (data['completedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'serviceProviderId': serviceProviderId,
      'serviceProviderName': serviceProviderName,
      'serviceCategory': serviceCategory,
      'services': services,
      'address': address,
      'phoneNumber': phoneNumber,
      'notes': notes,
      'status': _getStatusString(status),
      'createdAt': Timestamp.fromDate(createdAt),
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  OrderModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? serviceProviderId,
    String? serviceProviderName,
    String? serviceCategory,
    List<String>? services,
    String? address,
    String? phoneNumber,
    String? notes,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      serviceProviderId: serviceProviderId ?? this.serviceProviderId,
      serviceProviderName: serviceProviderName ?? this.serviceProviderName,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      services: services ?? this.services,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  static OrderStatus _getOrderStatus(String? status) {
    switch (status) {
      case 'new_order':
        return OrderStatus.new_order;
      case 'ongoing':
        return OrderStatus.ongoing;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.new_order;
    }
  }

  static String _getStatusString(OrderStatus status) {
    switch (status) {
      case OrderStatus.new_order:
        return 'new_order';
      case OrderStatus.ongoing:
        return 'ongoing';
      case OrderStatus.completed:
        return 'completed';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }
}
