# Developer Login Guide

This guide explains how to use the developer authentication system for testing the Coptic Pulse app.

## Overview

The app includes a developer authentication mode that bypasses the real API and allows you to login with predefined test credentials. This is perfect for development and testing without needing a backend server.

## How to Enable/Disable Dev Mode

Dev mode is controlled by the `DevConfig.enableDevAuth` flag in `lib/utils/dev_config.dart`:

```dart
static const bool enableDevAuth = true;  // Set to false for production
```

## Available Test Credentials

When dev mode is enabled, you can use any of these predefined accounts:

### Admin User (Administrator Role)
- **Email:** `admin@copticpulse.com`
- **Password:** `admin123`
- **Role:** Administrator
- **Name:** Father John
- **Features:** Access to admin dashboard, all member features

### Member User (Member Role)
- **Email:** `member@copticpulse.com`
- **Password:** `member123`
- **Role:** Member
- **Name:** Mary Smith
- **Features:** Standard member access, profile screen

### Developer User (Administrator Role)
- **Email:** `dev@test.com`
- **Password:** `dev123`
- **Role:** Administrator
- **Name:** Developer User
- **Features:** Same as admin, designed for development testing

## How to Login

### Method 1: Use the Dev Credentials Card (Recommended)
1. Launch the app in debug mode
2. On the login screen, you'll see a blue "Development Mode" card
3. Click the copy icon (📋) next to any credential set
4. The email and password will be automatically filled in
5. Tap "Login"

### Method 2: Manual Entry
1. Launch the app
2. Enter one of the email addresses above
3. Enter the corresponding password
4. Tap "Login"

### Method 3: Check Console Output
When the app starts, the console will display:
```
=== COPTIC PULSE DEV LOGIN CREDENTIALS ===
Admin User: admin@copticpulse.com / admin123
Member User: member@copticpulse.com / member123
Developer User: dev@test.com / dev123
==========================================
```

## Features in Dev Mode

- **No Network Calls:** All authentication happens locally
- **Instant Login:** No waiting for API responses
- **Persistent Sessions:** Login state is saved using secure storage
- **Role-Based Navigation:** Different UI based on user role
- **Mock Tokens:** Generates fake JWT tokens for testing

## Testing Different User Roles

### As Administrator (`admin@copticpulse.com` or `dev@test.com`)
- Bottom navigation shows: Community, Liturgy, Sermons, **Admin**
- Access to admin dashboard
- User menu includes "Settings" option

### As Member (`member@copticpulse.com`)
- Bottom navigation shows: Community, Liturgy, Sermons, **Profile**
- Standard member features only
- No admin-specific options

## Switching Between Users

1. Tap the user icon in the app bar (top right)
2. Select "Logout"
3. Login with different credentials to test different roles

## Troubleshooting

### Login Not Working
- Make sure `DevConfig.enableDevAuth = true` in `lib/utils/dev_config.dart`
- Check that you're using the exact email addresses (case-insensitive)
- Verify the passwords match exactly (case-sensitive)

### Dev Card Not Showing
- Ensure `DevConfig.showDevInfo = true` in the config
- Make sure you're running in debug mode
- Check that dev mode is enabled

### Console Credentials Not Showing
- Look for the credentials in the debug console when the app starts
- Make sure you're running `flutter run --debug`

## Production Deployment

**IMPORTANT:** Before deploying to production:

1. Set `DevConfig.enableDevAuth = false`
2. Set `DevConfig.showDevInfo = false`
3. Test that the real authentication system works
4. Remove or comment out dev credential printing

## Adding New Test Users

To add more test users, edit the `_testUsers` map in `lib/services/dev_auth_service.dart`:

```dart
static const Map<String, Map<String, dynamic>> _testUsers = {
  'your-email@test.com': {
    'password': 'your-password',
    'user': {
      'id': '4',
      'email': 'your-email@test.com',
      'name': 'Your Name',
      'role': 'member', // or 'administrator'
    }
  },
  // ... existing users
};
```

## Security Notes

- Dev credentials are hardcoded and should never be used in production
- Mock tokens are not real JWT tokens and provide no actual security
- Dev mode bypasses all real authentication and authorization
- Always disable dev mode before production deployment