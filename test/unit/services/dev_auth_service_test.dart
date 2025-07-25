import 'package:flutter_test/flutter_test.dart';
import 'package:coptic_pulse/services/dev_auth_service.dart';
import 'package:coptic_pulse/models/user.dart';

void main() {
  group('DevAuthService', () {
    late DevAuthService devAuthService;

    setUp(() {
      devAuthService = DevAuthService();
    });

    test('should login successfully with valid admin credentials', () async {
      final result = await devAuthService.login('admin@copticpulse.com', 'admin123');
      
      expect(result.isSuccess, true);
      expect(result.user, isNotNull);
      expect(result.user!.email, 'admin@copticpulse.com');
      expect(result.user!.role, UserRole.administrator);
      expect(result.user!.name, 'Father John');
    });

    test('should login successfully with valid member credentials', () async {
      final result = await devAuthService.login('member@copticpulse.com', 'member123');
      
      expect(result.isSuccess, true);
      expect(result.user, isNotNull);
      expect(result.user!.email, 'member@copticpulse.com');
      expect(result.user!.role, UserRole.member);
      expect(result.user!.name, 'Mary Smith');
    });

    test('should login successfully with dev credentials', () async {
      final result = await devAuthService.login('dev@test.com', 'dev123');
      
      expect(result.isSuccess, true);
      expect(result.user, isNotNull);
      expect(result.user!.email, 'dev@test.com');
      expect(result.user!.role, UserRole.administrator);
      expect(result.user!.name, 'Developer User');
    });

    test('should fail login with invalid email', () async {
      final result = await devAuthService.login('invalid@test.com', 'password');
      
      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('User not found'));
    });

    test('should fail login with invalid password', () async {
      final result = await devAuthService.login('admin@copticpulse.com', 'wrongpassword');
      
      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('Invalid password'));
    });

    test('should handle case insensitive email', () async {
      final result = await devAuthService.login('ADMIN@COPTICPULSE.COM', 'admin123');
      
      expect(result.isSuccess, true);
      expect(result.user!.email, 'admin@copticpulse.com');
    });

    test('should set current user after successful login', () async {
      expect(devAuthService.currentUser, isNull);
      expect(devAuthService.isAuthenticated, false);
      
      await devAuthService.login('admin@copticpulse.com', 'admin123');
      
      expect(devAuthService.currentUser, isNotNull);
      expect(devAuthService.isAuthenticated, true);
      expect(devAuthService.isAdmin, true);
    });

    test('should clear current user after logout', () async {
      await devAuthService.login('admin@copticpulse.com', 'admin123');
      expect(devAuthService.isAuthenticated, true);
      
      await devAuthService.logout();
      
      expect(devAuthService.currentUser, isNull);
      expect(devAuthService.isAuthenticated, false);
      expect(devAuthService.isAdmin, false);
    });

    test('should return test credentials', () {
      final credentials = DevAuthService.getTestCredentials();
      
      expect(credentials, isNotEmpty);
      expect(credentials.containsKey('Admin User'), true);
      expect(credentials.containsKey('Member User'), true);
      expect(credentials.containsKey('Developer User'), true);
      
      expect(credentials['Admin User'], 'admin@copticpulse.com / admin123');
      expect(credentials['Member User'], 'member@copticpulse.com / member123');
      expect(credentials['Developer User'], 'dev@test.com / dev123');
    });
  });
}