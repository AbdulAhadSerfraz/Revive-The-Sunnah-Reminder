# Revive Sunnah Reminder - Deployment Guide

## Overview

This document provides comprehensive instructions for deploying the Revive Sunnah Reminder app to production environments, including app stores and distribution platforms.

## Prerequisites

### Development Environment
- Flutter SDK 3.24.0 or higher
- Dart SDK 3.4.0 or higher
- Android Studio with Android SDK
- Xcode (for iOS builds)
- Java JDK 17
- Git

### Required Accounts
- Google Play Console account
- Apple Developer account
- Firebase project
- GitHub account (for CI/CD)

### Certificates and Keys
- Android signing keystore
- iOS distribution certificates
- Firebase service account keys
- App Store Connect API keys

## Build Configuration

### Environment Variables

Create a `.env` file in the project root:

```env
# App Configuration
APP_NAME=Revive - The Sunnah Reminder
APP_VERSION=1.0.0
BUILD_NUMBER=1

# API Configuration
API_BASE_URL=https://api.reviveapp.com
API_KEY=your_api_key_here

# Firebase Configuration
FIREBASE_PROJECT_ID=revive-sunnah-reminder
FIREBASE_API_KEY=your_firebase_api_key

# Analytics
GOOGLE_ANALYTICS_ID=GA-XXXXXXXXX
FIREBASE_ANALYTICS_ENABLED=true

# Feature Flags
ENABLE_CRASHLYTICS=true
ENABLE_PERFORMANCE_MONITORING=true
ENABLE_REMOTE_CONFIG=true
```

### Build Scripts

Create `scripts/build.sh`:

```bash
#!/bin/bash

# Build script for production deployment

set -e

echo \"Starting production build...\"

# Clean previous builds
flutter clean
flutter pub get

# Generate required files
dart run build_runner build --delete-conflicting-outputs

# Build for Android
echo \"Building Android...\"
flutter build appbundle --release --build-name=$APP_VERSION --build-number=$BUILD_NUMBER
flutter build apk --release --build-name=$APP_VERSION --build-number=$BUILD_NUMBER

# Build for iOS (if on macOS)
if [[ \"$OSTYPE\" == \"darwin\"* ]]; then
    echo \"Building iOS...\"
    flutter build ios --release --build-name=$APP_VERSION --build-number=$BUILD_NUMBER
fi

echo \"Build completed successfully!\"
```

## Android Deployment

### 1. Keystore Setup

Generate a signing keystore:

```bash
keytool -genkey -v -keystore android/app/keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias revive-key
```

Create `android/key.properties`:

```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=revive-key
storeFile=keystore.jks
```

### 2. Build Configuration

Update `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId \"com.reviveapp.sunnah_reminder\"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
        multiDexEnabled true
    }
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 3. Google Play Store Upload

1. Create app listing in Google Play Console
2. Upload app bundle:
   ```bash
   flutter build appbundle --release
   ```
3. Configure store listing:
   - App name: Revive - The Sunnah Reminder
   - Short description: Daily Sunnah reminders for Muslims
   - Full description: [Use marketing copy]
   - Screenshots: Prepare for different device sizes
   - Privacy Policy URL
   - Terms of Service URL

4. Set up release tracks:
   - Internal testing
   - Closed testing (alpha/beta)
   - Open testing
   - Production

## iOS Deployment

### 1. Certificate Setup

1. Create App ID in Apple Developer Console
2. Generate distribution certificate
3. Create provisioning profile for distribution
4. Configure Xcode project settings

### 2. Build Configuration

Update `ios/Runner/Info.plist`:

```xml
<key>CFBundleDisplayName</key>
<string>Revive</string>
<key>CFBundleIdentifier</key>
<string>com.reviveapp.sunnahReminder</string>
<key>CFBundleVersion</key>
<string>$(BUILD_NUMBER)</string>
<key>CFBundleShortVersionString</key>
<string>$(APP_VERSION)</string>
```

### 3. App Store Upload

1. Build archive:
   ```bash
   flutter build ios --release
   ```

2. Open Xcode and create archive
3. Upload to App Store Connect
4. Configure app listing:
   - App name
   - Subtitle
   - Description
   - Keywords
   - Screenshots
   - App preview videos
   - Privacy information

## Firebase Setup

### 1. Project Configuration

1. Create Firebase project
2. Add Android and iOS apps
3. Download configuration files:
   - `google-services.json` for Android
   - `GoogleService-Info.plist` for iOS

### 2. Services Configuration

```yaml
# pubspec.yaml dependencies
dependencies:
  firebase_core: ^2.24.2
  firebase_analytics: ^10.7.4
  firebase_crashlytics: ^3.4.8
  firebase_performance: ^0.9.3+8
  firebase_remote_config: ^4.3.8
```

### 3. Initialize Firebase

```dart
// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const ReviveApp());
}
```

## CI/CD Pipeline

### GitHub Actions Secrets

Configure the following secrets in GitHub repository:

```
# Android
KEYSTORE_BASE64=<base64-encoded-keystore>
KEYSTORE_PASSWORD=<keystore-password>
KEY_PASSWORD=<key-password>
KEY_ALIAS=<key-alias>
GOOGLE_PLAY_SERVICE_ACCOUNT=<service-account-json>

# iOS
MATCH_PASSWORD=<fastlane-match-password>
FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD=<app-specific-password>

# Firebase
FIREBASE_APP_ID=<firebase-app-id>
FIREBASE_SERVICE_ACCOUNT=<firebase-service-account-json>

# Notifications
SLACK_WEBHOOK=<slack-webhook-url>
```

### Deployment Workflow

1. **Development**: Push to `develop` branch
   - Runs tests and analysis
   - Builds debug versions
   - Deploys to Firebase App Distribution

2. **Staging**: Create PR to `main`
   - Runs full test suite
   - Performance testing
   - Security scanning

3. **Production**: Create GitHub release
   - Builds signed release versions
   - Uploads to app stores
   - Sends notifications

## Monitoring and Analytics

### 1. Firebase Analytics

```dart
// Track user events
FirebaseAnalytics.instance.logEvent(
  name: 'sunnah_completed',
  parameters: {
    'sunnah_id': sunnahId,
    'category': category,
    'completion_time': DateTime.now().millisecondsSinceEpoch,
  },
);
```

### 2. Crashlytics

```dart
// Report errors
FirebaseCrashlytics.instance.recordError(
  error,
  stackTrace,
  fatal: false,
);
```

### 3. Performance Monitoring

```dart
// Track performance
final trace = FirebasePerformance.instance.newTrace('sunnah_load');
trace.start();
// ... load sunnah data
trace.stop();
```

## Post-Deployment Checklist

### Immediate (Day 1)
- [ ] Verify app store listings are live
- [ ] Test download and installation
- [ ] Monitor crash reports
- [ ] Check analytics data flow
- [ ] Verify push notifications
- [ ] Test core user flows

### Short-term (Week 1)
- [ ] Monitor user feedback and reviews
- [ ] Track key performance indicators
- [ ] Monitor server performance
- [ ] Check database performance
- [ ] Review security logs

### Long-term (Month 1)
- [ ] Analyze user behavior patterns
- [ ] Plan feature updates
- [ ] Optimize based on analytics
- [ ] Update documentation
- [ ] Security audit

## Rollback Procedure

### Android
1. Halt rollout in Google Play Console
2. Remove problematic version
3. Promote previous stable version

### iOS
1. Remove app from App Store Connect
2. Submit previous version for review
3. Expedite review if critical

### Emergency Contacts

```
Developer: [Your Email]
DevOps: [DevOps Email]
Product Manager: [PM Email]
Support: support@reviveapp.com
```

## Security Considerations

### Data Protection
- All user data encrypted at rest
- API communications over HTTPS
- No sensitive data in logs
- Regular security updates

### Privacy Compliance
- GDPR compliance for EU users
- CCPA compliance for California users
- Privacy policy clearly displayed
- User consent for data collection

### App Security
- Code obfuscation enabled
- Root/jailbreak detection
- Certificate pinning
- Regular dependency updates

## Support and Maintenance

### Documentation
- Keep deployment docs updated
- Maintain runbooks for common issues
- Document configuration changes
- Version control all deployment scripts

### Monitoring
- Set up alerts for critical issues
- Monitor app performance metrics
- Track user satisfaction scores
- Regular security scans

### Updates
- Monthly dependency updates
- Quarterly security reviews
- Bi-annual architecture reviews
- Annual security audits

---

**Version**: 1.0.0  
**Last Updated**: $(date)  
**Maintained By**: Development Team"