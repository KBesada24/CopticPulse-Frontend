import 'package:flutter_test/flutter_test.dart';
import 'package:coptic_pulse/providers/navigation_provider.dart';

void main() {
  group('NavigationProvider', () {
    late NavigationProvider navigationProvider;

    setUp(() {
      navigationProvider = NavigationProvider();
    });

    test('initial state should be correct', () {
      expect(navigationProvider.currentIndex, 0);
      expect(navigationProvider.previousIndex, 0);
    });

    test('setCurrentIndex should update current index and notify listeners', () {
      bool notified = false;
      navigationProvider.addListener(() {
        notified = true;
      });

      navigationProvider.setCurrentIndex(2);

      expect(navigationProvider.currentIndex, 2);
      expect(navigationProvider.previousIndex, 0);
      expect(notified, true);
    });

    test('setCurrentIndex with same index should not notify listeners', () {
      bool notified = false;
      navigationProvider.addListener(() {
        notified = true;
      });

      navigationProvider.setCurrentIndex(0); // Same as initial

      expect(navigationProvider.currentIndex, 0);
      expect(navigationProvider.previousIndex, 0);
      expect(notified, false);
    });

    test('navigateToTab should work correctly', () {
      navigationProvider.navigateToTab(3);
      expect(navigationProvider.currentIndex, 3);
      expect(navigationProvider.previousIndex, 0);
    });

    test('navigation helper methods should work correctly', () {
      navigationProvider.navigateToCommunity();
      expect(navigationProvider.currentIndex, 0);

      navigationProvider.navigateToLiturgy();
      expect(navigationProvider.currentIndex, 1);
      expect(navigationProvider.previousIndex, 0);

      navigationProvider.navigateToSermons();
      expect(navigationProvider.currentIndex, 2);
      expect(navigationProvider.previousIndex, 1);

      navigationProvider.navigateToAdminOrProfile();
      expect(navigationProvider.currentIndex, 3);
      expect(navigationProvider.previousIndex, 2);
    });

    test('isTabSelected should return correct values', () {
      expect(navigationProvider.isTabSelected(0), true);
      expect(navigationProvider.isTabSelected(1), false);

      navigationProvider.setCurrentIndex(2);
      expect(navigationProvider.isTabSelected(0), false);
      expect(navigationProvider.isTabSelected(2), true);
    });

    test('getTabName should return correct names', () {
      expect(navigationProvider.getTabName(0, false), 'Community');
      expect(navigationProvider.getTabName(1, false), 'Liturgy');
      expect(navigationProvider.getTabName(2, false), 'Sermons');
      expect(navigationProvider.getTabName(3, false), 'Profile');
      expect(navigationProvider.getTabName(3, true), 'Admin');
      expect(navigationProvider.getTabName(99, false), 'Unknown');
    });

    test('reset should restore initial state', () {
      navigationProvider.setCurrentIndex(3);
      expect(navigationProvider.currentIndex, 3);

      navigationProvider.reset();
      expect(navigationProvider.currentIndex, 0);
      expect(navigationProvider.previousIndex, 0);
    });
  });
}