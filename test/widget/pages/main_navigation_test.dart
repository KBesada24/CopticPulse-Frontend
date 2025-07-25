import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:coptic_pulse/pages/main_navigation.dart';
import 'package:coptic_pulse/providers/auth_provider.dart';
import 'package:coptic_pulse/providers/navigation_provider.dart';
import 'package:coptic_pulse/models/user.dart';

/// Mock AuthProvider for testing
class MockAuthProvider extends AuthProvider {
  final bool _isAdmin;
  
  MockAuthProvider({bool isAdmin = false}) : _isAdmin = isAdmin;
  
  @override
  User? get user => _isAdmin 
    ? const User(
        id: '1',
        email: 'admin@test.com',
        name: 'Admin User',
        role: UserRole.administrator,
        title: 'Father John',
      )
    : const User(
        id: '2',
        email: 'member@test.com',
        name: 'Member User',
        role: UserRole.member,
      );
  
  @override
  bool get isAuthenticated => true;
  
  @override
  bool get isAdmin => _isAdmin;
  
  @override
  bool get isLoading => false;
  
  @override
  String? get errorMessage => null;
}

void main() {
  group('MainNavigationPage', () {
    late AuthProvider authProvider;
    late NavigationProvider navigationProvider;

    setUp(() {
      authProvider = AuthProvider();
      navigationProvider = NavigationProvider();
    });

    Widget createTestWidget({bool isAdmin = false}) {
      // Create a mock auth provider with user data
      final mockAuthProvider = MockAuthProvider(isAdmin: isAdmin);

      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            ChangeNotifierProvider<NavigationProvider>.value(value: navigationProvider),
          ],
          child: const MainNavigationPage(),
        ),
      );
    }

    testWidgets('displays bottom navigation with 4 tabs for members', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(isAdmin: false));

      // Verify bottom navigation bar exists
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Verify all 4 tabs are present for members
      expect(find.text('Community'), findsAtLeastNWidgets(1));
      expect(find.text('Liturgy'), findsAtLeastNWidgets(1));
      expect(find.text('Sermons'), findsAtLeastNWidgets(1));
      expect(find.text('Profile'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays bottom navigation with 4 tabs for admins', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(isAdmin: true));

      // Verify bottom navigation bar exists
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Verify all 4 tabs are present for admins
      expect(find.text('Community'), findsAtLeastNWidgets(1));
      expect(find.text('Liturgy'), findsAtLeastNWidgets(1));
      expect(find.text('Sermons'), findsAtLeastNWidgets(1));
      expect(find.text('Admin'), findsAtLeastNWidgets(1));
    });

    testWidgets('navigation between tabs works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(isAdmin: false));

      // Initially should be on Community tab (index 0)
      expect(navigationProvider.currentIndex, 0);

      // Tap on Liturgy tab
      await tester.tap(find.text('Liturgy'));
      await tester.pump();

      expect(navigationProvider.currentIndex, 1);

      // Tap on Sermons tab
      await tester.tap(find.text('Sermons'));
      await tester.pump();

      expect(navigationProvider.currentIndex, 2);

      // Tap on Profile tab
      await tester.tap(find.text('Profile'));
      await tester.pump();

      expect(navigationProvider.currentIndex, 3);
    });

    testWidgets('displays correct app bar titles for each tab', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(isAdmin: false));

      // Community tab should show "Community" in app bar
      expect(find.text('Community'), findsAtLeastNWidgets(1));

      // Navigate to Liturgy tab
      await tester.tap(find.text('Liturgy'));
      await tester.pump();
      expect(find.text('Liturgy Schedule'), findsAtLeastNWidgets(1));

      // Navigate to Sermons tab
      await tester.tap(find.text('Sermons'));
      await tester.pump();
      expect(find.text('Sermons'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows placeholder content for unimplemented screens', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(isAdmin: false));

      // Community screen should show placeholder
      expect(find.text('Community Screen'), findsOneWidget);
      expect(find.text('Coming soon...'), findsOneWidget);

      // Navigate to Sermons tab
      await tester.tap(find.text('Sermons'));
      await tester.pump();
      expect(find.text('Sermons Screen'), findsOneWidget);

      // Navigate to Profile tab
      await tester.tap(find.text('Profile'));
      await tester.pump();
      expect(find.text('Profile Screen'), findsOneWidget);
    });
  });
}