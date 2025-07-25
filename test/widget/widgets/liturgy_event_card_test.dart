import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coptic_pulse/widgets/liturgy_event_card.dart';
import 'package:coptic_pulse/models/liturgy_event.dart';

void main() {
  group('LiturgyEventCard', () {
    late LiturgyEvent testEvent;

    setUp(() {
      testEvent = LiturgyEvent(
        id: '1',
        title: 'Divine Liturgy',
        dateTime: DateTime(2024, 1, 15, 9, 0),
        location: 'Main Church',
        serviceType: 'Divine Liturgy',
        description: 'Sunday morning service',
        duration: const Duration(hours: 2),
      );
    });

    testWidgets('should display event information correctly', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: LiturgyEventCard(event: testEvent))),
      );

      // Assert
      expect(
        find.text('Divine Liturgy'),
        findsNWidgets(2),
      ); // Title and service type
      expect(find.text('Sunday morning service'), findsOneWidget);
      expect(find.text('Main Church'), findsOneWidget);
      expect(find.byIcon(Icons.church), findsOneWidget);
    });

    testWidgets('should display formatted date and time', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: LiturgyEventCard(event: testEvent))),
      );

      // Assert
      expect(find.textContaining('9:00 AM'), findsOneWidget);
      expect(find.textContaining('(2h)'), findsOneWidget); // Duration
    });

    testWidgets('should show TODAY indicator for today events', (
      WidgetTester tester,
    ) async {
      // Arrange
      final todayEvent = LiturgyEvent(
        id: '1',
        title: 'Today Event',
        dateTime: DateTime.now(),
        location: 'Main Church',
        serviceType: 'Divine Liturgy',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: LiturgyEventCard(event: todayEvent))),
      );

      // Assert
      expect(find.text('TODAY'), findsOneWidget);
    });

    testWidgets('should show UPCOMING indicator for upcoming events', (
      WidgetTester tester,
    ) async {
      // Arrange
      final upcomingEvent = LiturgyEvent(
        id: '1',
        title: 'Upcoming Event',
        dateTime: DateTime.now().add(const Duration(days: 3)),
        location: 'Main Church',
        serviceType: 'Divine Liturgy',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LiturgyEventCard(event: upcomingEvent)),
        ),
      );

      // Assert
      expect(find.text('UPCOMING'), findsOneWidget);
    });

    testWidgets('should handle tap events', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;
      void onTap() => tapped = true;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiturgyEventCard(event: testEvent, onTap: onTap),
          ),
        ),
      );

      await tester.tap(find.byType(LiturgyEventCard));
      await tester.pumpAndSettle();

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('should display compact version correctly', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiturgyEventCard(event: testEvent, compact: true),
          ),
        ),
      );

      // Assert
      expect(find.text('Divine Liturgy'), findsOneWidget);
      expect(find.textContaining('9:00 AM • Main Church'), findsOneWidget);
      expect(find.byIcon(Icons.church), findsOneWidget);

      // Description should not be shown in compact mode
      expect(find.text('Sunday morning service'), findsNothing);
    });

    testWidgets('should hide date when showDate is false', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiturgyEventCard(event: testEvent, showDate: false),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.calendar_today), findsNothing);
    });

    testWidgets('should handle event without description', (
      WidgetTester tester,
    ) async {
      // Arrange
      final eventWithoutDescription = LiturgyEvent(
        id: '1',
        title: 'Simple Event',
        dateTime: DateTime(2024, 1, 15, 9, 0),
        location: 'Main Church',
        serviceType: 'Divine Liturgy',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiturgyEventCard(event: eventWithoutDescription),
          ),
        ),
      );

      // Assert
      expect(find.text('Simple Event'), findsOneWidget);
      expect(find.text('Divine Liturgy'), findsOneWidget);
      expect(find.text('Main Church'), findsOneWidget);
    });

    testWidgets('should handle event without duration', (
      WidgetTester tester,
    ) async {
      // Arrange
      final eventWithoutDuration = LiturgyEvent(
        id: '1',
        title: 'No Duration Event',
        dateTime: DateTime(2024, 1, 15, 9, 0),
        location: 'Main Church',
        serviceType: 'Divine Liturgy',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LiturgyEventCard(event: eventWithoutDuration)),
        ),
      );

      // Assert
      expect(find.text('9:00 AM'), findsOneWidget);
      expect(find.textContaining('('), findsNothing); // No duration parentheses
    });
  });

  group('LiturgyEventsList', () {
    testWidgets('should display list of events', (WidgetTester tester) async {
      // Arrange
      final events = [
        LiturgyEvent(
          id: '1',
          title: 'Event 1',
          dateTime: DateTime(2024, 1, 15, 9, 0),
          location: 'Church 1',
          serviceType: 'Divine Liturgy',
        ),
        LiturgyEvent(
          id: '2',
          title: 'Event 2',
          dateTime: DateTime(2024, 1, 15, 18, 0),
          location: 'Church 2',
          serviceType: 'Vespers',
        ),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: LiturgyEventsList(events: events))),
      );

      // Assert
      expect(find.text('Event 1'), findsOneWidget);
      expect(find.text('Event 2'), findsOneWidget);
      expect(find.byType(LiturgyEventCard), findsNWidgets(2));
    });

    testWidgets('should display empty message when no events', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiturgyEventsList(
              events: const [],
              emptyMessage: 'No events found',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('No events found'), findsOneWidget);
      expect(find.byIcon(Icons.event_busy), findsOneWidget);
    });

    testWidgets('should display default empty message', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: LiturgyEventsList(events: const []))),
      );

      // Assert
      expect(find.text('No liturgy events scheduled'), findsOneWidget);
    });

    testWidgets('should handle tap on event card', (WidgetTester tester) async {
      // Arrange
      final events = [
        LiturgyEvent(
          id: '1',
          title: 'Tappable Event',
          dateTime: DateTime(2024, 1, 15, 9, 0),
          location: 'Main Church',
          serviceType: 'Divine Liturgy',
        ),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: LiturgyEventsList(events: events))),
      );

      await tester.tap(find.byType(LiturgyEventCard));
      await tester.pumpAndSettle();

      // Assert - Modal should appear
      expect(find.byType(LiturgyEventDetailsModal), findsOneWidget);
    });
  });

  group('LiturgyEventDetailsModal', () {
    late LiturgyEvent testEvent;

    setUp(() {
      testEvent = LiturgyEvent(
        id: '1',
        title: 'Detailed Event',
        dateTime: DateTime(2024, 1, 15, 9, 0),
        location: 'Main Church',
        serviceType: 'Divine Liturgy',
        description: 'Detailed description of the event',
        duration: const Duration(hours: 2),
      );
    });

    testWidgets('should display event details in modal', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LiturgyEventDetailsModal(event: testEvent)),
        ),
      );

      // Assert
      expect(find.text('Detailed Event'), findsOneWidget);
      expect(find.text('Divine Liturgy'), findsOneWidget);
      expect(find.text('Main Church'), findsOneWidget);
      expect(find.text('Detailed description of the event'), findsOneWidget);
      expect(find.byIcon(Icons.church), findsOneWidget);
    });

    testWidgets('should display formatted date and time details', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LiturgyEventDetailsModal(event: testEvent)),
        ),
      );

      // Assert
      expect(find.text('Date'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);
      expect(find.text('Location'), findsOneWidget);
      expect(find.textContaining('9:00 AM'), findsOneWidget);
      expect(find.textContaining('(2h)'), findsOneWidget);
    });

    testWidgets('should handle event without description', (
      WidgetTester tester,
    ) async {
      // Arrange
      final eventWithoutDescription = LiturgyEvent(
        id: '1',
        title: 'Simple Event',
        dateTime: DateTime(2024, 1, 15, 9, 0),
        location: 'Main Church',
        serviceType: 'Divine Liturgy',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiturgyEventDetailsModal(event: eventWithoutDescription),
          ),
        ),
      );

      // Assert
      expect(find.text('Simple Event'), findsOneWidget);
      expect(find.text('Description'), findsNothing);
    });
  });
}
