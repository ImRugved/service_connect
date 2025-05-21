import 'package:flutter/material.dart';

class LoginProvider extends ChangeNotifier {
  bool _obscurePassword = true;
  
  // Getters
  bool get obscurePassword => _obscurePassword;
  
  // Toggle password visibility
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }
}
