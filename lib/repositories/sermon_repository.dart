import '../models/sermon.dart';
import '../database/database_helper.dart';
import 'base_repository.dart';

/// Repository for managing sermon data with offline caching
class SermonRepository extends BaseRepository<Sermon> {
  SermonRepository({super.databaseHelper});

  @override
  String get tableName => DatabaseHelper.sermonsTable;

  @override
  String get cacheKeyPrefix => 'sermons_';

  @override
  Map<String, dynamic> toDatabase(Sermon model) {
    return {
      'id': model.id,
      'title': model.title,
      'description': model.description,
      'thumbnailUrl': model.thumbnailUrl,
      'videoUrl': model.videoUrl,
      'audioUrl': model.audioUrl,
      'publishedAt': model.publishedAt.toIso8601String(),
      'speaker': model.speaker,
      'tags': encodeList(model.tags),
      'duration': model.duration?.inSeconds,
    };
  }

  @override
  Sermon fromDatabase(Map<String, dynamic> map) {
    return Sermon(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      thumbnailUrl: map['thumbnailUrl'] as String?,
      videoUrl: map['videoUrl'] as String?,
      audioUrl: map['audioUrl'] as String?,
      publishedAt: DateTime.parse(map['publishedAt'] as String),
      speaker: map['speaker'] as String?,
      tags: decodeList(map['tags'] as String?),
      duration:
          map['duration'] != null
              ? Duration(seconds: map['duration'] as int)
              : null,
    );
  }

  /// Get cached sermons by speaker
  Future<List<Sermon>> getCachedSermonsBySpeaker(String speaker) async {
    final db = await databaseHelper.database;

    final maps = await db.query(
      tableName,
      where: 'speaker = ?',
      whereArgs: [speaker],
      orderBy: 'publishedAt DESC',
    );

    return maps.map((map) => fromDatabase(map)).toList();
  }

  /// Get cached recent sermons (within last 30 days)
  Future<List<Sermon>> getCachedRecentSermons() async {
    final db = await databaseHelper.database;
    final thirtyDaysAgo =
        DateTime.now().subtract(const Duration(days: 30)).toIso8601String();

    final maps = await db.query(
      tableName,
      where: 'publishedAt >= ?',
      whereArgs: [thirtyDaysAgo],
      orderBy: 'publishedAt DESC',
    );

    return maps.map((map) => fromDatabase(map)).toList();
  }

  /// Get cached sermons with video content
  Future<List<Sermon>> getCachedVideoSermons() async {
    final db = await databaseHelper.database;

    final maps = await db.query(
      tableName,
      where: 'videoUrl IS NOT NULL AND videoUrl != ""',
      orderBy: 'publishedAt DESC',
    );

    return maps.map((map) => fromDatabase(map)).toList();
  }

  /// Get cached sermons with audio content
  Future<List<Sermon>> getCachedAudioSermons() async {
    final db = await databaseHelper.database;

    final maps = await db.query(
      tableName,
      where: 'audioUrl IS NOT NULL AND audioUrl != ""',
      orderBy: 'publishedAt DESC',
    );

    return maps.map((map) => fromDatabase(map)).toList();
  }

  /// Search cached sermons by title, description, or speaker
  Future<List<Sermon>> searchCachedSermons(String query) async {
    final db = await databaseHelper.database;

    final maps = await db.query(
      tableName,
      where: 'title LIKE ? OR description LIKE ? OR speaker LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'publishedAt DESC',
    );

    return maps.map((map) => fromDatabase(map)).toList();
  }

  /// Get cached sermons by tag
  Future<List<Sermon>> getCachedSermonsByTag(String tag) async {
    final db = await databaseHelper.database;

    final maps = await db.query(
      tableName,
      where: 'tags LIKE ?',
      whereArgs: ['%"$tag"%'],
      orderBy: 'publishedAt DESC',
    );

    return maps.map((map) => fromDatabase(map)).toList();
  }

  /// Get cached sermons published in a date range
  Future<List<Sermon>> getCachedSermonsInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await databaseHelper.database;

    final maps = await db.query(
      tableName,
      where: 'publishedAt >= ? AND publishedAt <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'publishedAt DESC',
    );

    return maps.map((map) => fromDatabase(map)).toList();
  }

  /// Get cached sermons with pagination
  Future<List<Sermon>> getCachedSermonsPaginated({
    int page = 1,
    int limit = 20,
    String? speaker,
    bool hasVideoOnly = false,
    bool hasAudioOnly = false,
  }) async {
    final db = await databaseHelper.database;
    final offset = (page - 1) * limit;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (speaker != null) {
      whereClause += 'speaker = ?';
      whereArgs.add(speaker);
    }

    if (hasVideoOnly) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'videoUrl IS NOT NULL AND videoUrl != ""';
    }

    if (hasAudioOnly) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'audioUrl IS NOT NULL AND audioUrl != ""';
    }

    final maps = await db.query(
      tableName,
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'publishedAt DESC',
      limit: limit,
      offset: offset,
    );

    return maps.map((map) => fromDatabase(map)).toList();
  }

  /// Get count of cached sermons
  Future<int> getCachedSermonsCount({
    String? speaker,
    bool hasVideoOnly = false,
    bool hasAudioOnly = false,
  }) async {
    final db = await databaseHelper.database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (speaker != null) {
      whereClause += 'speaker = ?';
      whereArgs.add(speaker);
    }

    if (hasVideoOnly) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'videoUrl IS NOT NULL AND videoUrl != ""';
    }

    if (hasAudioOnly) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'audioUrl IS NOT NULL AND audioUrl != ""';
    }

    final result = await db.query(
      tableName,
      columns: ['COUNT(*) as count'],
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );

    return result.first['count'] as int;
  }

  /// Get all unique speakers from cached sermons
  Future<List<String>> getCachedSpeakers() async {
    final db = await databaseHelper.database;

    final maps = await db.query(
      tableName,
      columns: ['DISTINCT speaker'],
      where: 'speaker IS NOT NULL AND speaker != ""',
      orderBy: 'speaker ASC',
    );

    return maps
        .map((map) => map['speaker'] as String)
        .where((speaker) => speaker.isNotEmpty)
        .toList();
  }

  /// Get all unique tags from cached sermons
  Future<List<String>> getCachedTags() async {
    final sermons = await getCachedItems();
    final allTags = <String>{};

    for (final sermon in sermons) {
      allTags.addAll(sermon.tags);
    }

    final sortedTags = allTags.toList()..sort();
    return sortedTags;
  }
}
