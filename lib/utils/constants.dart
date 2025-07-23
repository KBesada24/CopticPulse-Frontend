/// Application constants including API endpoints and configuration
class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://api.copticpulse.com'; // Replace with actual API URL
  static const String apiVersion = 'v1';
  static const String apiBaseUrl = '$baseUrl/api/$apiVersion';
  
  // API Endpoints
  static const String loginEndpoint = '$apiBaseUrl/auth/login';
  static const String refreshTokenEndpoint = '$apiBaseUrl/auth/refresh';
  static const String logoutEndpoint = '$apiBaseUrl/auth/logout';
  
  static const String postsEndpoint = '$apiBaseUrl/posts';
  static const String approvalsEndpoint = '$apiBaseUrl/admin/approvals';
  static const String liturgyEventsEndpoint = '$apiBaseUrl/liturgy-events';
  static const String sermonsEndpoint = '$apiBaseUrl/sermons';
  static const String usersEndpoint = '$apiBaseUrl/users';
  static const String uploadEndpoint = '$apiBaseUrl/upload';
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_preference';
  
  // App Configuration
  static const String appName = 'Coptic Pulse';
  static const String appVersion = '1.0.0';
  static const int requestTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedVideoTypes = ['mp4', 'mov', 'avi'];
  
  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 1);
  static const String cacheVersion = '1.0';
  
  // Database Configuration
  static const String databaseName = 'coptic_pulse.db';
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