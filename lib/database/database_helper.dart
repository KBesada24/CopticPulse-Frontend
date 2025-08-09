import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../config/environment.dart';

/// Database helper for managing local SQLite database
class DatabaseHelper {
  static const int _databaseVersion = 1;

  // Table names
  static const String postsTable = 'posts';
  static const String liturgyEventsTable = 'liturgy_events';
  static const String sermonsTable = 'sermons';
  static const String cacheMetadataTable = 'cache_metadata';

  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  /// Get database instance
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, EnvironmentConfig.databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    await _createPostsTable(db);
    await _createLiturgyEventsTable(db);
    await _createSermonsTable(db);
    await _createCacheMetadataTable(db);
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database schema migrations here
    // For now, we'll recreate tables (in production, use proper migrations)
    if (oldVersion < newVersion) {
      await _dropAllTables(db);
      await _onCreate(db, newVersion);
    }
  }

  /// Create posts table
  Future<void> _createPostsTable(Database db) async {
    await db.execute('''
      CREATE TABLE $postsTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        authorId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        attachments TEXT,
        cached_at TEXT NOT NULL
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_posts_type ON $postsTable (type)');
    await db.execute('CREATE INDEX idx_posts_status ON $postsTable (status)');
    await db.execute('CREATE INDEX idx_posts_created_at ON $postsTable (createdAt)');
  }

  /// Create liturgy events table
  Future<void> _createLiturgyEventsTable(Database db) async {
    await db.execute('''
      CREATE TABLE $liturgyEventsTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        dateTime TEXT NOT NULL,
        location TEXT NOT NULL,
        serviceType TEXT NOT NULL,
        description TEXT,
        duration INTEGER,
        cached_at TEXT NOT NULL
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_liturgy_events_date ON $liturgyEventsTable (dateTime)');
    await db.execute('CREATE INDEX idx_liturgy_events_service_type ON $liturgyEventsTable (serviceType)');
  }

  /// Create sermons table
  Future<void> _createSermonsTable(Database db) async {
    await db.execute('''
      CREATE TABLE $sermonsTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        thumbnailUrl TEXT,
        videoUrl TEXT,
        audioUrl TEXT,
        publishedAt TEXT NOT NULL,
        speaker TEXT,
        tags TEXT,
        duration INTEGER,
        cached_at TEXT NOT NULL
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_sermons_published_at ON $sermonsTable (publishedAt)');
    await db.execute('CREATE INDEX idx_sermons_speaker ON $sermonsTable (speaker)');
  }

  /// Create cache metadata table for tracking cache status
  Future<void> _createCacheMetadataTable(Database db) async {
    await db.execute('''
      CREATE TABLE $cacheMetadataTable (
        key TEXT PRIMARY KEY,
        last_sync TEXT NOT NULL,
        expires_at TEXT,
        sync_status TEXT NOT NULL
      )
    ''');
  }

  /// Drop all tables (used for database upgrades)
  Future<void> _dropAllTables(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $postsTable');
    await db.execute('DROP TABLE IF EXISTS $liturgyEventsTable');
    await db.execute('DROP TABLE IF EXISTS $sermonsTable');
    await db.execute('DROP TABLE IF EXISTS $cacheMetadataTable');
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(postsTable);
      await txn.delete(liturgyEventsTable);
      await txn.delete(sermonsTable);
      await txn.delete(cacheMetadataTable);
    });
  }

  /// Get database size in bytes
  Future<int> getDatabaseSize() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, EnvironmentConfig.databaseName);
    final file = await File(path).stat();
    return file.size;
  }

  /// Close database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}