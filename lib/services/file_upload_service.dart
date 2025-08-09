import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import '../utils/constants.dart';
import 'api_service.dart';

/// Service for handling file upload operations
class FileUploadService {
  final ApiService _apiService;

  FileUploadService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  /// Upload a single file and return the file URL
  Future<String> uploadFile(File file) async {
    try {
      // Validate file size
      final fileSize = await file.length();
      if (fileSize > AppConstants.maxFileSize) {
        throw FileUploadException(
          message:
              'File size exceeds maximum allowed size of ${AppConstants.maxFileSize ~/ (1024 * 1024)}MB',
          type: FileUploadErrorType.fileTooLarge,
        );
      }

      // Validate file type
      final fileName = path.basename(file.path);
      final fileExtension = path
          .extension(fileName)
          .toLowerCase()
          .replaceFirst('.', '');

      if (!_isAllowedFileType(fileExtension)) {
        throw FileUploadException(
          message:
              'File type not allowed. Supported types: ${[...AppConstants.allowedImageTypes, ...AppConstants.allowedVideoTypes].join(', ')}',
          type: FileUploadErrorType.invalidFileType,
        );
      }

      // Determine MIME type
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

      // Create multipart file
      final multipartFile = await MultipartFile.fromFile(
        file.path,
        filename: fileName,
        contentType: DioMediaType.parse(mimeType),
      );

      // Create form data
      final formData = FormData.fromMap({
        'file': multipartFile,
        'type': _getFileCategory(fileExtension),
      });

      // Upload file
      final response = await _apiService.post(
        AppConstants.uploadEndpoint,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      // Extract file URL from response
      final fileUrl = response.data['url'] as String?;
      if (fileUrl == null) {
        throw FileUploadException(
          message: 'Invalid response from server',
          type: FileUploadErrorType.serverError,
        );
      }

      return fileUrl;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload multiple files and return their URLs
  Future<List<String>> uploadFiles(List<File> files) async {
    final uploadTasks = files.map((file) => uploadFile(file));
    return await Future.wait(uploadTasks);
  }

  /// Check if file type is allowed
  bool _isAllowedFileType(String extension) {
    return AppConstants.allowedImageTypes.contains(extension) ||
        AppConstants.allowedVideoTypes.contains(extension);
  }

  /// Get file category based on extension
  String _getFileCategory(String extension) {
    if (AppConstants.allowedImageTypes.contains(extension)) {
      return 'image';
    } else if (AppConstants.allowedVideoTypes.contains(extension)) {
      return 'video';
    }
    return 'other';
  }

  /// Handle API errors and convert to FileUploadException
  FileUploadException _handleError(DioException error) {
    final apiError = error.error;
    if (apiError is ApiError) {
      return FileUploadException(
        message: apiError.message,
        type: _mapErrorType(apiError.type),
        statusCode: apiError.statusCode,
      );
    }

    return FileUploadException(
      message: error.message ?? 'File upload failed',
      type: FileUploadErrorType.unknown,
    );
  }

  /// Map API error types to file upload error types
  FileUploadErrorType _mapErrorType(ApiErrorType apiErrorType) {
    switch (apiErrorType) {
      case ApiErrorType.network:
      case ApiErrorType.timeout:
        return FileUploadErrorType.network;
      case ApiErrorType.authentication:
        return FileUploadErrorType.authentication;
      case ApiErrorType.authorization:
        return FileUploadErrorType.authorization;
      case ApiErrorType.validation:
        return FileUploadErrorType.validation;
      case ApiErrorType.server:
        return FileUploadErrorType.serverError;
      default:
        return FileUploadErrorType.unknown;
    }
  }
}

/// Exception types for file upload operations
enum FileUploadErrorType {
  network,
  authentication,
  authorization,
  validation,
  fileTooLarge,
  invalidFileType,
  serverError,
  unknown,
}

/// Custom exception for file upload errors
class FileUploadException implements Exception {
  final String message;
  final FileUploadErrorType type;
  final int? statusCode;

  const FileUploadException({
    required this.message,
    required this.type,
    this.statusCode,
  });

  @override
  String toString() {
    return 'FileUploadException(type: $type, message: $message, statusCode: $statusCode)';
  }

  /// Check if error is related to network connectivity
  bool get isNetworkError => type == FileUploadErrorType.network;

  /// Check if error is related to file validation
  bool get isValidationError =>
      type == FileUploadErrorType.validation ||
      type == FileUploadErrorType.fileTooLarge ||
      type == FileUploadErrorType.invalidFileType;

  /// Check if error is a server error
  bool get isServerError => type == FileUploadErrorType.serverError;
}
