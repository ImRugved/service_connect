import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../utils/session_manager.dart';
import '../model/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _firebaseUser != null;
  
  AuthProvider() {
    _init();
  }
  
  void _init() {
    _auth.authStateChanges().listen((User? user) async {
      _firebaseUser = user;
      if (user != null) {
        await _fetchUserData();
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }
  
  Future<void> _fetchUserData() async {
    try {
      _setLoading(true);
      final docSnapshot = await _firestore
          .collection('users')
          .doc(_firebaseUser!.uid)
          .get();
      
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        _userModel = UserModel.fromJson({
          'uid': _firebaseUser!.uid,
          ...data,
        });
      }
      _setLoading(false);
    } catch (e) {
      _setError('Failed to fetch user data: $e');
    }
  }
  
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String userType,
    String? phoneNumber,
    String? category,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user document in Firestore
      final user = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        userType: userType,
        phoneNumber: phoneNumber,
      );
      
      // Create user data with additional fields if needed
      final userData = user.toJson();
      
      // Add category for service providers
      if (userType == 'service_provider' && category != null) {
        userData['category'] = category;
        userData['isAvailable'] = true; // Set default availability
      }
      
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userData);
      
      // Save session data
      await SessionManager.saveAuthToken(userCredential.user!.uid);
      await SessionManager.saveUserType(userType);
      await SessionManager.saveUserId(userCredential.user!.uid);
      
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      String message;
      
      switch (e.code) {
        case 'email-already-in-use':
          message = 'The email address is already in use.';
          break;
        case 'weak-password':
          message = 'The password is too weak.';
          break;
        case 'invalid-email':
          message = 'The email address is invalid.';
          break;
        default:
          message = 'An error occurred during sign up.';
      }
      
      _setError(message);
      return false;
    } catch (e) {
      _setError('Failed to sign up: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Fetch user data to get the user type
      final docSnapshot = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final userType = data['userType'] as String;
        
        // Save session data
        await SessionManager.saveAuthToken(userCredential.user!.uid);
        await SessionManager.saveUserType(userType);
        await SessionManager.saveUserId(userCredential.user!.uid);
      }
      
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      String message;
      
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided.';
          break;
        case 'invalid-email':
          message = 'The email address is invalid.';
          break;
        case 'user-disabled':
          message = 'This user has been disabled.';
          break;
        default:
          message = 'An error occurred during sign in.';
      }
      
      _setError(message);
      return false;
    } catch (e) {
      _setError('Failed to sign in: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _auth.signOut();
      
      // Clear session data
      await SessionManager.clearSession();
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to sign out: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
  }) async {
    try {
      if (_firebaseUser == null || _userModel == null) {
        _setError('User not authenticated');
        return false;
      }
      
      _setLoading(true);
      
      final updatedData = {
        if (name != null) 'name': name,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (address != null) 'address': address,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      };
      
      if (updatedData.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(_firebaseUser!.uid)
            .update(updatedData);
        
        // Update local user model
        _userModel = _userModel!.copyWith(
          name: name,
          phoneNumber: phoneNumber,
          address: address,
          profileImageUrl: profileImageUrl,
        );
        
        notifyListeners();
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> updateServiceProviderDetails(Map<String, dynamic> details) async {
    try {
      if (_firebaseUser == null || _userModel == null) {
        _setError('User not authenticated');
        return false;
      }
      
      if (_userModel!.userType != 'service_provider') {
        _setError('User is not a service provider');
        return false;
      }
      
      _setLoading(true);
      
      await _firestore
          .collection('users')
          .doc(_firebaseUser!.uid)
          .update({
        'serviceProviderDetails': details,
      });
      
      // Update local user model
      _userModel = _userModel!.copyWith(
        serviceProviderDetails: details,
      );
      
      notifyListeners();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update service provider details: $e');
      return false;
    } finally {
      _setLoading(false);
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
  
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
