import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_interface.dart';
import '../services/auth_service.dart';
import '../services/dev_auth_service.dart';
import '../utils/dev_config.dart';

/// Provider for managing authentication state throughout the app
class AuthProvider extends ChangeNotifier {
  late final AuthInterface _authService;
  
  AuthProvider() {
    // Use dev auth service in development mode, real auth service in production
    _authService = DevConfig.enableDevAuth ? DevAuthService() : AuthService();
  }

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  /// Current authenticated user
  User? get user => _user;

  /// Whether authentication operation is in progress
  bool get isLoading => _isLoading;

  /// Current error message, if any
  String? get errorMessage => _errorMessage;

  /// Whether user is authenticated
  bool get isAuthenticated => _user != null;

  /// Whether current user is an administrator
  bool get isAdmin => _user?.role == UserRole.administrator;

  /// Initialize the auth provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _authService.initialize();
      _user = _authService.currentUser;
      _clearError();
    } catch (e) {
      _setError('Failed to initialize authentication');
    } finally {
      _setLoading(false);
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.login(email, password);
      
      if (result.isSuccess) {
        _user = result.user;
        _clearError();
        notifyListeners();
        return true;
      } else {
        _setError(result.errorMessage ?? 'Login failed');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred during login');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _user = null;
      _clearError();
    } catch (e) {
      _setError('Failed to logout');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh the authentication token
  Future<bool> refreshToken() async {
    try {
      final success = await _authService.refreshToken();
      if (success) {
        _user = _authService.currentUser;
        notifyListeners();
      } else {
        // Token refresh failed, user needs to login again
        _user = null;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _user = null;
      notifyListeners();
      return false;
    }
  }

  /// Check if the current session is valid
  Future<bool> validateSession() async {
    if (!isAuthenticated) return false;

    try {
      final isValid = await _authService.isSessionValid();
      if (!isValid) {
        _user = null;
        notifyListeners();
      }
      return isValid;
    } catch (e) {
      _user = null;
      notifyListeners();
      return false;
    }
  }

  /// Clear any error messages
  void clearError() {
    _clearError();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}