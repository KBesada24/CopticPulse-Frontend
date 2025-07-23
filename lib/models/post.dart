/// Post model for community posts and announcements
class Post {
  final String id;
  final String title;
  final String content;
  final PostType type;
  final PostStatus status;
  final String authorId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> attachments;

  const Post({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.status,
    required this.authorId,
    required this.createdAt,
    this.updatedAt,
    this.attachments = const [],
  });

  /// Creates a Post from JSON data
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      type: PostType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PostType.announcement,
      ),
      status: PostStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PostStatus.draft,
      ),
      authorId: json['authorId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
    );
  }

  /// Converts Post to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type.name,
      'status': status.name,
      'authorId': authorId,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      'attachments': attachments,
    };
  }

  /// Creates a copy of this Post with updated fields
  Post copyWith({
    String? id,
    String? title,
    String? content,
    PostType? type,
    PostStatus? status,
    String? authorId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? attachments,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      authorId: authorId ?? this.authorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attachments: attachments ?? this.attachments,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Post &&
        other.id == id &&
        other.title == title &&
        other.content == content &&
        other.type == type &&
        other.status == status &&
        other.authorId == authorId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        _listEquals(other.attachments, attachments);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      content,
      type,
      status,
      authorId,
      createdAt,
      updatedAt,
      Object.hashAll(attachments),
    );
  }

  @override
  String toString() {
    return 'Post(id: $id, title: $title, type: $type, status: $status, authorId: $authorId, createdAt: $createdAt)';
  }

  /// Helper method to compare lists
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Enum for different types of posts
enum PostType {
  announcement,
  event,
  prayerRequest;

  /// Returns display name for the post type
  String get displayName {
    switch (this) {
      case PostType.announcement:
        return 'Announcement';
      case PostType.event:
        return 'Event';
      case PostType.prayerRequest:
        return 'Prayer Request';
    }
  }

  /// Returns icon name for the post type
  String get iconName {
    switch (this) {
      case PostType.announcement:
        return 'announcement';
      case PostType.event:
        return 'event';
      case PostType.prayerRequest:
        return 'prayer';
    }
  }
}

/// Enum for post approval status
enum PostStatus {
  draft,
  pending,
  approved,
  rejected;

  /// Returns display name for the post status
  String get displayName {
    switch (this) {
      case PostStatus.draft:
        return 'Draft';
      case PostStatus.pending:
        return 'Pending Approval';
      case PostStatus.approved:
        return 'Approved';
      case PostStatus.rejected:
        return 'Rejected';
    }
  }

  /// Returns whether the post is visible to community
  bool get isVisible {
    return this == PostStatus.approved;
  }

  /// Returns whether the post can be edited
  bool get canEdit {
    return this == PostStatus.draft || this == PostStatus.rejected;
  }
}