import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../screens/liturgy_schedule.dart';
import '../screens/sermons_screen.dart';
import '../screens/admin_dashboard_screen.dart';

/// Main navigation page with bottom navigation bar and role-based views
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, NavigationProvider>(
      builder: (context, authProvider, navigationProvider, child) {
        final isAdmin = authProvider.isAdmin;
        final navigationItems = _getNavigationItems(isAdmin);
        final screens = _getScreens(isAdmin);

        return Scaffold(
          body: IndexedStack(
            index: navigationProvider.currentIndex,
            children: screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: navigationProvider.currentIndex,
            onTap: navigationProvider.setCurrentIndex,
            type: BottomNavigationBarType.fixed,
            items: navigationItems,
          ),
        );
      },
    );
  }

  /// Get navigation items based on user role
  List<BottomNavigationBarItem> _getNavigationItems(bool isAdmin) {
    final baseItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        activeIcon: Icon(Icons.home),
        label: 'Community',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.calendar_today),
        activeIcon: Icon(Icons.calendar_today),
        label: 'Liturgy',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.play_circle_outline),
        activeIcon: Icon(Icons.play_circle),
        label: 'Sermons',
      ),
    ];

    if (isAdmin) {
      return [
        ...baseItems,
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings_outlined),
          activeIcon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
      ];
    } else {
      return [
        ...baseItems,
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }
  }

  /// Get screens based on user role
  List<Widget> _getScreens(bool isAdmin) {
    final baseScreens = [
      const CommunityScreenWrapper(),
      const LiturgyScheduleWrapper(),
      const SermonsScreenWrapper(),
    ];

    if (isAdmin) {
      return [
        ...baseScreens,
        const AdminDashboardWrapper(),
      ];
    } else {
      return [
        ...baseScreens,
        const ProfileScreenWrapper(),
      ];
    }
  }
}

/// Wrapper for Community Screen with custom app bar
class CommunityScreenWrapper extends StatelessWidget {
  const CommunityScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Community'),
      body: CommunityScreenPlaceholder(), // Will be replaced with actual CommunityScreen
    );
  }
}

/// Wrapper for Liturgy Schedule with custom app bar
class LiturgyScheduleWrapper extends StatelessWidget {
  const LiturgyScheduleWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Liturgy Schedule'),
      body: LiturgyScheduleDetailPage(),
    );
  }
}

/// Wrapper for Sermons Screen with custom app bar
class SermonsScreenWrapper extends StatelessWidget {
  const SermonsScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Sermons'),
      body: SermonsScreen(),
    );
  }
}

/// Wrapper for Admin Dashboard with custom app bar
class AdminDashboardWrapper extends StatelessWidget {
  const AdminDashboardWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Admin Dashboard'),
      body: AdminDashboardScreen(),
    );
  }
}

/// Wrapper for Profile Screen with custom app bar
class ProfileScreenWrapper extends StatelessWidget {
  const ProfileScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Profile'),
      body: ProfileScreenPlaceholder(), // Will be replaced with actual ProfileScreen
    );
  }
}

/// Placeholder for Community Screen (to be implemented in future tasks)
class CommunityScreenPlaceholder extends StatelessWidget {
  const CommunityScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Community Screen',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming soon...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder for Sermons Screen (to be implemented in future tasks)
class SermonsScreenPlaceholder extends StatelessWidget {
  const SermonsScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_outline,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Sermons Screen',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming soon...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder for Admin Dashboard (to be implemented in future tasks)
class AdminDashboardPlaceholder extends StatelessWidget {
  const AdminDashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.admin_panel_settings,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Admin Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming soon...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder for Profile Screen (to be implemented in future tasks)
class ProfileScreenPlaceholder extends StatelessWidget {
  const ProfileScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Profile Screen',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming soon...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}