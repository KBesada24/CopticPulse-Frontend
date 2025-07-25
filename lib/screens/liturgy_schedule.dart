import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../models/liturgy_event.dart';
import '../providers/liturgy_provider.dart';
import '../widgets/liturgy_event_card.dart';

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

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LiturgyProvider>().loadLiturgyEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liturgy Schedule'),
        backgroundColor: const Color.fromRGBO(253, 250, 245, 1.0),
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Consumer<LiturgyProvider>(
        builder: (context, liturgyProvider, child) {
          return RefreshIndicator(
            onRefresh: () => liturgyProvider.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
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
                      child: TableCalendar<LiturgyEvent>(
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
                          liturgyProvider.setSelectedDate(selectedDay);
                        },
                        onFormatChanged: (format) {
                          setState(() => _calendarFormat = format);
                        },
                        onPageChanged: (focusedDay) {
                          setState(() => _focusedDay = focusedDay);
                          liturgyProvider.onMonthChanged(focusedDay);
                        },
                        eventLoader: (day) => liturgyProvider.getEventsForDate(day),
                        
                        // Custom styling to match your app
                        headerStyle: const HeaderStyle(
                          titleCentered: true,
                          formatButtonVisible: true,
                          formatButtonDecoration: BoxDecoration(
                            color: Color(0xFF8B0000),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          formatButtonTextStyle: TextStyle(color: Colors.white),
                        ),
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: const Color.fromRGBO(253, 250, 245, 1.0),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF8B0000)),
                          ),
                          selectedDecoration: const BoxDecoration(
                            color: Color(0xFF8B0000),
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: const BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                          markersMaxCount: 3,
                          markerSize: 6,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Error handling
                    if (liturgyProvider.error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade600),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                liturgyProvider.error!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                liturgyProvider.clearError();
                                liturgyProvider.refresh();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // Loading indicator
                    if (liturgyProvider.isLoading) ...[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                            color: Color(0xFF8B0000),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Selected date events
                      if (_selectedDay != null) ...[
                        Text(
                          'Events for ${_formatSelectedDate(_selectedDay!)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        LiturgyEventsList(
                          events: liturgyProvider.selectedDateEvents,
                          emptyMessage: 'No liturgy events scheduled for this date',
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Format the selected date for display
  String _formatSelectedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);
    
    if (selectedDate == today) {
      return 'Today';
    } else if (selectedDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else if (selectedDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }
}