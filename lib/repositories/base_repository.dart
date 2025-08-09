import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/cache_metadata.dart';

/// Base repository class providing common caching functionality
abstract class BaseRepository<T> {
  final DatabaseHelper _databaseHelper;

  BaseRepository({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper();

  /// Get database helper instance for subclasses
  @protected
  DatabaseHelper get databaseHelper => _databaseHelper;

  /// Get table name for this repository
  String get tableName;

  /// Get cache key prefix for this repository
  String get cacheKeyPrefix;

  /// Convert model to database map
  Map<String, dynamic> toDatabase(T model);

  /// Convert database map to model
  T fromDatabase(Map<String, dynamic> map);

  /// Get all cached items
  Future<List<T>> getCachedItems() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(tableName, orderBy: 'cached_at DESC');

    return maps.map((map) => fromDatabase(map)).toList();
  }

  /// Get cached item by ID
  Future<T?> getCachedItem(String id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return fromDatabase(maps.first);
  }

  /// Cache single item
  Future<void> cacheItem(T item) async {
    final db = await _databaseHelper.database;
    final data = toDatabase(item);
    data['cached_at'] = DateTime.now().toIso8601String();

    await db.insert(
      tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Cache multiple items
  Future<void> cacheItems(List<T> items) async {
    if (items.isEmpty) return;

    final db = await _databaseHelper.database;
    final batch = db.batch();
    final cachedAt = DateTime.now().toIso8601String();

    for (final item in items) {
      final data = toDatabase(item);
      data['cached_at'] = cachedAt;

      batch.insert(
        tableName,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Remove cached item by ID
  Future<void> removeCachedItem(String id) async {
    final db = await _databaseHelper.database;
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  /// Clear all cached items
  Future<void> clearCache() async {
    final db = await _databaseHelper.database;
    await db.delete(tableName);
    await _removeCacheMetadata();
  }

  /// Get cache metadata
  Future<CacheMetadata?> getCacheMetadata(String key) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseHelper.cacheMetadataTable,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return CacheMetadata.fromJson(maps.first);
  }

  /// Update cache metadata
  Future<void> updateCacheMetadata(CacheMetadata metadata) async {
    final db = await _databaseHelper.database;
    await db.insert(
      DatabaseHelper.cacheMetadataTable,
      metadata.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Remove cache metadata
  Future<void> _removeCacheMetadata() async {
    final db = await _databaseHelper.database;
    await db.delete(
      DatabaseHelper.cacheMetadataTable,
      where: 'key LIKE ?',
      whereArgs: ['$cacheKeyPrefix%'],
    );
  }

  /// Check if cache is valid and not expired
  Future<bool> isCacheValid(String key) async {
    final metadata = await getCacheMetadata(key);
    if (metadata == null) return false;

    return !metadata.needsRefresh && metadata.syncStatus.isSuccessful;
  }

  /// Get cache age in minutes
  Future<int> getCacheAge(String key) async {
    final metadata = await getCacheMetadata(key);
    if (metadata == null) return -1;

    return metadata.ageInMinutes;
  }

  /// Mark cache as syncing
  Future<void> markCacheAsSyncing(String key) async {
    final metadata = CacheMetadata(
      key: key,
      lastSync: DateTime.now(),
      syncStatus: CacheSyncStatus.syncing,
    );
    await updateCacheMetadata(metadata);
  }

  /// Mark cache as successful
  Future<void> markCacheAsSuccess(String key, {Duration? expiresIn}) async {
    final now = DateTime.now();
    final metadata = CacheMetadata(
      key: key,
      lastSync: now,
      expiresAt: expiresIn != null ? now.add(expiresIn) : null,
      syncStatus: CacheSyncStatus.success,
    );
    await updateCacheMetadata(metadata);
  }

  /// Mark cache as failed
  Future<void> markCacheAsFailed(String key) async {
    final metadata = CacheMetadata(
      key: key,
      lastSync: DateTime.now(),
      syncStatus: CacheSyncStatus.failed,
    );
    await updateCacheMetadata(metadata);
  }

  /// Helper method to encode list as JSON string
  String encodeList(List<String> list) {
    return jsonEncode(list);
  }

  /// Helper method to decode JSON string as list
  List<String> decodeList(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final decoded = jsonDecode(jsonString);
      return (decoded as List<dynamic>).map((e) => e as String).toList();
    } catch (e) {
      return [];
    }
  }
}
