import 'package:flutter_test/flutter_test.dart';
import 'package:coptic_pulse/models/user.dart';

void main() {
  group('User Model Tests', () {
    const testUserJson = {
      'id': 'user123',
      'email': 'john@example.com',
      'name': 'John Doe',
      'role': 'member',
      'title': null,
    };

    const testAdminJson = {
      'id': 'admin123',
      'email': 'father.john@church.com',
      'name': 'Father John',
      'role': 'administrator',
      'title': 'Father',
    };

    test('should create User from JSON correctly', () {
      final user = User.fromJson(testUserJson);

      expect(user.id, equals('user123'));
      expect(user.email, equals('john@example.com'));
      expect(user.name, equals('John Doe'));
      expect(user.role, equals(UserRole.member));
      expect(user.title, isNull);
    });

    test('should create Admin User from JSON correctly', () {
      final admin = User.fromJson(testAdminJson);

      expect(admin.id, equals('admin123'));
      expect(admin.email, equals('father.john@church.com'));
      expect(admin.name, equals('Father John'));
      expect(admin.role, equals(UserRole.administrator));
      expect(admin.title, equals('Father'));
    });

    test('should convert User to JSON correctly', () {
      const user = User(
        id: 'user123',
        email: 'john@example.com',
        name: 'John Doe',
        role: UserRole.member,
      );

      final json = user.toJson();

      expect(json['id'], equals('user123'));
      expect(json['email'], equals('john@example.com'));
      expect(json['name'], equals('John Doe'));
      expect(json['role'], equals('member'));
      expect(json.containsKey('title'), isFalse);
    });

    test('should convert Admin User to JSON correctly', () {
      const admin = User(
        id: 'admin123',
        email: 'father.john@church.com',
        name: 'Father John',
        role: UserRole.administrator,
        title: 'Father',
      );

      final json = admin.toJson();

      expect(json['id'], equals('admin123'));
      expect(json['email'], equals('father.john@church.com'));
      expect(json['name'], equals('Father John'));
      expect(json['role'], equals('administrator'));
      expect(json['title'], equals('Father'));
    });

    test('should handle invalid role gracefully', () {
      final invalidJson = {
        'id': 'user123',
        'email': 'john@example.com',
        'name': 'John Doe',
        'role': 'invalid_role',
      };

      final user = User.fromJson(invalidJson);
      expect(user.role, equals(UserRole.member)); // Should default to member
    });

    test('should create copy with updated fields', () {
      const originalUser = User(
        id: 'user123',
        email: 'john@example.com',
        name: 'John Doe',
        role: UserRole.member,
      );

      final updatedUser = originalUser.copyWith(
        name: 'John Smith',
        role: UserRole.administrator,
        title: 'Father',
      );

      expect(updatedUser.id, equals('user123'));
      expect(updatedUser.email, equals('john@example.com'));
      expect(updatedUser.name, equals('John Smith'));
      expect(updatedUser.role, equals(UserRole.administrator));
      expect(updatedUser.title, equals('Father'));
    });

    test('should implement equality correctly', () {
      const user1 = User(
        id: 'user123',
        email: 'john@example.com',
        name: 'John Doe',
        role: UserRole.member,
      );

      const user2 = User(
        id: 'user123',
        email: 'john@example.com',
        name: 'John Doe',
        role: UserRole.member,
      );

      const user3 = User(
        id: 'user456',
        email: 'jane@example.com',
        name: 'Jane Doe',
        role: UserRole.member,
      );

      expect(user1, equals(user2));
      expect(user1, isNot(equals(user3)));
      expect(user1.hashCode, equals(user2.hashCode));
    });

    test('should have proper toString implementation', () {
      const user = User(
        id: 'user123',
        email: 'john@example.com',
        name: 'John Doe',
        role: UserRole.member,
        title: 'Mr.',
      );

      final string = user.toString();
      expect(string, contains('user123'));
      expect(string, contains('john@example.com'));
      expect(string, contains('John Doe'));
      expect(string, contains('UserRole.member'));
      expect(string, contains('Mr.'));
    });

    group('UserRole enum tests', () {
      test('should have correct display names', () {
        expect(UserRole.member.displayName, equals('Member'));
        expect(UserRole.administrator.displayName, equals('Administrator'));
      });

      test('should serialize to correct string values', () {
        expect(UserRole.member.name, equals('member'));
        expect(UserRole.administrator.name, equals('administrator'));
      });
    });
  });
}