import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class ProfileProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false;
  bool _isEditing = false;
  String? _errorMessage;
  
  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  
  // Service provider specific
  String _selectedCategory = '';
  final List<String> _selectedServices = [];
  final businessHoursController = {
    'Monday': {'start': TextEditingController(), 'end': TextEditingController()},
    'Tuesday': {'start': TextEditingController(), 'end': TextEditingController()},
    'Wednesday': {'start': TextEditingController(), 'end': TextEditingController()},
    'Thursday': {'start': TextEditingController(), 'end': TextEditingController()},
    'Friday': {'start': TextEditingController(), 'end': TextEditingController()},
    'Saturday': {'start': TextEditingController(), 'end': TextEditingController()},
    'Sunday': {'start': TextEditingController(), 'end': TextEditingController()},
  };
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isEditing => _isEditing;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  List<String> get selectedServices => _selectedServices;
  
  // Initialize controllers with user data
  Future<void> initializeControllers() async {
    try {
      _setLoading(true);
      
      final user = _auth.currentUser;
      if (user == null) {
        _setError('User not authenticated');
        return;
      }
      
      final docSnapshot = await _firestore.collection('users').doc(user.uid).get();
      
      if (!docSnapshot.exists) {
        _setError('User profile not found');
        return;
      }
      
      final data = docSnapshot.data()!;
      
      nameController.text = data['name'] ?? '';
      emailController.text = data['email'] ?? '';
      phoneController.text = data['phoneNumber'] ?? '';
      addressController.text = data['address'] ?? '';
      
      if (data['userType'] == 'service_provider') {
        final serviceProviderDetails = data['serviceProviderDetails'] ?? {};
        _selectedCategory = serviceProviderDetails['category'] ?? '';
        _selectedServices.clear();
        _selectedServices.addAll(List<String>.from(serviceProviderDetails['services'] ?? []));
        
        final businessHours = serviceProviderDetails['businessHours'] ?? {};
        
        businessHoursController.forEach((day, controllers) {
          final dayHours = businessHours[day] ?? {};
          controllers['start']!.text = dayHours['start'] ?? '';
          controllers['end']!.text = dayHours['end'] ?? '';
        });
      }
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load profile: $e');
    }
  }
  
  // Toggle editing mode
  void toggleEditing(bool value) {
    _isEditing = value;
    if (!value) {
      // Reset controllers to current values if canceling edit
      initializeControllers();
    }
    notifyListeners();
  }
  
  // Set category
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
  
  // Toggle service selection
  void toggleService(String service) {
    if (_selectedServices.contains(service)) {
      _selectedServices.remove(service);
    } else {
      _selectedServices.add(service);
    }
    notifyListeners();
  }
  
  // Update profile with UI feedback
  Future<bool> updateProfile(BuildContext context) async {
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
      final userType = data['userType'];
      
      final Map<String, dynamic> updateData = {
        'name': nameController.text.trim(),
        'phoneNumber': phoneController.text.trim(),
        'address': addressController.text.trim(),
      };
      
      if (userType == 'service_provider') {
        final Map<String, Map<String, String>> businessHours = {};
        
        businessHoursController.forEach((day, controllers) {
          businessHours[day] = {
            'start': controllers['start']!.text.trim(),
            'end': controllers['end']!.text.trim(),
          };
        });
        
        final Map<String, dynamic> serviceProviderDetails = {
          'category': _selectedCategory,
          'services': _selectedServices,
          'businessHours': businessHours,
          'isAvailable': data['serviceProviderDetails']?['isAvailable'] ?? true,
          'rating': data['serviceProviderDetails']?['rating'] ?? 0.0,
        };
        
        updateData['serviceProviderDetails'] = serviceProviderDetails;
      }
      
      await _firestore.collection('users').doc(user.uid).update(updateData);
      
      _isEditing = false;
      _setLoading(false);
      
      // Show success message
      showSuccessMessage(context, 'Profile updated successfully');
      return true;
    } catch (e) {
      _setError('Failed to update profile: $e');
      showErrorMessage(context, 'Failed to update profile: $e');
      return false;
    }
  }
  
  // Sign out with navigation
  Future<void> signOut(BuildContext context) async {
    try {
      _setLoading(true);
      await _auth.signOut();
      _setLoading(false);
      
      // Navigate to login screen
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      _setError('Failed to sign out: $e');
      showErrorMessage(context, 'Failed to sign out: $e');
    }
  }
  
  // Show success message
  void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  // Show error message
  void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
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
  
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    
    businessHoursController.forEach((day, controllers) {
      controllers['start']!.dispose();
      controllers['end']!.dispose();
    });
    
    super.dispose();
  }
}
