// ignore_for_file: unused_import, unused_local_variable

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:coptic_pulse/providers/liturgy_provider.dart';
import 'package:coptic_pulse/services/liturgy_service.dart';
import 'package:coptic_pulse/models/liturgy_event.dart';

import 'liturgy_provider_test.mocks.dart';

@GenerateMocks([LiturgyService])
void main() {
  group('LiturgyProvider', () {
    late LiturgyProvider liturgyProvider;
    late MockLiturgyService mockLiturgyService;

    setUp(() {
      mockLiturgyService = MockLiturgyService();
      liturgyProvider = LiturgyProvider();
      // We would need dependency injection to properly test with mocks
    });

    group('Initial State', () {
      test('should have correct initial values', () {
        expect(liturgyProvider.events, isEmpty);
        expect(liturgyProvider.eventsByDate, isEmpty);
        expect(liturgyProvider.isLoading, isFalse);
        expect(liturgyProvider.error, isNull);
        expect(liturgyProvider.selectedDate.day, equals(DateTime.now().day));
        expect(liturgyProvider.focusedMonth.month, equals(DateTime.now().month));
      });
    });

    group('Date Management', () {
      test('should update selected date', () {
        // Arrange
        final newDate = DateTime(2024, 1, 15);
        bool notified = false;
        liturgyProvider.addListener(() => notified = true);

        // Act
        liturgyProvider.setSelectedDate(newDate);

        // Assert
        expect(liturgyProvider.selectedDate, equals(newDate));
        expect(notified, isTrue);
      });

      test('should update focused month', () {
        // Arrange
        final newMonth = DateTime(2024, 2, 1);
        bool notified = false;
        liturgyProvider.addListener(() => notified = true);

        // Act
        liturgyProvider.setFocusedMonth(newMonth);

        // Assert
        expect(liturgyProvider.focusedMonth, equals(newMonth));
        expect(notified, isTrue);
      });
    });

    group('Event Filtering', () {
      test('should return events for specific date', () {
        // Arrange
        final testDate = DateTime(2024, 1, 15);
        final event1 = LiturgyEvent(
          id: '1',
          title: 'Morning Liturgy',
          dateTime: DateTime(2024, 1, 15, 9, 0),
          location: 'Main Church',
          serviceType: 'Divine Liturgy',
        );
        final event2 = LiturgyEvent(
          id: '2',
          title: 'Evening Prayer',
          dateTime: DateTime(2024, 1, 15, 18, 0),
          location: 'Main Church',
          serviceType: 'Vespers',
        );
        final event3 = LiturgyEvent(
          id: '3',
          title: 'Different Day',
          dateTime: DateTime(2024, 1, 16, 9, 0),
          location: 'Main Church',
          serviceType: 'Divine Liturgy',
        );

        // Simulate loading events
        liturgyProvider.events.addAll([event1, event2, event3]);
        liturgyProvider.eventsByDate[DateTime(2024, 1, 15)] = [event1, event2];
        liturgyProvider.eventsByDate[DateTime(2024, 1, 16)] = [event3];

        // Act
        final eventsForDate = liturgyProvider.getEventsForDate(testDate);

        // Assert
        expect(eventsForDate.length, equals(2));
        expect(eventsForDate.contains(event1), isTrue);
        expect(eventsForDate.contains(event2), isTrue);
        expect(eventsForDate.contains(event3), isFalse);
      });

      test('should return empty list for date with no events', () {
        // Arrange
        final testDate = DateTime(2024, 1, 20);

        // Act
        final eventsForDate = liturgyProvider.getEventsForDate(testDate);

        // Assert
        expect(eventsForDate, isEmpty);
      });

      test('should check if date has events', () {
        // Arrange
        final dateWithEvents = DateTime(2024, 1, 15);
        final dateWithoutEvents = DateTime(2024, 1, 20);
        
        liturgyProvider.eventsByDate[dateWithEvents] = [
          LiturgyEvent(
            id: '1',
            title: 'Test Event',
            dateTime: dateWithEvents,
            location: 'Test Location',
            serviceType: 'Test Service',
          ),
        ];

        // Act & Assert
        expect(liturgyProvider.hasEventsForDate(dateWithEvents), isTrue);
        expect(liturgyProvider.hasEventsForDate(dateWithoutEvents), isFalse);
      });
    });

    group('Error Handling', () {
      test('should have clearError method', () {
        // Act & Assert
        expect(() => liturgyProvider.clearError(), returnsNormally);
      });
    });

    group('Event Categorization', () {
      test('should return today events', () {
        // Arrange
        final today = DateTime.now();
        final todayEvent = LiturgyEvent(
          id: '1',
          title: 'Today Event',
          dateTime: today,
          location: 'Main Church',
          serviceType: 'Divine Liturgy',
        );
        final tomorrowEvent = LiturgyEvent(
          id: '2',
          title: 'Tomorrow Event',
          dateTime: today.add(const Duration(days: 1)),
          location: 'Main Church',
          serviceType: 'Vespers',
        );

        liturgyProvider.events.addAll([todayEvent, tomorrowEvent]);
        final todayKey = DateTime(today.year, today.month, today.day);
        liturgyProvider.eventsByDate[todayKey] = [todayEvent];

        // Act
        final todayEvents = liturgyProvider.todayEvents;

        // Assert
        expect(todayEvents.length, equals(1));
        expect(todayEvents.first.id, equals('1'));
      });

      test('should return upcoming events within 7 days', () {
        // Arrange
        final now = DateTime.now();
        final upcomingEvent = LiturgyEvent(
          id: '1',
          title: 'Upcoming Event',
          dateTime: now.add(const Duration(days: 3)),
          location: 'Main Church',
          serviceType: 'Divine Liturgy',
        );
        final farFutureEvent = LiturgyEvent(
          id: '2',
          title: 'Far Future Event',
          dateTime: now.add(const Duration(days: 10)),
          location: 'Main Church',
          serviceType: 'Vespers',
        );

        liturgyProvider.events.addAll([upcomingEvent, farFutureEvent]);

        // Act
        final upcomingEvents = liturgyProvider.upcomingEvents;

        // Assert
        expect(upcomingEvents.length, equals(1));
        expect(upcomingEvents.first.id, equals('1'));
      });

      test('should return current month events', () {
        // Arrange
        final now = DateTime.now();
        final currentMonthEvent = LiturgyEvent(
          id: '1',
          title: 'Current Month Event',
          dateTime: DateTime(now.year, now.month, 15),
          location: 'Main Church',
          serviceType: 'Divine Liturgy',
        );
        final nextMonthEvent = LiturgyEvent(
          id: '2',
          title: 'Next Month Event',
          dateTime: DateTime(now.year, now.month + 1, 15),
          location: 'Main Church',
          serviceType: 'Vespers',
        );

        liturgyProvider.events.addAll([currentMonthEvent, nextMonthEvent]);

        // Act
        final currentMonthEvents = liturgyProvider.currentMonthEvents;

        // Assert
        expect(currentMonthEvents.length, equals(1));
        expect(currentMonthEvents.first.id, equals('1'));
      });
    });

    group('Selected Date Events', () {
      test('should return events for selected date', () {
        // Arrange
        final selectedDate = DateTime(2024, 1, 15);
        final event = LiturgyEvent(
          id: '1',
          title: 'Selected Date Event',
          dateTime: selectedDate,
          location: 'Main Church',
          serviceType: 'Divine Liturgy',
        );

        liturgyProvider.setSelectedDate(selectedDate);
        liturgyProvider.eventsByDate[DateTime(2024, 1, 15)] = [event];

        // Act
        final selectedDateEvents = liturgyProvider.selectedDateEvents;

        // Assert
        expect(selectedDateEvents.length, equals(1));
        expect(selectedDateEvents.first.id, equals('1'));
      });
    });
  });
}