/// LiturgyEvent model for liturgy schedule data
class LiturgyEvent {
  final String id;
  final String title;
  final DateTime dateTime;
  final String location;
  final String serviceType;
  final String? description;
  final Duration? duration;

  const LiturgyEvent({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.location,
    required this.serviceType,
    this.description,
    this.duration,
  });

  /// Creates a LiturgyEvent from JSON data
  factory LiturgyEvent.fromJson(Map<String, dynamic> json) {
    return LiturgyEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      location: json['location'] as String,
      serviceType: json['serviceType'] as String,
      description: json['description'] as String?,
      duration: json['duration'] != null
          ? Duration(minutes: json['duration'] as int)
          : null,
    );
  }

  /// Converts LiturgyEvent to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'location': location,
      'serviceType': serviceType,
      if (description != null) 'description': description,
      if (duration != null) 'duration': duration!.inMinutes,
    };
  }

  /// Creates a copy of this LiturgyEvent with updated fields
  LiturgyEvent copyWith({
    String? id,
    String? title,
    DateTime? dateTime,
    String? location,
    String? serviceType,
    String? description,
    Duration? duration,
  }) {
    return LiturgyEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      serviceType: serviceType ?? this.serviceType,
      description: description ?? this.description,
      duration: duration ?? this.duration,
    );
  }

  /// Returns formatted date string
  String get formattedDate {
    return '${_getWeekday(dateTime.weekday)}, ${_getMonth(dateTime.month)} ${dateTime.day}, ${dateTime.year}';
  }

  /// Returns formatted time string
  String get formattedTime {
    final hour = dateTime.hour == 0 ? 12 : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Returns formatted duration string
  String? get formattedDuration {
    if (duration == null) return null;
    final hours = duration!.inHours;
    final minutes = duration!.inMinutes % 60;
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }

  /// Returns whether the event is today
  bool get isToday {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// Returns whether the event is in the past
  bool get isPast {
    return dateTime.isBefore(DateTime.now());
  }

  /// Returns whether the event is upcoming (within next 7 days)
  bool get isUpcoming {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    return dateTime.isAfter(now) && dateTime.isBefore(weekFromNow);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LiturgyEvent &&
        other.id == id &&
        other.title == title &&
        other.dateTime == dateTime &&
        other.location == location &&
        other.serviceType == serviceType &&
        other.description == description &&
        other.duration == duration;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      dateTime,
      location,
      serviceType,
      description,
      duration,
    );
  }

  @override
  String toString() {
    return 'LiturgyEvent(id: $id, title: $title, dateTime: $dateTime, location: $location, serviceType: $serviceType)';
  }

  /// Helper method to get weekday name
  String _getWeekday(int weekday) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return weekdays[weekday - 1];
  }

  /// Helper method to get month name
  String _getMonth(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}