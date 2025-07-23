import 'package:flutter/material.dart';
import 'package:coptic_pulse/utils/constants.dart';

/// Utility helper functions for the Coptic Pulse app
class AppHelpers {
  /// Show a snackbar with a message
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  /// Show a loading dialog
  static void showLoadingDialog(BuildContext context, {String message = 'Loading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }
  
  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
  
  /// Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
  
  /// Format date for display
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
  
  /// Format time for display
  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '$displayHour:$minute $period';
  }
  
  /// Format date and time for display
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} at ${formatTime(dateTime)}';
  }
  
  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  /// Validate password strength
  static bool isValidPassword(String password) {
    // At least 8 characters, contains letters and numbers
    return password.length >= 8 && 
           RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(password);
  }
  
  /// Get file extension from filename
  static String getFileExtension(String filename) {
    return filename.split('.').last.toLowerCase();
  }
  
  /// Check if file is an allowed image type
  static bool isAllowedImageType(String filename) {
    final extension = getFileExtension(filename);
    return AppConstants.allowedImageTypes.contains(extension);
  }
  
  /// Check if file is an allowed video type
  static bool isAllowedVideoType(String filename) {
    final extension = getFileExtension(filename);
    return AppConstants.allowedVideoTypes.contains(extension);
  }
  
  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
  
  /// Get post type display name
  static String getPostTypeDisplayName(String postType) {
    switch (postType) {
      case AppConstants.postTypeAnnouncement:
        return 'Announcement';
      case AppConstants.postTypeEvent:
        return 'Event';
      case AppConstants.postTypePrayerRequest:
        return 'Prayer Request';
      default:
        return 'Post';
    }
  }
  
  /// Get post status display name
  static String getPostStatusDisplayName(String postStatus) {
    switch (postStatus) {
      case AppConstants.postStatusDraft:
        return 'Draft';
      case AppConstants.postStatusPending:
        return 'Pending Approval';
      case AppConstants.postStatusApproved:
        return 'Approved';
      case AppConstants.postStatusRejected:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }
  
  /// Get post status color
  static Color getPostStatusColor(String postStatus) {
    switch (postStatus) {
      case AppConstants.postStatusDraft:
        return Colors.grey;
      case AppConstants.postStatusPending:
        return Colors.orange;
      case AppConstants.postStatusApproved:
        return Colors.green;
      case AppConstants.postStatusRejected:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  /// Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }
  
  /// Capitalize first letter of each word
  static String capitalizeWords(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}