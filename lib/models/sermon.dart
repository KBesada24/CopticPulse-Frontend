/// Sermon model for sermon content and resources
class Sermon {
  final String id;
  final String title;
  final String description;
  final String? thumbnailUrl;
  final String? videoUrl;
  final String? audioUrl;
  final DateTime publishedAt;
  final String? speaker;
  final List<String> tags;
  final Duration? duration;

  const Sermon({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnailUrl,
    this.videoUrl,
    this.audioUrl,
    required this.publishedAt,
    this.speaker,
    this.tags = const [],
    this.duration,
  });

  /// Creates a Sermon from JSON data
  factory Sermon.fromJson(Map<String, dynamic> json) {
    return Sermon(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      speaker: json['speaker'] as String?,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      duration: json['duration'] != null
          ? Duration(seconds: json['duration'] as int)
          : null,
    );
  }

  /// Converts Sermon to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      if (videoUrl != null) 'videoUrl': videoUrl,
      if (audioUrl != null) 'audioUrl': audioUrl,
      'publishedAt': publishedAt.toIso8601String(),
      if (speaker != null) 'speaker': speaker,
      'tags': tags,
      if (duration != null) 'duration': duration!.inSeconds,
    };
  }

  /// Creates a copy of this Sermon with updated fields
  Sermon copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? videoUrl,
    String? audioUrl,
    DateTime? publishedAt,
    String? speaker,
    List<String>? tags,
    Duration? duration,
  }) {
    return Sermon(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      speaker: speaker ?? this.speaker,
      tags: tags ?? this.tags,
      duration: duration ?? this.duration,
    );
  }

  /// Returns formatted published date
  String get formattedPublishedDate {
    return '${_getMonth(publishedAt.month)} ${publishedAt.day}, ${publishedAt.year}';
  }

  /// Returns formatted duration string
  String? get formattedDuration {
    if (duration == null) return null;
    final hours = duration!.inHours;
    final minutes = duration!.inMinutes % 60;
    final seconds = duration!.inSeconds % 60;
    
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    } else if (minutes > 0) {
      return seconds > 0 ? '${minutes}m ${seconds}s' : '${minutes}m';
    } else {
      return '${seconds}s';
    }
  }

  /// Returns whether the sermon has video content
  bool get hasVideo {
    return videoUrl != null && videoUrl!.isNotEmpty;
  }

  /// Returns whether the sermon has audio content
  bool get hasAudio {
    return audioUrl != null && audioUrl!.isNotEmpty;
  }

  /// Returns whether the sermon has any media content
  bool get hasMedia {
    return hasVideo || hasAudio;
  }

  /// Returns whether the sermon was published recently (within last 7 days)
  bool get isRecent {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return publishedAt.isAfter(weekAgo);
  }

  /// Returns the primary media URL (video preferred over audio)
  String? get primaryMediaUrl {
    return hasVideo ? videoUrl : audioUrl;
  }

  /// Returns the media type for the primary media
  SermonMediaType? get primaryMediaType {
    if (hasVideo) return SermonMediaType.video;
    if (hasAudio) return SermonMediaType.audio;
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Sermon &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.thumbnailUrl == thumbnailUrl &&
        other.videoUrl == videoUrl &&
        other.audioUrl == audioUrl &&
        other.publishedAt == publishedAt &&
        other.speaker == speaker &&
        _listEquals(other.tags, tags) &&
        other.duration == duration;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      thumbnailUrl,
      videoUrl,
      audioUrl,
      publishedAt,
      speaker,
      Object.hashAll(tags),
      duration,
    );
  }

  @override
  String toString() {
    return 'Sermon(id: $id, title: $title, speaker: $speaker, publishedAt: $publishedAt)';
  }

  /// Helper method to compare lists
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
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

/// Enum for sermon media types
enum SermonMediaType {
  video,
  audio;

  /// Returns display name for the media type
  String get displayName {
    switch (this) {
      case SermonMediaType.video:
        return 'Video';
      case SermonMediaType.audio:
        return 'Audio';
    }
  }

  /// Returns icon name for the media type
  String get iconName {
    switch (this) {
      case SermonMediaType.video:
        return 'play_circle';
      case SermonMediaType.audio:
        return 'volume_up';
    }
  }
}