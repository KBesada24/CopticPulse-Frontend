import '../config/environment.dart';

/// Application constants including API endpoints and configuration
class AppConstants {
  // API Configuration - Uses environment-specific URLs
  static String get apiBaseUrl => EnvironmentConfig.apiBaseUrl;
  
  // API Endpoints - Dynamic based on environment
  static String get loginEndpoint => '$apiBaseUrl/auth/login';
  static String get refreshTokenEndpoint => '$apiBaseUrl/auth/refresh';
  static String get logoutEndpoint => '$apiBaseUrl/auth/logout';
  
  static String get postsEndpoint => '$apiBaseUrl/posts';
  static String get approvalsEndpoint => '$apiBaseUrl/admin/approvals';
  static String get liturgyEventsEndpoint => '$apiBaseUrl/liturgy-events';
  static String get sermonsEndpoint => '$apiBaseUrl/sermons';
  static String get usersEndpoint => '$apiBaseUrl/users';
  static String get uploadEndpoint => '$apiBaseUrl/upload';
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_preference';
  
  // App Configuration
  static const String appName = 'Coptic Pulse';
  static const String appVersion = '1.0.0';
  static int get requestTimeoutSeconds => EnvironmentConfig.requestTimeout.inSeconds;
  static int get maxRetryAttempts => EnvironmentConfig.backendConfig.retryAttempts;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedVideoTypes = ['mp4', 'mov', 'avi'];
  
  // Cache Configuration
  static Duration get cacheExpiration => EnvironmentConfig.cacheExpiration;
  static const String cacheVersion = '1.0';
  
  // Database Configuration
  static String get databaseName => EnvironmentConfig.databaseName;
  static const int databaseVersion = 1;
  
  // Post Types
  static const String postTypeAnnouncement = 'announcement';
  static const String postTypeEvent = 'event';
  static const String postTypePrayerRequest = 'prayer_request';
  
  // Post Status
  static const String postStatusDraft = 'draft';
  static const String postStatusPending = 'pending';
  static const String postStatusApproved = 'approved';
  static const String postStatusRejected = 'rejected';
  
  // User Roles
  static const String roleMember = 'member';
  static const String roleAdministrator = 'administrator';
  
  // Error Messages
  static const String networkErrorMessage = 'Network connection error. Please check your internet connection.';
  static const String serverErrorMessage = 'Server error. Please try again later.';
  static const String authErrorMessage = 'Authentication failed. Please login again.';
  static const String validationErrorMessage = 'Please check your input and try again.';
  static const String unknownErrorMessage = 'An unexpected error occurred. Please try again.';
}