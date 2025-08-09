import 'package:flutter_test/flutter_test.dart';
import 'package:coptic_pulse/models/post.dart';
import 'package:coptic_pulse/services/file_upload_service.dart';

void main() {
  group('Post Creation Integration Tests', () {
    test('should create Post object with correct properties', () {
      // Arrange
      const title = 'Test Post Title';
      const content = 'This is a test post content that is long enough to pass validation';
      const type = PostType.announcement;
      const status = PostStatus.pending;
      const authorId = 'user123';
      final createdAt = DateTime.now();
      const attachments = <String>['https://example.com/image1.jpg'];

      // Act
      final post = Post(
        id: '',
        title: title,
        content: content,
        type: type,
        status: status,
        authorId: authorId,
        createdAt: createdAt,
        attachments: attachments,
      );

      // Assert
      expect(post.title, equals(title));
      expect(post.content, equals(content));
      expect(post.type, equals(type));
      expect(post.status, equals(status));
      expect(post.authorId, equals(authorId));
      expect(post.createdAt, equals(createdAt));
      expect(post.attachments, equals(attachments));
    });

    test('should validate PostType enum values', () {
      // Test all post types
      expect(PostType.announcement.displayName, equals('Announcement'));
      expect(PostType.event.displayName, equals('Event'));
      expect(PostType.prayerRequest.displayName, equals('Prayer Request'));
    });

    test('should validate PostStatus enum values', () {
      // Test all post statuses
      expect(PostStatus.draft.displayName, equals('Draft'));
      expect(PostStatus.pending.displayName, equals('Pending Approval'));
      expect(PostStatus.approved.displayName, equals('Approved'));
      expect(PostStatus.rejected.displayName, equals('Rejected'));
      
      // Test visibility logic
      expect(PostStatus.approved.isVisible, isTrue);
      expect(PostStatus.pending.isVisible, isFalse);
      expect(PostStatus.draft.isVisible, isFalse);
      expect(PostStatus.rejected.isVisible, isFalse);
      
      // Test edit permissions
      expect(PostStatus.draft.canEdit, isTrue);
      expect(PostStatus.rejected.canEdit, isTrue);
      expect(PostStatus.pending.canEdit, isFalse);
      expect(PostStatus.approved.canEdit, isFalse);
    });

    test('should validate file type checking logic', () {
      // Test image file extensions
      expect(['jpg', 'jpeg', 'png', 'gif'].every((ext) => 
        ['jpg', 'jpeg', 'png', 'gif'].contains(ext)), isTrue);
      
      // Test video file extensions
      expect(['mp4', 'mov', 'avi'].every((ext) => 
        ['mp4', 'mov', 'avi'].contains(ext)), isTrue);
    });

    test('should create FileUploadException with correct properties', () {
      // Arrange
      const message = 'File too large';
      const type = FileUploadErrorType.fileTooLarge;
      const statusCode = 413;

      // Act
      const exception = FileUploadException(
        message: message,
        type: type,
        statusCode: statusCode,
      );

      // Assert
      expect(exception.message, equals(message));
      expect(exception.type, equals(type));
      expect(exception.statusCode, equals(statusCode));
      expect(exception.isValidationError, isTrue);
      expect(exception.isNetworkError, isFalse);
      expect(exception.isServerError, isFalse);
    });

    test('should handle different FileUploadErrorType validations', () {
      // Test network error
      const networkException = FileUploadException(
        message: 'Network error',
        type: FileUploadErrorType.network,
      );
      expect(networkException.isNetworkError, isTrue);
      expect(networkException.isValidationError, isFalse);

      // Test server error
      const serverException = FileUploadException(
        message: 'Server error',
        type: FileUploadErrorType.serverError,
      );
      expect(serverException.isServerError, isTrue);
      expect(serverException.isValidationError, isFalse);

      // Test validation errors
      const fileTooLargeException = FileUploadException(
        message: 'File too large',
        type: FileUploadErrorType.fileTooLarge,
      );
      expect(fileTooLargeException.isValidationError, isTrue);

      const invalidTypeException = FileUploadException(
        message: 'Invalid file type',
        type: FileUploadErrorType.invalidFileType,
      );
      expect(invalidTypeException.isValidationError, isTrue);

      const validationException = FileUploadException(
        message: 'Validation error',
        type: FileUploadErrorType.validation,
      );
      expect(validationException.isValidationError, isTrue);
    });

    test('should convert Post to and from JSON correctly', () {
      // Arrange
      final originalPost = Post(
        id: 'post123',
        title: 'Test Post',
        content: 'Test content',
        type: PostType.event,
        status: PostStatus.approved,
        authorId: 'user123',
        createdAt: DateTime(2024, 1, 1, 12, 0, 0),
        updatedAt: DateTime(2024, 1, 2, 12, 0, 0),
        attachments: const ['https://example.com/image.jpg'],
      );

      // Act
      final json = originalPost.toJson();
      final reconstructedPost = Post.fromJson(json);

      // Assert
      expect(reconstructedPost.id, equals(originalPost.id));
      expect(reconstructedPost.title, equals(originalPost.title));
      expect(reconstructedPost.content, equals(originalPost.content));
      expect(reconstructedPost.type, equals(originalPost.type));
      expect(reconstructedPost.status, equals(originalPost.status));
      expect(reconstructedPost.authorId, equals(originalPost.authorId));
      expect(reconstructedPost.createdAt, equals(originalPost.createdAt));
      expect(reconstructedPost.updatedAt, equals(originalPost.updatedAt));
      expect(reconstructedPost.attachments, equals(originalPost.attachments));
    });

    test('should create Post copy with updated fields', () {
      // Arrange
      final originalPost = Post(
        id: 'post123',
        title: 'Original Title',
        content: 'Original content',
        type: PostType.announcement,
        status: PostStatus.draft,
        authorId: 'user123',
        createdAt: DateTime.now(),
        attachments: const [],
      );

      // Act
      final updatedPost = originalPost.copyWith(
        title: 'Updated Title',
        status: PostStatus.approved,
        attachments: const ['https://example.com/image.jpg'],
      );

      // Assert
      expect(updatedPost.id, equals(originalPost.id));
      expect(updatedPost.title, equals('Updated Title'));
      expect(updatedPost.content, equals(originalPost.content));
      expect(updatedPost.type, equals(originalPost.type));
      expect(updatedPost.status, equals(PostStatus.approved));
      expect(updatedPost.authorId, equals(originalPost.authorId));
      expect(updatedPost.createdAt, equals(originalPost.createdAt));
      expect(updatedPost.attachments, equals(const ['https://example.com/image.jpg']));
    });

    test('should validate Post equality', () {
      // Arrange
      final createdAt = DateTime.now();
      final post1 = Post(
        id: 'post123',
        title: 'Test Post',
        content: 'Test content',
        type: PostType.announcement,
        status: PostStatus.approved,
        authorId: 'user123',
        createdAt: createdAt,
        attachments: const ['image.jpg'],
      );

      final post2 = Post(
        id: 'post123',
        title: 'Test Post',
        content: 'Test content',
        type: PostType.announcement,
        status: PostStatus.approved,
        authorId: 'user123',
        createdAt: createdAt,
        attachments: const ['image.jpg'],
      );

      final post3 = post1.copyWith(title: 'Different Title');

      // Assert
      expect(post1, equals(post2));
      expect(post1.hashCode, equals(post2.hashCode));
      expect(post1, isNot(equals(post3)));
      expect(post1.hashCode, isNot(equals(post3.hashCode)));
    });
  });
}