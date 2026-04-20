# 🚀 MobiFund - Google Play Store Upload Guide

## STATUS: READY FOR SIGNING & UPLOAD SETUP

---

## ✅ WHAT'S BEEN CONFIGURED

1. **Release Build Signing** - Updated `android/app/build.gradle.kts`
   - Configured to load signing credentials from `key.properties`
   - R8 minification enabled (code obfuscation)
   - ProGuard rules added for safe obfuscation

2. **ProGuard Rules** - Created `android/app/proguard-rules.pro`
   - Preserves critical Flutter, Supabase, and app code
   - Removes debug logging for release builds
   - Safe obfuscation for native libraries

3. **App Configuration**
   - Package name: `com.mobiwave.mobifund`
   - Min SDK: 21 (Android 5.1+)
   - Version: 1.0.0+1
   - Permissions: INTERNET, ACCESS_NETWORK_STATE

---

## 🔴 IMMEDIATE SETUP (Before Upload)

### Step 1: Create Release Signing Key (ONE TIME)

```bash
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias mobifund
```

**Important:** 
- Save the passwords in a safe place (not in version control)
- The key is valid for ~27 years (10000 days)
- You'll need these passwords every time you build a release

### Step 2: Create `android/key.properties` File

Create file: **`android/key.properties`** (add to .gitignore!)

```properties
storePassword=YOUR_STORE_PASSWORD_HERE
keyPassword=YOUR_KEY_PASSWORD_HERE
keyAlias=mobifund
storeFile=../../key.jks
```

**SECURITY:** Add to `.gitignore` - NEVER commit this file!

```bash
echo "android/key.properties" >> .gitignore
```

### Step 3: Build Release Bundle

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

Output will be at: `build/app/outputs/bundle/release/app-release.aab`

---

## 📋 PLAY STORE LISTING REQUIREMENTS

Before uploading to Play Store, you need:

### App Content
- [ ] **App Icon** (512x512 PNG - use your logo_mark.png)
- [ ] **Screenshots** (2-8 images showing app features)
- [ ] **Feature Graphic** (1024x500 PNG for store listing)
- [ ] **App Description** (4000 chars max)
- [ ] **Short Description** (80 chars max)

### Privacy & Policies
- [ ] **Privacy Policy URL** - Host your privacy policy online
- [ ] **Terms of Service URL** - Host your terms online
- [ ] **Support Email** - e.g., support@mobiwave.com
- [ ] **Support Website** - e.g., https://mobiwave.com

### Content Rating
Fill out questionnaire addressing:
- Financial & Payment Information (CRITICAL - handles money)
- Unrestricted Internet Access
- Purchases with Real Money (M-Pesa integration)

### Category & Targeting
- **Category:** Finance
- **Content Rating:** Based on questionnaire
- **Android 5.1+** (API 21+) - Already configured

---

## 🔐 SECURITY CHECKLIST

Before publishing:

- [ ] Release build is signed (not debug-signed)
- [ ] Test APK thoroughly on multiple devices
- [ ] Verify no hardcoded secrets in code
- [ ] `.env` file is in `.gitignore`
- [ ] `android/key.properties` is in `.gitignore`
- [ ] Firebase keys (if used) are properly configured
- [ ] API credentials are externalized, not hardcoded
- [ ] HTTPS only (usesCleartextTraffic=false)

---

## 🧪 TESTING BEFORE UPLOAD

### Create Test Release Build (Local)

```bash
# Build APK for testing
flutter build apk --release

# Or build AAB (what Play Store uses)
flutter build appbundle --release
```

### Test on Real Device
- [ ] Login works with test account
- [ ] M-Pesa integration functions (or sandbox)
- [ ] SMS sending works (or test mode)
- [ ] Data sync completes
- [ ] No crashes or ANRs (Application Not Responding)
- [ ] All screens render correctly
- [ ] Offline mode works
- [ ] Permissions are requested appropriately

### Check for Issues
```bash
# Run flutter analyze
flutter analyze

# Check build log for warnings
flutter build appbundle --release 2>&1 | grep -i warning
```

---

## 📈 VERSION MANAGEMENT

Each upload needs a version bump:

```yaml
# pubspec.yaml
version: 1.0.0+1    # Format: semantic+buildNumber
#        ^^^^^^^ release version
#            ^^^ build number (must increment)
```

Examples for each release:
- First release: `1.0.0+1`
- Bug fix: `1.0.1+2`
- New features: `1.1.0+3`
- Major update: `2.0.0+4`

---

## 🎯 PLAY STORE UPLOAD PROCESS

### Via Web Console (play.google.com/console)

1. **Sign in** to Google Play Console
2. **Create app** (if first time) or select MobiFund
3. **Go to Releases → Production**
4. **Upload AAB file** from `build/app/outputs/bundle/release/app-release.aab`
5. **Fill in all store listing details**
6. **Add screenshots and graphics**
7. **Add privacy policy & terms URLs**
8. **Set pricing** (Free or Paid)
9. **Select target countries**
10. **Submit for review**

### Expected Review Time
- First release: 24-48 hours
- Updates: Usually faster (few hours)

---

## ✨ ENHANCEMENTS TO CONSIDER

For future versions:

- [ ] Add Firebase Crashlytics for error tracking
- [ ] Implement in-app billing (if monetizing)
- [ ] Add analytics (Firebase Analytics)
- [ ] Implement auto-update checking
- [ ] Add push notifications (Firebase Cloud Messaging)
- [ ] Implement app reviews prompt

---

## 📞 SUPPORT RESOURCES

- Flutter Build Docs: https://flutter.dev/docs/deployment/android
- Play Store Console: https://play.google.com/console
- Play Store Policies: https://support.google.com/googleplay/android-developer/

---

## ⚠️ COMMON MISTAKES TO AVOID

❌ **DON'T:**
- Upload with debug signing
- Commit `key.properties` to Git
- Use hardcoded API keys
- Skip ProGuard/R8 minification
- Upload without testing
- Include test/dummy data
- Use cleartext traffic
- Forget to bump version code

✅ **DO:**
- Keep signing key secure
- Test thoroughly before uploading
- Use environment variables for secrets
- Update version for each release
- Provide clear app description
- Include working privacy policy URL
- Monitor Play Store reviews
- Respond to user feedback

