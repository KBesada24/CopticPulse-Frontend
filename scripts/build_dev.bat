@echo off
REM Development build script for Coptic Pulse (Windows)
REM This script enables dev features for testing

echo 🛠️ Building Coptic Pulse for Development...

echo 📋 Enabling development features...

REM Build debug APK with dev flags enabled
echo 🔨 Building debug APK with dev features...
flutter build apk --debug ^
  --dart-define=ENABLE_DEV_AUTH=true ^
  --dart-define=SHOW_DEV_INFO=true ^
  --dart-define=MOCK_API=true ^
  --dart-define=DEV_SERVER_URL=http://localhost:3000

if %ERRORLEVEL% neq 0 (
    echo ❌ Build failed!
    exit /b 1
)

echo ✅ Development build complete!
echo 📦 APK location: build\app\outputs\flutter-apk\app-debug.apk
echo 🔧 Dev features enabled - DO NOT USE FOR PRODUCTION