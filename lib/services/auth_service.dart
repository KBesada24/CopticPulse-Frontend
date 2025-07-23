import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import 'api_service.dart';

/// Service for handling authentication operations
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  User? _currentUser;

  /// Get the currently authenticated user
  User? get currentUser => _currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUser != null;

  /// Check if current user is an administrator
  bool get isAdmin => _currentUser?.role == UserRole.administrator;

  /// Initialize the auth service and check for existing session
  Future<void> initialize() async {
    await _loadUserFromStorage();
  }

  /// Login with email and password
  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        AppConstants.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Store tokens securely
        await _secureStorage.write(
          key: AppConstants.accessTokenKey,
          value: data['access_token'],
        );
        
        if (data['refresh_token'] != null) {
          await _secureStorage.write(
            key: AppConstants.refreshTokenKey,
            value: data['refresh_token'],
          );
        }

        // Create and store user
        _currentUser = User.fromJson(data['user']);
        await _storeUserData(_currentUser!);

        return AuthResult.success(_currentUser!);
      } else {
        return AuthResult.failure('Login failed');
      }
    } catch (e) {
      if (e is ApiError) {
        return AuthResult.failure(e.message);
      }
      return AuthResult.failure('An unexpected error occurred during login');
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    try {
      // Call logout endpoint if user is authenticated
      if (isAuthenticated) {
        await _apiService.post(AppConstants.logoutEndpoint);
      }
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      // Clear all stored data
      await _clearAuthData();
    }
  }

  /// Refresh the authentication token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: AppConstants.refreshTokenKey);
      if (refreshToken == null) return false;

      final response = await _apiService.post(
        AppConstants.refreshTokenEndpoint,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Update stored tokens
        await _secureStorage.write(
          key: AppConstants.accessTokenKey,
          value: data['access_token'],
        );
        
        if (data['refresh_token'] != null) {
          await _secureStorage.write(
            key: AppConstants.refreshTokenKey,
            value: data['refresh_token'],
          );
        }

        // Update user data if provided
        if (data['user'] != null) {
          _currentUser = User.fromJson(data['user']);
          await _storeUserData(_currentUser!);
        }

        return true;
      }
    } catch (e) {
      // Refresh failed, clear auth data
      await _clearAuthData();
    }
    
    return false;
  }

  /// Get the current access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: AppConstants.accessTokenKey);
  }

  /// Check if the current session is valid
  Future<bool> isSessionValid() async {
    final token = await getAccessToken();
    if (token == null) return false;

    try {
      // Try to make an authenticated request to validate the token
      final response = await _apiService.get('/auth/validate');
      return response.statusCode == 200;
    } catch (e) {
      // If validation fails, try to refresh the token
      return await refreshToken();
    }
  }

  /// Load user data from secure storage
  Future<void> _loadUserFromStorage() async {
    try {
      final userDataJson = await _secureStorage.read(key: AppConstants.userDataKey);
      if (userDataJson != null) {
        final userData = jsonDecode(userDataJson);
        _currentUser = User.fromJson(userData);
        
        // Validate the session
        final isValid = await isSessionValid();
        if (!isValid) {
          await _clearAuthData();
        }
      }
    } catch (e) {
      // If loading fails, clear potentially corrupted data
      await _clearAuthData();
    }
  }

  /// Store user data securely
  Future<void> _storeUserData(User user) async {
    final userDataJson = jsonEncode(user.toJson());
    await _secureStorage.write(
      key: AppConstants.userDataKey,
      value: userDataJson,
    );
  }

  /// Clear all authentication data
  Future<void> _clearAuthData() async {
    _currentUser = null;
    await _secureStorage.delete(key: AppConstants.accessTokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
    await _secureStorage.delete(key: AppConstants.userDataKey);
  }
}

/// Result class for authentication operations
class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final User? user;

  const AuthResult._({
    required this.isSuccess,
    this.errorMessage,
    this.user,
  });

  /// Create a successful authentication result
  factory AuthResult.success(User user) {
    return AuthResult._(
      isSuccess: true,
      user: user,
    );
  }

  /// Create a failed authentication result
  factory AuthResult.failure(String message) {
    return AuthResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }
}