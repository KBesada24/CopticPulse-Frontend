import 'package:flutter_test/flutter_test.dart';
import 'package:coptic_pulse/models/liturgy_event.dart';

void main() {
  group('LiturgyEvent Model Tests', () {
    final testDateTime = DateTime(2024, 3, 15, 9, 30); // Friday, March 15, 2024 at 9:30 AM
    final testDuration = const Duration(hours: 2, minutes: 30);

    final testEventJson = {
      'id': 'event123',
      'title': 'Divine Liturgy',
      'dateTime': testDateTime.toIso8601String(),
      'location': 'St. Mark Church',
      'serviceType': 'Divine Liturgy',
      'description': 'Weekly Divine Liturgy service',
      'duration': testDuration.inMinutes,
    };

    final testEventJsonMinimal = {
      'id': 'event456',
      'title': 'Vespers',
      'dateTime': testDateTime.toIso8601String(),
      'location': 'St. Mary Church',
      'serviceType': 'Vespers',
    };

    test('should create LiturgyEvent from JSON correctly', () {
      final event = LiturgyEvent.fromJson(testEventJson);

      expect(event.id, equals('event123'));
      expect(event.title, equals('Divine Liturgy'));
      expect(event.dateTime, equals(testDateTime));
      expect(event.location, equals('St. Mark Church'));
      expect(event.serviceType, equals('Divine Liturgy'));
      expect(event.description, equals('Weekly Divine Liturgy service'));
      expect(event.duration, equals(testDuration));
    });

    test('should create LiturgyEvent from minimal JSON correctly', () {
      final event = LiturgyEvent.fromJson(testEventJsonMinimal);

      expect(event.id, equals('event456'));
      expect(event.title, equals('Vespers'));
      expect(event.dateTime, equals(testDateTime));
      expect(event.location, equals('St. Mary Church'));
      expect(event.serviceType, equals('Vespers'));
      expect(event.description, isNull);
      expect(event.duration, isNull);
    });

    test('should convert LiturgyEvent to JSON correctly', () {
      final event = LiturgyEvent(
        id: 'event123',
        title: 'Divine Liturgy',
        dateTime: testDateTime,
        location: 'St. Mark Church',
        serviceType: 'Divine Liturgy',
        description: 'Weekly Divine Liturgy service',
        duration: testDuration,
      );

      final json = event.toJson();

      expect(json['id'], equals('event123'));
      expect(json['title'], equals('Divine Liturgy'));
      expect(json['dateTime'], equals(testDateTime.toIso8601String()));
      expect(json['location'], equals('St. Mark Church'));
      expect(json['serviceType'], equals('Divine Liturgy'));
      expect(json['description'], equals('Weekly Divine Liturgy service'));
      expect(json['duration'], equals(testDuration.inMinutes));
    });

    test('should convert LiturgyEvent without optional fields to JSON correctly', () {
      final event = LiturgyEvent(
        id: 'event456',
        title: 'Vespers',
        dateTime: testDateTime,
        location: 'St. Mary Church',
        serviceType: 'Vespers',
      );

      final json = event.toJson();

      expect(json['id'], equals('event456'));
      expect(json['title'], equals('Vespers'));
      expect(json['dateTime'], equals(testDateTime.toIso8601String()));
      expect(json['location'], equals('St. Mary Church'));
      expect(json['serviceType'], equals('Vespers'));
      expect(json.containsKey('description'), isFalse);
      expect(json.containsKey('duration'), isFalse);
    });

    test('should create copy with updated fields', () {
      final originalEvent = LiturgyEvent(
        id: 'event123',
        title: 'Original Title',
        dateTime: testDateTime,
        location: 'Original Location',
        serviceType: 'Original Service',
      );

      final newDateTime = DateTime(2024, 4, 20, 10, 0);
      final newDuration = const Duration(hours: 1, minutes: 45);

      final updatedEvent = originalEvent.copyWith(
        title: 'Updated Title',
        dateTime: newDateTime,
        description: 'Updated description',
        duration: newDuration,
      );

      expect(updatedEvent.id, equals('event123'));
      expect(updatedEvent.title, equals('Updated Title'));
      expect(updatedEvent.dateTime, equals(newDateTime));
      expect(updatedEvent.location, equals('Original Location'));
      expect(updatedEvent.serviceType, equals('Original Service'));
      expect(updatedEvent.description, equals('Updated description'));
      expect(updatedEvent.duration, equals(newDuration));
    });

    test('should format date correctly', () {
      final event = LiturgyEvent(
        id: 'event123',
        title: 'Test Event',
        dateTime: DateTime(2024, 3, 15), // Friday, March 15, 2024
        location: 'Test Location',
        serviceType: 'Test Service',
      );

      expect(event.formattedDate, equals('Friday, March 15, 2024'));
    });

    test('should format time correctly', () {
      // Test AM time
      final morningEvent = LiturgyEvent(
        id: 'event1',
        title: 'Morning Service',
        dateTime: DateTime(2024, 3, 15, 9, 30), // 9:30 AM
        location: 'Test Location',
        serviceType: 'Test Service',
      );

      expect(morningEvent.formattedTime, equals('9:30 AM'));

      // Test PM time
      final eveningEvent = LiturgyEvent(
        id: 'event2',
        title: 'Evening Service',
        dateTime: DateTime(2024, 3, 15, 18, 45), // 6:45 PM
        location: 'Test Location',
        serviceType: 'Test Service',
      );

      expect(eveningEvent.formattedTime, equals('6:45 PM'));

      // Test noon
      final noonEvent = LiturgyEvent(
        id: 'event3',
        title: 'Noon Service',
        dateTime: DateTime(2024, 3, 15, 12, 0), // 12:00 PM
        location: 'Test Location',
        serviceType: 'Test Service',
      );

      expect(noonEvent.formattedTime, equals('12:00 PM'));

      // Test midnight
      final midnightEvent = LiturgyEvent(
        id: 'event4',
        title: 'Midnight Service',
        dateTime: DateTime(2024, 3, 15, 0, 0), // 12:00 AM
        location: 'Test Location',
        serviceType: 'Test Service',
      );

      expect(midnightEvent.formattedTime, equals('12:00 AM'));
    });

    test('should format duration correctly', () {
      // Test hours and minutes
      final event1 = LiturgyEvent(
        id: 'event1',
        title: 'Test Event',
        dateTime: testDateTime,
        location: 'Test Location',
        serviceType: 'Test Service',
        duration: const Duration(hours: 2, minutes: 30),
      );

      expect(event1.formattedDuration, equals('2h 30m'));

      // Test hours only
      final event2 = LiturgyEvent(
        id: 'event2',
        title: 'Test Event',
        dateTime: testDateTime,
        location: 'Test Location',
        serviceType: 'Test Service',
        duration: const Duration(hours: 1),
      );

      expect(event2.formattedDuration, equals('1h'));

      // Test minutes only
      final event3 = LiturgyEvent(
        id: 'event3',
        title: 'Test Event',
        dateTime: testDateTime,
        location: 'Test Location',
        serviceType: 'Test Service',
        duration: const Duration(minutes: 45),
      );

      expect(event3.formattedDuration, equals('45m'));

      // Test no duration
      final event4 = LiturgyEvent(
        id: 'event4',
        title: 'Test Event',
        dateTime: testDateTime,
        location: 'Test Location',
        serviceType: 'Test Service',
      );

      expect(event4.formattedDuration, isNull);
    });

    test('should correctly identify if event is today', () {
      final now = DateTime.now();
      final todayEvent = LiturgyEvent(
        id: 'event1',
        title: 'Today Event',
        dateTime: DateTime(now.year, now.month, now.day, 10, 0),
        location: 'Test Location',
        serviceType: 'Test Service',
      );

      final yesterdayEvent = LiturgyEvent(
        id: 'event2',
        title: 'Yesterday Event',
        dateTime: DateTime(now.year, now.month, now.day - 1, 10, 0),
        location: 'Test Location',
        serviceType: 'Test Service',
      );

      expect(todayEvent.isToday, isTrue);
      expect(yesterdayEvent.isToday, isFalse);
    });

    test('should correctly identify if event is in the past', () {
      final now = DateTime.now();
      final pastEvent = LiturgyEvent(
        id: 'event1',
        title: 'Past Event',
        dateTime: now.subtract(const Duration(hours: 1)),
        location: 'Test Location',
        serviceType: 'Test Service',
      );

      final futureEvent = LiturgyEvent(
        id: 'event2',
        title: 'Future Event',
        dateTime: now.add(const Duration(hours: 1)),
        location: 'Test Location',
        serviceType: 'Test Service',
      );

      expect(pastEvent.isPast, isTrue);
      expect(futureEvent.isPast, isFalse);
    });

    test('should correctly identify if event is upcoming', () {
      final now = DateTime.now();
      final upcomingEvent = LiturgyEvent(
        id: 'event1',
        title: 'Upcoming Event',
        dateTime: now.add(const Duration(days: 3)),
        location: 'Test Location',
        serviceType: 'Test Service',
      );

      final farFutureEvent = LiturgyEvent(
        id: 'event2',
        title: 'Far Future Event',
        dateTime: now.add(const Duration(days: 10)),
        location: 'Test Location',
        serviceType: 'Test Service',
      );

      final pastEvent = LiturgyEvent(
        id: 'event3',
        title: 'Past Event',
        dateTime: now.subtract(const Duration(days: 1)),
        location: 'Test Location',
        serviceType: 'Test Service',
      );

      expect(upcomingEvent.isUpcoming, isTrue);
      expect(farFutureEvent.isUpcoming, isFalse);
      expect(pastEvent.isUpcoming, isFalse);
    });

    test('should implement equality correctly', () {
      final event1 = LiturgyEvent(
        id: 'event123',
        title: 'Test Event',
        dateTime: testDateTime,
        location: 'Test Location',
        serviceType: 'Test Service',
        description: 'Test description',
        duration: testDuration,
      );

      final event2 = LiturgyEvent(
        id: 'event123',
        title: 'Test Event',
        dateTime: testDateTime,
        location: 'Test Location',
        serviceType: 'Test Service',
        description: 'Test description',
        duration: testDuration,
      );

      final event3 = LiturgyEvent(
        id: 'event456',
        title: 'Different Event',
        dateTime: testDateTime,
        location: 'Different Location',
        serviceType: 'Different Service',
      );

      expect(event1, equals(event2));
      expect(event1, isNot(equals(event3)));
      expect(event1.hashCode, equals(event2.hashCode));
    });

    test('should have proper toString implementation', () {
      final event = LiturgyEvent(
        id: 'event123',
        title: 'Test Event',
        dateTime: testDateTime,
        location: 'Test Location',
        serviceType: 'Test Service',
      );

      final string = event.toString();
      expect(string, contains('event123'));
      expect(string, contains('Test Event'));
      expect(string, contains('Test Location'));
      expect(string, contains('Test Service'));
    });
  });
}