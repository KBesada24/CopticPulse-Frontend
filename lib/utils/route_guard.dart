import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Utility class for protecting routes based on user roles
class RouteGuard {
  /// Check if current user has admin privileges
  static bool isAdmin(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isAdmin;
  }

  /// Check if current user is authenticated
  static bool isAuthenticated(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isAuthenticated;
  }

  /// Navigate to a route only if user has admin privileges
  static Future<T?> pushAdminRoute<T extends Object?>(
    BuildContext context,
    Widget screen, {
    String? routeName,
  }) async {
    if (!isAdmin(context)) {
      _showAccessDeniedDialog(context);
      return null;
    }

    return Navigator.of(context).push<T>(
      MaterialPageRoute(
        builder: (context) => screen,
        settings: routeName != null ? RouteSettings(name: routeName) : null,
      ),
    );
  }

  /// Replace current route with admin route only if user has admin privileges
  static Future<T?> pushReplacementAdminRoute<T extends Object?, TO extends Object?>(
    BuildContext context,
    Widget screen, {
    String? routeName,
    TO? result,
  }) async {
    if (!isAdmin(context)) {
      _showAccessDeniedDialog(context);
      return null;
    }

    return Navigator.of(context).pushReplacement<T, TO>(
      MaterialPageRoute(
        builder: (context) => screen,
        settings: routeName != null ? RouteSettings(name: routeName) : null,
      ),
      result: result,
    );
  }

  /// Navigate to a route only if user is authenticated
  static Future<T?> pushAuthenticatedRoute<T extends Object?>(
    BuildContext context,
    Widget screen, {
    String? routeName,
  }) async {
    if (!isAuthenticated(context)) {
      _showLoginRequiredDialog(context);
      return null;
    }

    return Navigator.of(context).push<T>(
      MaterialPageRoute(
        builder: (context) => screen,
        settings: routeName != null ? RouteSettings(name: routeName) : null,
      ),
    );
  }

  /// Show access denied dialog for admin routes
  static void _showAccessDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Access Denied'),
        content: const Text(
          'You need administrator privileges to access this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show login required dialog for authenticated routes
  static void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text(
          'You need to be logged in to access this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to login screen
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}

/// Widget wrapper that protects child widgets based on user role
class AdminOnlyWidget extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const AdminOnlyWidget({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAdmin) {
          return child;
        }
        
        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}

/// Widget wrapper that protects child widgets for authenticated users only
class AuthenticatedOnlyWidget extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const AuthenticatedOnlyWidget({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          return child;
        }
        
        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}

/// Mixin for screens that require admin access
mixin AdminRequiredMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAdminAccess();
    });
  }

  void _checkAdminAccess() {
    if (!RouteGuard.isAdmin(context)) {
      Navigator.of(context).pop();
      RouteGuard._showAccessDeniedDialog(context);
    }
  }
}

/// Mixin for screens that require authentication
mixin AuthenticationRequiredMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthentication();
    });
  }

  void _checkAuthentication() {
    if (!RouteGuard.isAuthenticated(context)) {
      Navigator.of(context).pop();
      RouteGuard._showLoginRequiredDialog(context);
    }
  }
}