import '../models/post.dart';
import '../database/database_helper.dart';
import 'base_repository.dart';

/// Repository for managing post data with offline caching
class PostRepository extends BaseRepository<Post> {
  PostRepository({super.databaseHelper});

  @override
  String get tableName => DatabaseHelper.postsTable;

  @override
  String get cacheKeyPrefix => 'posts_';

  @override
  Map<String, dynamic> toDatabase(Post model) {
    return {
      'id': model.id,
      'title': model.title,
      'content': model.content,
      'type': model.type.name,
      'status': model.status.name,
      'authorId': model.authorId,
      'createdAt': model.createdAt.toIso8601String(),
      'updatedAt': model.updatedAt?.toIso8601String(),
      'attachments': encodeList(model.attachments),
    };
  }

  @override
  Post fromDatabase(Map<String, dynamic> map) {
    return Post(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      type: PostType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => PostType.announcement,
      ),
      status: PostStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PostStatus.draft,
      ),
      authorId: map['authorId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
      attachments: decodeList(map['attachments'] as String?),
    );
  }

  /// Get cached posts by type
  Future<List<Post>> getCachedPostsByType(PostType type) async {
    final db = await databaseHelper.database;
    final maps = await db.query(
      tableName,
      where: 'type = ?',
      whereArgs: [type.name],
      orderBy: 'createdAt DESC',
    );
    
    return maps.map((map) => fromDatabase(map)).toList();
  }

  /// Get cached approved posts
  Future<List<Post>> getCachedApprovedPosts() async {
    final db = await databaseHelper.database;
    final maps = await db.query(
      tableName,
      where: 'status = ?',
      whereArgs: [PostStatus.approved.name],
      orderBy: 'createdAt DESC',
    );
    
    return maps.map((map) => fromDatabase(map)).toList();
  }

  /// Get cached posts by author
  Future<List<Post>> getCachedPostsByAuthor(String authorId) async {
    final db = await databaseHelper.database;
    final maps = await db.query(
      tableName,
      where: 'authorId = ?',
      whereArgs: [authorId],
      orderBy: 'createdAt DESC',
    );
    
    return maps.map((map) => fromDatabase(map)).toList();
  }

  /// Search cached posts by title or content
  Future<List<Post>> searchCachedPosts(String query) async {
    final db = await databaseHelper.database;
    final maps = await db.query(
      tableName,
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );
    
    return maps.map((map) => fromDatabase(map)).toList();
  }

  /// Get cached posts with pagination
  Future<List<Post>> getCachedPostsPaginated({
    int page = 1,
    int limit = 20,
    PostType? type,
    PostStatus? status,
  }) async {
    final db = await databaseHelper.database;
    final offset = (page - 1) * limit;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (type != null) {
      whereClause += 'type = ?';
      whereArgs.add(type.name);
    }
    
    if (status != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'status = ?';
      whereArgs.add(status.name);
    }
    
    final maps = await db.query(
      tableName,
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'createdAt DESC',
      limit: limit,
      offset: offset,
    );
    
    return maps.map((map) => fromDatabase(map)).toList();
  }

  /// Get count of cached posts
  Future<int> getCachedPostsCount({PostType? type, PostStatus? status}) async {
    final db = await databaseHelper.database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (type != null) {
      whereClause += 'type = ?';
      whereArgs.add(type.name);
    }
    
    if (status != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'status = ?';
      whereArgs.add(status.name);
    }
    
    final result = await db.query(
      tableName,
      columns: ['COUNT(*) as count'],
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );
    
    return result.first['count'] as int;
  }
}