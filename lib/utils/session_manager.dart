import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  // Keys
  static const String authTokenKey = 'auth_token';
  static const String userTypeKey = 'user_type';
  static const String userIdKey = 'user_id';

  // Save auth token to indicate user is logged in
  static Future<bool> saveAuthToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(authTokenKey, token);
  }

  // Get auth token
  static Future<String?> getAuthToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(authTokenKey);
  }

  // Save user type (customer or service_provider)
  static Future<bool> saveUserType(String userType) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userTypeKey, userType);
  }

  // Get user type
  static Future<String?> getUserType() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userTypeKey);
  }

  // Save user ID
  static Future<bool> saveUserId(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userIdKey, userId);
  }

  // Get user ID
  static Future<String?> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(authTokenKey) && prefs.getString(authTokenKey) != null;
  }

  // Clear session data (logout)
  static Future<bool> clearSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
}
