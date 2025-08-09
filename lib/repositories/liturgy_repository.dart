import '../models/liturgy_event.dart';
import '../database/database_helper.dart';
import 'base_repository.dart';

/// Repository for managing liturgy event data with offline caching
class LiturgyRepository extends BaseRepository<LiturgyEvent> {
  LiturgyRepository({super.databaseHelper});

  @override
  String get tableName => DatabaseHelper.liturgyEventsTable;

  @override
  String get cacheKeyPrefix => 'liturgy_';

  @override
  Map<String, dynamic> toDatabase(LiturgyEvent model) {
    return {
      'id': model.id,
      'title': model.title,
      'dateTime': model.dateTime.toIso8601String(),
      'location': model.location,
      'serviceType': model.serviceType,
      'description': model.description,
      'duration': model.duration?.inMinutes,
    };
  }

  @override
  LiturgyEvent fromDatabase(Map<String, dynamic> map) {
    return LiturgyEvent(
      id: map['id'] as String,
      title: map['title'] as String,
      dateTime: DateTime.parse(map['dateTime'] as String),
      location: map['location'] as String,
      serviceType: map['serviceType'] as String,
      description: map['description'] as String?,
      duration:
          map['duration'] != null
              ? Duration(minutes: map['duration'] as int)
              : null,
    );
  }

  /// Get cached upcoming liturgy events
  Future<List<LiturgyEvent>> getCachedUpcomingEvents() async {
    final db = await databaseHelper.database;
    final now = DateTime.now().toIso8601String();

    final maps = await db.query(
      tableName,
      where: 'dateTime >= ?',
      whereArgs: [now],
      orderBy: 'dateTime ASC',
    );

    return maps.map((map) => fromDatabase(map)).toList();
  }

  /// Get cached liturgy events for a specific date range
  Future<List<LiturgyEvent>> getCachedEventsInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await databaseHelper.database;

    final maps = await db.query(
      tableName,
      where: 'dateTime >= ? AND dateTime <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'dateTime ASC',
    );

    return maps.map((map) => fromDatabase(map)).toList();
  }

  /// Get cached liturgy events for a specific month
  Future<List<LiturgyEvent>> getCachedEventsForMonth({
    required int year,
    required int month,
  }) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    return getCachedEventsInRange(startDate: startDate, endDate: endDate);
  }

  /// Get cached liturgy events by service type
  Future<List<LiturgyEvent>> getCachedEventsByServiceType(
    String serviceType,
  ) async {
    final db = await databaseHelper.database;

    final maps = await db.query(
      tableName,
      where: 'serviceType = ?',
      whereArgs: [serviceType],
      orderBy: 'dateTime ASC',
    );

    return maps.map((map) => fromDatabase(map)).toList();
  }

  /// Get cached liturgy events for today
  Future<List<LiturgyEvent>> getCachedTodayEvents() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return getCachedEventsInRange(startDate: startOfDay, endDate: endOfDay);
  }

  /// Get cached liturgy events for this week
  Future<List<LiturgyEvent>> getCachedWeekEvents() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );

    return getCachedEventsInRange(
      startDate: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      endDate: endOfWeek,
    );
  }

  /// Search cached liturgy events by title or description
  Future<List<LiturgyEvent>> searchCachedEvents(String query) async {
    final db = await databaseHelper.database;

    final maps = await db.query(
      tableName,
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'dateTime ASC',
    );

    return maps.map((map) => fromDatabase(map)).toList();
  }

  /// Get cached liturgy events with pagination
  Future<List<LiturgyEvent>> getCachedEventsPaginated({
    int page = 1,
    int limit = 20,
    bool upcomingOnly = true,
  }) async {
    final db = await databaseHelper.database;
    final offset = (page - 1) * limit;

    String? whereClause;
    List<dynamic>? whereArgs;

    if (upcomingOnly) {
      whereClause = 'dateTime >= ?';
      whereArgs = [DateTime.now().toIso8601String()];
    }

    final maps = await db.query(
      tableName,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'dateTime ASC',
      limit: limit,
      offset: offset,
    );

    return maps.map((map) => fromDatabase(map)).toList();
  }

  /// Get count of cached liturgy events
  Future<int> getCachedEventsCount({bool upcomingOnly = true}) async {
    final db = await databaseHelper.database;

    String? whereClause;
    List<dynamic>? whereArgs;

    if (upcomingOnly) {
      whereClause = 'dateTime >= ?';
      whereArgs = [DateTime.now().toIso8601String()];
    }

    final result = await db.query(
      tableName,
      columns: ['COUNT(*) as count'],
      where: whereClause,
      whereArgs: whereArgs,
    );

    return result.first['count'] as int;
  }
}
