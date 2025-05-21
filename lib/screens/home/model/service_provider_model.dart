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
}
