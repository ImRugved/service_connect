class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? phoneNumber;
  final String userType; // 'customer' or 'service_provider'
  final String? profileImageUrl;
  final String? address;
  final Map<String, dynamic>? serviceProviderDetails;
  final List<String>? favoriteServiceProviders;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.phoneNumber,
    required this.userType,
    this.profileImageUrl,
    this.address,
    this.serviceProviderDetails,
    this.favoriteServiceProviders,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'],
      userType: json['userType'] ?? 'customer',
      profileImageUrl: json['profileImageUrl'],
      address: json['address'],
      serviceProviderDetails: json['serviceProviderDetails'],
      favoriteServiceProviders: json['favoriteServiceProviders'] != null
          ? List<String>.from(json['favoriteServiceProviders'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'userType': userType,
      'profileImageUrl': profileImageUrl,
      'address': address,
      'serviceProviderDetails': serviceProviderDetails,
      'favoriteServiceProviders': favoriteServiceProviders,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phoneNumber,
    String? userType,
    String? profileImageUrl,
    String? address,
    Map<String, dynamic>? serviceProviderDetails,
    List<String>? favoriteServiceProviders,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userType: userType ?? this.userType,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      address: address ?? this.address,
      serviceProviderDetails: serviceProviderDetails ?? this.serviceProviderDetails,
      favoriteServiceProviders: favoriteServiceProviders ?? this.favoriteServiceProviders,
    );
  }
}
