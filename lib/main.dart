import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coptic_pulse/pages/login.dart';
import 'package:coptic_pulse/pages/home.dart';
import 'package:coptic_pulse/pages/main_navigation.dart';
import 'package:coptic_pulse/utils/theme.dart';
import 'package:coptic_pulse/utils/constants.dart';
import 'package:coptic_pulse/utils/dev_config.dart';
import 'package:coptic_pulse/services/api_service.dart';
import 'package:coptic_pulse/services/auth_service.dart';
import 'package:coptic_pulse/services/dev_auth_service.dart';
import 'package:coptic_pulse/providers/auth_provider.dart';
import 'package:coptic_pulse/providers/navigation_provider.dart';
import 'package:coptic_pulse/providers/liturgy_provider.dart';
import 'package:coptic_pulse/providers/sermon_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only show dev info in debug builds
  if (DevConfig.isDevelopment && DevConfig.enableDevAuth) {
    DevConfig.printConfig();
    DevAuthService.printTestCredentials();
  }

  // Initialize services
  ApiService().initialize();

      // Initialize appropriate auth service based on dev config
  // This will always use AuthService in release builds
  if (DevConfig.enableDevAuth) {
    await DevAuthService().initialize();
  } else {
    await AuthService().initialize();
  }

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
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
        ChangeNotifierProvider(create: (context) => LiturgyProvider()),
        ChangeNotifierProvider(create: (context) => SermonProvider()),
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
          '/main': (context) => const MainNavigationPage(),
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
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Navigate based on authentication state
        if (authProvider.isAuthenticated) {
          return const MainNavigationPage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
