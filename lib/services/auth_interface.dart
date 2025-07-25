import '../models/user.dart';
import 'auth_service.dart';

/// Interface for authentication services
abstract class AuthInterface {
  /// Get the currently authenticated user
  User? get currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated;

  /// Check if current user is an administrator
  bool get isAdmin;

  /// Initialize the auth service
  Future<void> initialize();

  /// Login with email and password
  Future<AuthResult> login(String email, String password);

  /// Logout the current user
  Future<void> logout();

  /// Refresh the authentication token
  Future<bool> refreshToken();

  /// Get the current access token
  Future<String?> getAccessToken();

  /// Check if the current session is valid
  Future<bool> isSessionValid();
}