import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:coptic_pulse/services/file_upload_service.dart';
import 'package:coptic_pulse/services/api_service.dart';
import 'package:coptic_pulse/utils/constants.dart';

import 'file_upload_service_test.mocks.dart';

@GenerateMocks([ApiService, File])
void main() {
  group('FileUploadService Tests', () {
    late FileUploadService fileUploadService;
    late MockApiService mockApiService;
    late MockFile mockFile;

    setUp(() {
      mockApiService = MockApiService();
      mockFile = MockFile();
      fileUploadService = FileUploadService(apiService: mockApiService);
    });

    group('uploadFile', () {
      testWidgets('should successfully upload a valid image file', (WidgetTester tester) async {
        // Arrange
        const fileName = 'test.jpg';
        const filePath = '/path/to/test.jpg';
        const fileSize = 1024 * 1024; // 1MB
        const expectedUrl = 'https://example.com/uploads/test.jpg';

        when(mockFile.path).thenReturn(filePath);
        when(mockFile.length()).thenAnswer((_) async => fileSize);
        when(mockApiService.post(
          AppConstants.uploadEndpoint,
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {'url': expectedUrl},
          statusCode: 200,
        ));

        // Act
        final result = await fileUploadService.uploadFile(mockFile);

        // Assert
        expect(result, equals(expectedUrl));
        verify(mockApiService.post(
          AppConstants.uploadEndpoint,
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).called(1);
      });

      testWidgets('should throw FileUploadException for file too large', (WidgetTester tester) async {
        // Arrange
        const filePath = '/path/to/large_file.jpg';
        const fileSize = AppConstants.maxFileSize + 1;

        when(mockFile.path).thenReturn(filePath);
        when(mockFile.length()).thenAnswer((_) async => fileSize);

        // Act & Assert
        expect(
          () => fileUploadService.uploadFile(mockFile),
          throwsA(isA<FileUploadException>()
              .having((e) => e.type, 'type', FileUploadErrorType.fileTooLarge)),
        );
      });

      testWidgets('should throw FileUploadException for invalid file type', (WidgetTester tester) async {
        // Arrange
        const filePath = '/path/to/test.txt';
        const fileSize = 1024;

        when(mockFile.path).thenReturn(filePath);
        when(mockFile.length()).thenAnswer((_) async => fileSize);

        // Act & Assert
        expect(
          () => fileUploadService.uploadFile(mockFile),
          throwsA(isA<FileUploadException>()
              .having((e) => e.type, 'type', FileUploadErrorType.invalidFileType)),
        );
      });

      testWidgets('should handle network errors', (WidgetTester tester) async {
        // Arrange
        const filePath = '/path/to/test.jpg';
        const fileSize = 1024;

        when(mockFile.path).thenReturn(filePath);
        when(mockFile.length()).thenAnswer((_) async => fileSize);
        when(mockApiService.post(
          AppConstants.uploadEndpoint,
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          error: const ApiError(
            type: ApiErrorType.network,
            message: 'Network error',
          ),
        ));

        // Act & Assert
        expect(
          () => fileUploadService.uploadFile(mockFile),
          throwsA(isA<FileUploadException>()
              .having((e) => e.type, 'type', FileUploadErrorType.network)),
        );
      });

      testWidgets('should handle server response without URL', (WidgetTester tester) async {
        // Arrange
        const filePath = '/path/to/test.jpg';
        const fileSize = 1024;

        when(mockFile.path).thenReturn(filePath);
        when(mockFile.length()).thenAnswer((_) async => fileSize);
        when(mockApiService.post(
          AppConstants.uploadEndpoint,
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {'message': 'Upload successful'},
          statusCode: 200,
        ));

        // Act & Assert
        expect(
          () => fileUploadService.uploadFile(mockFile),
          throwsA(isA<FileUploadException>()
              .having((e) => e.type, 'type', FileUploadErrorType.serverError)),
        );
      });
    });

    group('uploadFiles', () {
      testWidgets('should upload multiple files successfully', (WidgetTester tester) async {
        // Arrange
        final mockFile1 = MockFile();
        final mockFile2 = MockFile();
        const filePath1 = '/path/to/test1.jpg';
        const filePath2 = '/path/to/test2.png';
        const fileSize = 1024;
        const expectedUrl1 = 'https://example.com/uploads/test1.jpg';
        const expectedUrl2 = 'https://example.com/uploads/test2.png';

        when(mockFile1.path).thenReturn(filePath1);
        when(mockFile1.length()).thenAnswer((_) async => fileSize);
        when(mockFile2.path).thenReturn(filePath2);
        when(mockFile2.length()).thenAnswer((_) async => fileSize);

        when(mockApiService.post(
          AppConstants.uploadEndpoint,
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer((invocation) async {
          // Return different URLs based on the file being uploaded
          return Response(
            requestOptions: RequestOptions(path: ''),
            data: {'url': expectedUrl1}, // Simplified for test
            statusCode: 200,
          );
        });

        // Act
        final result = await fileUploadService.uploadFiles([mockFile1, mockFile2]);

        // Assert
        expect(result, hasLength(2));
        verify(mockApiService.post(
          AppConstants.uploadEndpoint,
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).called(2);
      });

      testWidgets('should handle partial failures in multiple file upload', (WidgetTester tester) async {
        // Arrange
        final mockFile1 = MockFile();
        final mockFile2 = MockFile();
        const filePath1 = '/path/to/test1.jpg';
        const filePath2 = '/path/to/test2.jpg';
        const fileSize = 1024;
        const expectedUrl1 = 'https://example.com/uploads/test1.jpg';

        when(mockFile1.path).thenReturn(filePath1);
        when(mockFile1.length()).thenAnswer((_) async => fileSize);
        when(mockFile2.path).thenReturn(filePath2);
        when(mockFile2.length()).thenAnswer((_) async => fileSize);

        var callCount = 0;
        when(mockApiService.post(
          AppConstants.uploadEndpoint,
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer((invocation) async {
          callCount++;
          if (callCount == 1) {
            return Response(
              requestOptions: RequestOptions(path: ''),
              data: {'url': expectedUrl1},
              statusCode: 200,
            );
          } else {
            throw DioException(
              requestOptions: RequestOptions(path: ''),
              error: const ApiError(
                type: ApiErrorType.server,
                message: 'Server error',
              ),
            );
          }
        });

        // Act & Assert
        expect(
          () => fileUploadService.uploadFiles([mockFile1, mockFile2]),
          throwsA(isA<FileUploadException>()),
        );
      });
    });

    group('File validation', () {
      testWidgets('should accept valid image file types', (WidgetTester tester) async {
        // Test each allowed image type
        for (final extension in AppConstants.allowedImageTypes) {
          final filePath = '/path/to/test.$extension';
          const fileSize = 1024;
          const expectedUrl = 'https://example.com/uploads/test.jpg';

          when(mockFile.path).thenReturn(filePath);
          when(mockFile.length()).thenAnswer((_) async => fileSize);
          when(mockApiService.post(
            AppConstants.uploadEndpoint,
            data: anyNamed('data'),
            options: anyNamed('options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'url': expectedUrl},
            statusCode: 200,
          ));

          // Should not throw exception
          await fileUploadService.uploadFile(mockFile);
        }
      });

      testWidgets('should accept valid video file types', (WidgetTester tester) async {
        // Test each allowed video type
        for (final extension in AppConstants.allowedVideoTypes) {
          final filePath = '/path/to/test.$extension';
          const fileSize = 1024;
          const expectedUrl = 'https://example.com/uploads/test.mp4';

          when(mockFile.path).thenReturn(filePath);
          when(mockFile.length()).thenAnswer((_) async => fileSize);
          when(mockApiService.post(
            AppConstants.uploadEndpoint,
            data: anyNamed('data'),
            options: anyNamed('options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'url': expectedUrl},
            statusCode: 200,
          ));

          // Should not throw exception
          await fileUploadService.uploadFile(mockFile);
        }
      });

      testWidgets('should reject invalid file types', (WidgetTester tester) async {
        final invalidExtensions = ['txt', 'doc', 'pdf', 'exe'];
        
        for (final extension in invalidExtensions) {
          final filePath = '/path/to/test.$extension';
          const fileSize = 1024;

          when(mockFile.path).thenReturn(filePath);
          when(mockFile.length()).thenAnswer((_) async => fileSize);

          expect(
            () => fileUploadService.uploadFile(mockFile),
            throwsA(isA<FileUploadException>()
                .having((e) => e.type, 'type', FileUploadErrorType.invalidFileType)),
          );
        }
      });
    });

    group('Error mapping', () {
      testWidgets('should map API error types correctly', (WidgetTester tester) async {
        const filePath = '/path/to/test.jpg';
        const fileSize = 1024;

        when(mockFile.path).thenReturn(filePath);
        when(mockFile.length()).thenAnswer((_) async => fileSize);

        final testCases = [
          (ApiErrorType.authentication, FileUploadErrorType.authentication),
          (ApiErrorType.authorization, FileUploadErrorType.authorization),
          (ApiErrorType.validation, FileUploadErrorType.validation),
          (ApiErrorType.server, FileUploadErrorType.serverError),
          (ApiErrorType.network, FileUploadErrorType.network),
          (ApiErrorType.timeout, FileUploadErrorType.network),
        ];

        for (final (apiErrorType, expectedUploadErrorType) in testCases) {
          when(mockApiService.post(
            AppConstants.uploadEndpoint,
            data: anyNamed('data'),
            options: anyNamed('options'),
          )).thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            error: ApiError(
              type: apiErrorType,
              message: 'Test error',
            ),
          ));

          expect(
            () => fileUploadService.uploadFile(mockFile),
            throwsA(isA<FileUploadException>()
                .having((e) => e.type, 'type', expectedUploadErrorType)),
          );
        }
      });
    });
  });
}