import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:coptic_pulse/widgets/custom_app_bar.dart';
import 'package:coptic_pulse/providers/auth_provider.dart';
import 'package:coptic_pulse/models/user.dart';

/// Mock AuthProvider for testing
class MockAuthProvider extends AuthProvider {
  final User? _user;
  
  MockAuthProvider({User? user}) : _user = user;
  
  @override
  User? get user => _user;
  
  @override
  bool get isAuthenticated => _user != null;
  
  @override
  bool get isAdmin => _user?.role == UserRole.administrator;
  
  @override
  bool get isLoading => false;
  
  @override
  String? get errorMessage => null;
}

void main() {
  group('CustomAppBar', () {
    Widget createTestWidget({User? user}) {
      return MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>(
          create: (context) => MockAuthProvider(user: user),
          child: const Scaffold(
            appBar: CustomAppBar(title: 'Test Title'),
            body: Center(child: Text('Test Body')),
          ),
        ),
      );
    }

    testWidgets('displays title correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('displays Coptic cross icon', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Look for the icon container
      expect(find.byIcon(Icons.add), findsOneWidget); // Using add as placeholder for cross
    });

    testWidgets('displays user menu button', (WidgetTester tester) async {
      const testUser = User(
        id: '1',
        email: 'test@example.com',
        name: 'Test User',
        role: UserRole.member,
      );

      await tester.pumpWidget(createTestWidget(user: testUser));

      expect(find.byIcon(Icons.account_circle), findsOneWidget);
    });

    testWidgets('shows user menu when tapped', (WidgetTester tester) async {
      const testUser = User(
        id: '1',
        email: 'test@example.com',
        name: 'Test User',
        role: UserRole.member,
      );

      await tester.pumpWidget(createTestWidget(user: testUser));

      // Tap the user menu button
      await tester.tap(find.byIcon(Icons.account_circle));
      await tester.pumpAndSettle();

      // Check if menu items are displayed
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('shows admin settings for admin users', (WidgetTester tester) async {
      const adminUser = User(
        id: '1',
        email: 'admin@example.com',
        name: 'Admin User',
        role: UserRole.administrator,
        title: 'Father John',
      );

      await tester.pumpWidget(createTestWidget(user: adminUser));

      // Tap the user menu button
      await tester.tap(find.byIcon(Icons.account_circle));
      await tester.pumpAndSettle();

      // Check if admin-specific menu items are displayed
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows back button when showBackButton is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>(
            create: (context) => MockAuthProvider(),
            child: const Scaffold(
              appBar: CustomAppBar(
                title: 'Test Title',
                showBackButton: true,
              ),
              body: Center(child: Text('Test Body')),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });
}