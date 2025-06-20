import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // Add this import

class LiturgyScheduleDetailPage extends StatefulWidget {
  const LiturgyScheduleDetailPage({super.key});

  @override
  State<LiturgyScheduleDetailPage> createState() => _LiturgyScheduleDetailPageState();
}

class _LiturgyScheduleDetailPageState extends State<LiturgyScheduleDetailPage> {
  // Calendar state variables
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Optional: Events data
  final Map<DateTime, List<String>> _events = {
    DateTime.utc(DateTime.now().year, DateTime.now().month, 15): ['Special Mass'],
    DateTime.utc(DateTime.now().year, DateTime.now().month, 20): ['Baptism Service'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liturgy Schedule'),
        backgroundColor: const Color.fromRGBO(253, 250, 245, 1.0),
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Liturgy Schedule',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'All schedules are subject to change. Please check back regularly for updates.',
            ),
            const SizedBox(height: 20),
            
            // Calendar Container with styling
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  // Handle date selection
                  print("Selected date: $selectedDay");
                  if (_events[selectedDay] != null) {
                    print("Events: ${_events[selectedDay]!.join(', ')}");
                  }
                },
                onFormatChanged: (format) {
                  setState(() => _calendarFormat = format);
                },
                onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                eventLoader: (day) => _events[day] ?? [],
                
                // Custom styling to match your app
                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: true,
                  formatButtonDecoration: BoxDecoration(
                    color: Colors.brown,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  formatButtonTextStyle: TextStyle(color: Colors.white),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: const Color.fromRGBO(253, 250, 245, 1.0),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.brown),
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.brown,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            
            // Display selected date/events
            const SizedBox(height: 20),
            if (_selectedDay != null) ...[
              Text(
                'Selected Date: ${_selectedDay!.toString().split(' ')[0]}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (_events[_selectedDay] != null) ...[
                const SizedBox(height: 10),
                Text('Events: ${_events[_selectedDay]!.join(', ')}'),
              ],
            ],
          ],
        ),
      ),
    );
  }
}