class ServiceProviderModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String category;
  final String description;
  final double rating;
  final int reviewCount;
  final List<String> services;
  final String? profileImageUrl;
  final String? address;
  final bool isAvailable;
  final Map<String, dynamic>? businessHours;
  final List<String>? portfolioImages;
  
  ServiceProviderModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.category,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.services,
    this.profileImageUrl,
    this.address,
    required this.isAvailable,
    this.businessHours,
    this.portfolioImages,
  });
  
  factory ServiceProviderModel.fromJson(Map<String, dynamic> json) {
    return ServiceProviderModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      services: json['services'] != null 
          ? List<String>.from(json['services']) 
          : [],
      profileImageUrl: json['profileImageUrl'],
      address: json['address'],
      isAvailable: json['isAvailable'] ?? false,
      businessHours: json['businessHours'],
      portfolioImages: json['portfolioImages'] != null 
          ? List<String>.from(json['portfolioImages']) 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'category': category,
      'description': description,
      'rating': rating,
      'reviewCount': reviewCount,
      'services': services,
      'profileImageUrl': profileImageUrl,
      'address': address,
      'isAvailable': isAvailable,
      'businessHours': businessHours,
      'portfolioImages': portfolioImages,
    };
  }
  
  // Method to create a copy of this model with updated fields
  ServiceProviderModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? category,
    String? description,
    double? rating,
    int? reviewCount,
    List<String>? services,
    String? profileImageUrl,
    String? address,
    bool? isAvailable,
    Map<String, dynamic>? businessHours,
    List<String>? portfolioImages,
  }) {
    return ServiceProviderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      category: category ?? this.category,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      services: services ?? this.services,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      address: address ?? this.address,
      isAvailable: isAvailable ?? this.isAvailable,
      businessHours: businessHours ?? this.businessHours,
      portfolioImages: portfolioImages ?? this.portfolioImages,
    );
  }
}
