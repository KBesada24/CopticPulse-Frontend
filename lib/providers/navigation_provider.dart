import 'package:flutter/foundation.dart';

/// Provider for managing navigation state throughout the app
class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int _previousIndex = 0;

  /// Current selected tab index
  int get currentIndex => _currentIndex;

  /// Previous selected tab index
  int get previousIndex => _previousIndex;

  /// Set the current tab index
  void setCurrentIndex(int index) {
    if (_currentIndex != index) {
      _previousIndex = _currentIndex;
      _currentIndex = index;
      notifyListeners();
    }
  }

  /// Navigate to a specific tab
  void navigateToTab(int index) {
    setCurrentIndex(index);
  }

  /// Navigate to Community tab (index 0)
  void navigateToCommunity() {
    setCurrentIndex(0);
  }

  /// Navigate to Liturgy tab (index 1)
  void navigateToLiturgy() {
    setCurrentIndex(1);
  }

  /// Navigate to Sermons tab (index 2)
  void navigateToSermons() {
    setCurrentIndex(2);
  }

  /// Navigate to Admin/Profile tab (index 3)
  void navigateToAdminOrProfile() {
    setCurrentIndex(3);
  }

  /// Reset navigation to initial state
  void reset() {
    _currentIndex = 0;
    _previousIndex = 0;
    notifyListeners();
  }

  /// Check if a specific tab is currently selected
  bool isTabSelected(int index) {
    return _currentIndex == index;
  }

  /// Get tab name by index
  String getTabName(int index, bool isAdmin) {
    switch (index) {
      case 0:
        return 'Community';
      case 1:
        return 'Liturgy';
      case 2:
        return 'Sermons';
      case 3:
        return isAdmin ? 'Admin' : 'Profile';
      default:
        return 'Unknown';
    }
  }
}