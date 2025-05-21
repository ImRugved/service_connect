import 'package:flutter/material.dart';

class SignupProvider extends ChangeNotifier {
  String _selectedUserType = 'customer';
  String _selectedCategory = '';
  final List<String> _selectedServices = [];
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  // Getters
  String get selectedUserType => _selectedUserType;
  String get selectedCategory => _selectedCategory;
  List<String> get selectedServices => _selectedServices;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  
  // Set user type
  void setUserType(String userType) {
    _selectedUserType = userType;
    notifyListeners();
  }
  
  // Set category
  void setCategory(String category) {
    _selectedCategory = category;
    _selectedServices.clear();
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
  
  // Toggle password visibility
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }
  
  // Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }
  
  // Reset state
  void reset() {
    _selectedUserType = 'customer';
    _selectedCategory = '';
    _selectedServices.clear();
    _obscurePassword = true;
    _obscureConfirmPassword = true;
    notifyListeners();
  }
}
