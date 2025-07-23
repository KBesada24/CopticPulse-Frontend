import 'package:flutter_test/flutter_test.dart';
import 'package:coptic_pulse/models/post.dart';

void main() {
  group('Post Model Tests', () {
    final testDateTime = DateTime(2024, 1, 15, 10, 30);
    final testUpdatedDateTime = DateTime(2024, 1, 16, 14, 45);

    final testPostJson = {
      'id': 'post123',
      'title': 'Test Announcement',
      'content': 'This is a test announcement content.',
      'type': 'announcement',
      'status': 'approved',
      'authorId': 'user123',
      'createdAt': testDateTime.toIso8601String(),
      'updatedAt': testUpdatedDateTime.toIso8601String(),
      'attachments': ['image1.jpg', 'image2.jpg'],
    };

    final testPostJsonMinimal = {
      'id': 'post456',
      'title': 'Simple Post',
      'content': 'Simple content.',
      'type': 'event',
      'status': 'pending',
      'authorId': 'user456',
      'createdAt': testDateTime.toIso8601String(),
    };

    test('should create Post from JSON correctly', () {
      final post = Post.fromJson(testPostJson);

      expect(post.id, equals('post123'));
      expect(post.title, equals('Test Announcement'));
      expect(post.content, equals('This is a test announcement content.'));
      expect(post.type, equals(PostType.announcement));
      expect(post.status, equals(PostStatus.approved));
      expect(post.authorId, equals('user123'));
      expect(post.createdAt, equals(testDateTime));
      expect(post.updatedAt, equals(testUpdatedDateTime));
      expect(post.attachments, equals(['image1.jpg', 'image2.jpg']));
    });

    test('should create Post from minimal JSON correctly', () {
      final post = Post.fromJson(testPostJsonMinimal);

      expect(post.id, equals('post456'));
      expect(post.title, equals('Simple Post'));
      expect(post.content, equals('Simple content.'));
      expect(post.type, equals(PostType.event));
      expect(post.status, equals(PostStatus.pending));
      expect(post.authorId, equals('user456'));
      expect(post.createdAt, equals(testDateTime));
      expect(post.updatedAt, isNull);
      expect(post.attachments, isEmpty);
    });

    test('should convert Post to JSON correctly', () {
      final post = Post(
        id: 'post123',
        title: 'Test Announcement',
        content: 'This is a test announcement content.',
        type: PostType.announcement,
        status: PostStatus.approved,
        authorId: 'user123',
        createdAt: testDateTime,
        updatedAt: testUpdatedDateTime,
        attachments: const ['image1.jpg', 'image2.jpg'],
      );

      final json = post.toJson();

      expect(json['id'], equals('post123'));
      expect(json['title'], equals('Test Announcement'));
      expect(json['content'], equals('This is a test announcement content.'));
      expect(json['type'], equals('announcement'));
      expect(json['status'], equals('approved'));
      expect(json['authorId'], equals('user123'));
      expect(json['createdAt'], equals(testDateTime.toIso8601String()));
      expect(json['updatedAt'], equals(testUpdatedDateTime.toIso8601String()));
      expect(json['attachments'], equals(['image1.jpg', 'image2.jpg']));
    });

    test('should convert Post without updatedAt to JSON correctly', () {
      final post = Post(
        id: 'post456',
        title: 'Simple Post',
        content: 'Simple content.',
        type: PostType.event,
        status: PostStatus.pending,
        authorId: 'user456',
        createdAt: testDateTime,
      );

      final json = post.toJson();

      expect(json['id'], equals('post456'));
      expect(json['title'], equals('Simple Post'));
      expect(json['content'], equals('Simple content.'));
      expect(json['type'], equals('event'));
      expect(json['status'], equals('pending'));
      expect(json['authorId'], equals('user456'));
      expect(json['createdAt'], equals(testDateTime.toIso8601String()));
      expect(json.containsKey('updatedAt'), isFalse);
      expect(json['attachments'], isEmpty);
    });

    test('should handle invalid type and status gracefully', () {
      final invalidJson = {
        'id': 'post123',
        'title': 'Test Post',
        'content': 'Test content',
        'type': 'invalid_type',
        'status': 'invalid_status',
        'authorId': 'user123',
        'createdAt': testDateTime.toIso8601String(),
      };

      final post = Post.fromJson(invalidJson);
      expect(post.type, equals(PostType.announcement)); // Should default
      expect(post.status, equals(PostStatus.draft)); // Should default
    });

    test('should create copy with updated fields', () {
      final originalPost = Post(
        id: 'post123',
        title: 'Original Title',
        content: 'Original content',
        type: PostType.announcement,
        status: PostStatus.draft,
        authorId: 'user123',
        createdAt: testDateTime,
      );

      final updatedPost = originalPost.copyWith(
        title: 'Updated Title',
        status: PostStatus.approved,
        updatedAt: testUpdatedDateTime,
        attachments: const ['new_image.jpg'],
      );

      expect(updatedPost.id, equals('post123'));
      expect(updatedPost.title, equals('Updated Title'));
      expect(updatedPost.content, equals('Original content'));
      expect(updatedPost.type, equals(PostType.announcement));
      expect(updatedPost.status, equals(PostStatus.approved));
      expect(updatedPost.authorId, equals('user123'));
      expect(updatedPost.createdAt, equals(testDateTime));
      expect(updatedPost.updatedAt, equals(testUpdatedDateTime));
      expect(updatedPost.attachments, equals(['new_image.jpg']));
    });

    test('should implement equality correctly', () {
      final post1 = Post(
        id: 'post123',
        title: 'Test Post',
        content: 'Test content',
        type: PostType.announcement,
        status: PostStatus.approved,
        authorId: 'user123',
        createdAt: testDateTime,
        attachments: const ['image.jpg'],
      );

      final post2 = Post(
        id: 'post123',
        title: 'Test Post',
        content: 'Test content',
        type: PostType.announcement,
        status: PostStatus.approved,
        authorId: 'user123',
        createdAt: testDateTime,
        attachments: const ['image.jpg'],
      );

      final post3 = Post(
        id: 'post456',
        title: 'Different Post',
        content: 'Different content',
        type: PostType.event,
        status: PostStatus.pending,
        authorId: 'user456',
        createdAt: testDateTime,
      );

      expect(post1, equals(post2));
      expect(post1, isNot(equals(post3)));
      expect(post1.hashCode, equals(post2.hashCode));
    });

    test('should have proper toString implementation', () {
      final post = Post(
        id: 'post123',
        title: 'Test Post',
        content: 'Test content',
        type: PostType.announcement,
        status: PostStatus.approved,
        authorId: 'user123',
        createdAt: testDateTime,
      );

      final string = post.toString();
      expect(string, contains('post123'));
      expect(string, contains('Test Post'));
      expect(string, contains('PostType.announcement'));
      expect(string, contains('PostStatus.approved'));
      expect(string, contains('user123'));
    });

    group('PostType enum tests', () {
      test('should have correct display names', () {
        expect(PostType.announcement.displayName, equals('Announcement'));
        expect(PostType.event.displayName, equals('Event'));
        expect(PostType.prayerRequest.displayName, equals('Prayer Request'));
      });

      test('should have correct icon names', () {
        expect(PostType.announcement.iconName, equals('announcement'));
        expect(PostType.event.iconName, equals('event'));
        expect(PostType.prayerRequest.iconName, equals('prayer'));
      });

      test('should serialize to correct string values', () {
        expect(PostType.announcement.name, equals('announcement'));
        expect(PostType.event.name, equals('event'));
        expect(PostType.prayerRequest.name, equals('prayerRequest'));
      });
    });

    group('PostStatus enum tests', () {
      test('should have correct display names', () {
        expect(PostStatus.draft.displayName, equals('Draft'));
        expect(PostStatus.pending.displayName, equals('Pending Approval'));
        expect(PostStatus.approved.displayName, equals('Approved'));
        expect(PostStatus.rejected.displayName, equals('Rejected'));
      });

      test('should have correct visibility rules', () {
        expect(PostStatus.draft.isVisible, isFalse);
        expect(PostStatus.pending.isVisible, isFalse);
        expect(PostStatus.approved.isVisible, isTrue);
        expect(PostStatus.rejected.isVisible, isFalse);
      });

      test('should have correct edit rules', () {
        expect(PostStatus.draft.canEdit, isTrue);
        expect(PostStatus.pending.canEdit, isFalse);
        expect(PostStatus.approved.canEdit, isFalse);
        expect(PostStatus.rejected.canEdit, isTrue);
      });

      test('should serialize to correct string values', () {
        expect(PostStatus.draft.name, equals('draft'));
        expect(PostStatus.pending.name, equals('pending'));
        expect(PostStatus.approved.name, equals('approved'));
        expect(PostStatus.rejected.name, equals('rejected'));
      });
    });
  });
}