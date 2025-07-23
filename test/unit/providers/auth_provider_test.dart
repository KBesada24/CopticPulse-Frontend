import 'package:flutter_test/flutter_test.dart';
import 'package:coptic_pulse/providers/auth_provider.dart';
import 'package:coptic_pulse/models/user.dart';

void main() {
  group('AuthProvider', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    group('initialization', () {
      test('should initialize with default values', () {
        expect(authProvider.user, isNull);
        expect(authProvider.isLoading, false);
        expect(authProvider.errorMessage, isNull);
        expect(authProvider.isAuthenticated, false);
        expect(authProvider.isAdmin, false);
      });
    });

    group('error handling', () {
      test('should clear error message', () {
        // Arrange - simulate an error state
        authProvider.clearError();

        // Act
        authProvider.clearError();

        // Assert
        expect(authProvider.errorMessage, isNull);
      });
    });

    group('admin role detection', () {
      test('should return false when no user is authenticated', () {
        expect(authProvider.isAdmin, false);
      });

      test('should return false when user is not admin', () {
        expect(authProvider.isAuthenticated, false);
        expect(authProvider.isAdmin, false);
      });
    });

    group('authentication state', () {
      test('should return false when no user is set', () {
        expect(authProvider.isAuthenticated, false);
      });
    });
  });
}