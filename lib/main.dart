import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coptic_pulse/pages/login.dart';
import 'package:coptic_pulse/pages/home.dart';
import 'package:coptic_pulse/utils/theme.dart';
import 'package:coptic_pulse/utils/constants.dart';
import 'package:coptic_pulse/services/api_service.dart';
import 'package:coptic_pulse/services/auth_service.dart';
import 'package:coptic_pulse/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  ApiService().initialize();
  await AuthService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider()..initialize(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/home': (context) => const HomePage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// Wrapper widget that handles authentication state and routing
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen while initializing
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Navigate based on authentication state
        if (authProvider.isAuthenticated) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}

