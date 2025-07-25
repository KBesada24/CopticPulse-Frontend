import 'package:flutter/foundation.dart';
import '../models/liturgy_event.dart';
import '../services/liturgy_service.dart';

/// Provider for managing liturgy events state
class LiturgyProvider with ChangeNotifier {
  final LiturgyService _liturgyService = LiturgyService();

  // State variables
  List<LiturgyEvent> _events = [];
  final Map<DateTime, List<LiturgyEvent>> _eventsByDate = {};
  bool _isLoading = false;
  String? _error;
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  // Getters
  List<LiturgyEvent> get events => _events;
  Map<DateTime, List<LiturgyEvent>> get eventsByDate => _eventsByDate;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;
  DateTime get focusedMonth => _focusedMonth;

  /// Get events for a specific date
  List<LiturgyEvent> getEventsForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return _eventsByDate[dateKey] ?? [];
  }

  /// Get events for the selected date
  List<LiturgyEvent> get selectedDateEvents => getEventsForDate(_selectedDate);

  /// Check if a date has events
  bool hasEventsForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return _eventsByDate[dateKey]?.isNotEmpty ?? false;
  }

  /// Set the selected date
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// Set the focused month
  void setFocusedMonth(DateTime month) {
    _focusedMonth = month;
    notifyListeners();
  }

  /// Load liturgy events for the current month
  Future<void> loadLiturgyEvents({bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    _setLoading(true);
    _setError(null);

    try {
      final events = await _liturgyService.getLiturgyEventsForMonth(_focusedMonth);
      _events = events;
      _groupEventsByDate(events);
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Load upcoming liturgy events
  Future<void> loadUpcomingEvents({bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    _setLoading(true);
    _setError(null);

    try {
      final events = await _liturgyService.getUpcomingLiturgyEvents();
      _events = events;
      _groupEventsByDate(events);
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Load events for a specific date range
  Future<void> loadEventsForDateRange(DateTime startDate, DateTime endDate, {bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    _setLoading(true);
    _setError(null);

    try {
      final events = await _liturgyService.getLiturgyEvents(
        startDate: startDate,
        endDate: endDate,
      );
      _events = events;
      _groupEventsByDate(events);
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh current data
  Future<void> refresh() async {
    await loadLiturgyEvents(refresh: true);
  }

  /// Load events when month changes
  Future<void> onMonthChanged(DateTime month) async {
    _focusedMonth = month;
    await loadLiturgyEvents(refresh: true);
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Group events by date for calendar display
  void _groupEventsByDate(List<LiturgyEvent> events) {
    _eventsByDate.clear();
    
    for (final event in events) {
      final dateKey = DateTime(
        event.dateTime.year,
        event.dateTime.month,
        event.dateTime.day,
      );
      
      if (_eventsByDate[dateKey] == null) {
        _eventsByDate[dateKey] = [];
      }
      
      _eventsByDate[dateKey]!.add(event);
    }

    // Sort events within each date by time
    for (final dateEvents in _eventsByDate.values) {
      dateEvents.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error state
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is LiturgyServiceException) {
      if (error.isNetworkError) {
        return 'Please check your internet connection and try again.';
      } else if (error.isAuthError) {
        return 'Please login again to view liturgy events.';
      } else if (error.isServerError) {
        return 'Server is temporarily unavailable. Please try again later.';
      }
      return error.message;
    }
    
    return 'An unexpected error occurred. Please try again.';
  }

  /// Get today's events
  List<LiturgyEvent> get todayEvents {
    final today = DateTime.now();
    return getEventsForDate(today);
  }

  /// Get upcoming events (next 7 days)
  List<LiturgyEvent> get upcomingEvents {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    
    return _events.where((event) {
      return event.dateTime.isAfter(now) && event.dateTime.isBefore(weekFromNow);
    }).toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  /// Get events for current month
  List<LiturgyEvent> get currentMonthEvents {
    final now = DateTime.now();
    return _events.where((event) {
      return event.dateTime.year == now.year && event.dateTime.month == now.month;
    }).toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }
}