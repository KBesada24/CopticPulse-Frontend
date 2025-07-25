import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import '../utils/dev_config.dart';
import 'auth_interface.dart';
import 'auth_service.dart';

/// Developer authentication service for testing without a backend
/// ⚠️ WARNING: This service should NEVER be used in production builds!
class DevAuthService implements AuthInterface {
  static final DevAuthService _instance = DevAuthService._internal();
  factory DevAuthService() {
    // Safety check: Prevent instantiation in release builds
    if (kReleaseMode) {
      throw StateError(
        'DevAuthService cannot be used in release builds! '
        'This is a development-only service.'
      );
    }
    return _instance;
  }
  DevAuthService._internal() {
    // Additional safety check
    if (!DevConfig.isDevelopment) {
      throw StateError(
        'DevAuthService is only available in development mode!'
      );
    }
  }

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  User? _currentUser;

  // Predefined test users
  static const Map<String, Map<String, dynamic>> _testUsers = {
    'admin@copticpulse.com': {
      'password': 'admin123',
      'user': {
        'id': '1',
        'email': 'admin@copticpulse.com',
        'name': 'Father John',
        'role': 'administrator',
        'title': 'Father John',
      },
    },
    'member@copticpulse.com': {
      'password': 'member123',
      'user': {
        'id': '2',
        'email': 'member@copticpulse.com',
        'name': 'Mary Smith',
        'role': 'member',
      },
    },
    'dev@test.com': {
      'password': 'dev123',
      'user': {
        'id': '3',
        'email': 'dev@test.com',
        'name': 'Developer User',
        'role': 'administrator',
        'title': 'Developer',
      },
    },
  };

  @override
  User? get currentUser => _currentUser;

  @override
  bool get isAuthenticated => _currentUser != null;

  @override
  bool get isAdmin => _currentUser?.role == UserRole.administrator;

  @override
  Future<void> initialize() async {
    await _loadUserFromStorage();
  }

  @override
  Future<AuthResult> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final testUser = _testUsers[email.toLowerCase()];

    if (testUser == null) {
      return AuthResult.failure(
        'User not found. Try: admin@copticpulse.com, member@copticpulse.com, or dev@test.com',
      );
    }

    if (testUser['password'] != password) {
      return AuthResult.failure(
        'Invalid password. Check the predefined passwords in DevAuthService.',
      );
    }

    try {
      // Create user from test data
      _currentUser = User.fromJson(testUser['user']);

      // Store mock tokens
      await _secureStorage.write(
        key: AppConstants.accessTokenKey,
        value: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
      );

      await _secureStorage.write(
        key: AppConstants.refreshTokenKey,
        value: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      );

      // Store user data
      await _storeUserData(_currentUser!);

      return AuthResult.success(_currentUser!);
    } catch (e) {
      return AuthResult.failure('Failed to process login: $e');
    }
  }

  @override
  Future<void> logout() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    await _clearAuthData();
  }

  @override
  Future<bool> refreshToken() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final refreshToken = await _secureStorage.read(
      key: AppConstants.refreshTokenKey,
    );
    if (refreshToken == null ||
        !refreshToken.startsWith('mock_refresh_token_')) {
      return false;
    }

    // Generate new mock tokens
    await _secureStorage.write(
      key: AppConstants.accessTokenKey,
      value: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
    );

    await _secureStorage.write(
      key: AppConstants.refreshTokenKey,
      value: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
    );

    return true;
  }

  @override
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: AppConstants.accessTokenKey);
  }

  @override
  Future<bool> isSessionValid() async {
    final token = await getAccessToken();
    if (token == null || !token.startsWith('mock_access_token_')) {
      return false;
    }

    // Mock sessions are always valid for development
    return _currentUser != null;
  }

  /// Load user data from secure storage
  Future<void> _loadUserFromStorage() async {
    try {
      final userDataJson = await _secureStorage.read(
        key: AppConstants.userDataKey,
      );
      if (userDataJson != null) {
        final userData = jsonDecode(userDataJson);
        _currentUser = User.fromJson(userData);

        // For dev mode, we'll assume stored sessions are valid
        final token = await getAccessToken();
        if (token == null || !token.startsWith('mock_access_token_')) {
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

  /// Get available test credentials for development
  static Map<String, String> getTestCredentials() {
    return {
      'Admin User': 'admin@copticpulse.com / admin123',
      'Member User': 'member@copticpulse.com / member123',
      'Developer User': 'dev@test.com / dev123',
    };
  }

  /// Print available test credentials to console
  /// ⚠️ Only works in debug builds - will not print in release
  static void printTestCredentials() {
    // Safety check: Never print credentials in release builds
    if (kReleaseMode || !DevConfig.isDevelopment) {
      return;
    }
    
    debugPrint('\n=== COPTIC PULSE DEV LOGIN CREDENTIALS ===');
    final credentials = getTestCredentials();
    credentials.forEach((role, creds) {
      debugPrint('$role: $creds');
    });
    debugPrint('⚠️  DEV ONLY - These credentials will not work in production');
    debugPrint('==========================================\n');
  }
}
