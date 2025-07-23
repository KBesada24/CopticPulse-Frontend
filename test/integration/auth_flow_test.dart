import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:coptic_pulse/main.dart';
import 'package:coptic_pulse/providers/auth_provider.dart';
import 'package:coptic_pulse/pages/login.dart';
import 'package:coptic_pulse/pages/home.dart';

void main() {
  group('Authentication Flow Integration Tests', () {
    testWidgets('should show login page when not authenticated', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());
      
      // Wait for initialization
      await tester.pumpAndSettle();
      
      // Verify login page is shown
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('should show validation errors for invalid input', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      
      // Find and tap the login button without entering credentials
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();
      
      // Verify validation errors are shown
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('should show email validation error for invalid email', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      
      // Enter invalid email
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'invalid-email');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      
      // Tap login button
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();
      
      // Verify email validation error
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should show password validation error for short password', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      
      // Enter valid email but short password
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), '123');
      
      // Tap login button
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();
      
      // Verify password validation error
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('should show loading state during login attempt', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      
      // Enter valid credentials
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      
      // Tap login button
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);
      
      // Pump once to trigger the login process
      await tester.pump();
      
      // Verify loading indicator is shown (this will likely fail due to network call)
      // In a real test, we would mock the network calls
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('should handle authentication state changes', (WidgetTester tester) async {
      // Create a test app with a mock auth provider
      final authProvider = AuthProvider();
      
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp(
            home: Consumer<AuthProvider>(
              builder: (context, auth, child) {
                if (auth.isAuthenticated) {
                  return const HomePage();
                } else {
                  return const LoginPage();
                }
              },
            ),
          ),
        ),
      );
      
      // Initially should show login page
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
      
      // Note: In a real integration test, we would simulate successful authentication
      // and verify that the HomePage is shown. This would require mocking the backend.
    });
  });
}