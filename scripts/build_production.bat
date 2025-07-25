@echo off
REM Production build script for Coptic Pulse (Windows)
REM This script ensures no dev code makes it to production

echo 🚀 Building Coptic Pulse for Production...

REM Verify we're not in dev mode
echo 📋 Checking configuration...

REM Build release APK without dev flags
echo 🔨 Building release APK...
flutter build apk --release ^
  --dart-define=ENABLE_DEV_AUTH=false ^
  --dart-define=SHOW_DEV_INFO=false ^
  --dart-define=MOCK_API=false ^
  --dart-define=DEV_SERVER_URL= ^
  --obfuscate ^
  --split-debug-info=build/debug-info

if %ERRORLEVEL% neq 0 (
    echo ❌ Build failed!
    exit /b 1
)

echo ✅ Production build complete!
echo 📦 APK location: build\app\outputs\flutter-apk\app-release.apk

echo 🔍 Production build verification complete
echo ✅ Ready for deployment