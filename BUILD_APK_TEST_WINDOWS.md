# BlindMeet - Build APK & Test on Windows Guide

Complete step-by-step guide to build APK and test locally on Windows. This is the fastest way to get your app running on a real Android phone for testing.

---

# SECTION 1: BUILD APK FILE

## ✅ Prerequisites Check

Before building, verify you have:

### 1. Flutter Installed
```powershell
flutter --version
# Should show: Flutter 3.10.0 or higher
```

### 2. Android SDK Installed
```powershell
flutter doctor

# You should see:
# ✓ Flutter (version...)
# ✓ Android toolchain - develop for Android devices
# ✓ [Android SDK] (android-sdk version...)
```

### 3. Java Development Kit (JDK)
```powershell
java -version
# Should show: Java version 11 or higher
```

### 4. PostgreSQL Running (for backend)
```powershell
# Windows: Services → PostgreSQL → Running
# Or command:
psql -U postgres
# Commands:
# \q (to exit)
```

### 5. Backend Running
```powershell
# Open new PowerShell window
cd backend
npm run dev
# Should show: 🚀 BlindMeet Backend running on port 5000
```

**If Flutter Doctor shows issues:**
```powershell
flutter doctor --android-licenses
# Type 'y' for all prompts to accept Android licenses
```

---

## 🔑 Step 1: Create Keystore (Signing Key)

This is required to sign your APK. You only do this ONCE.

### Check if keystore already exists
```powershell
cd frontend/android/app

# Check if blindmeet.jks exists
dir blindmeet.jks.*
# If it exists, skip to Step 2
```

### Generate New Keystore
```powershell
cd frontend/android/app

# Generate keystore file
keytool -genkey -v -keystore blindmeet.jks `
  -keyalg RSA -keysize 2048 -validity 10000 `
  -alias blindmeet-key

# You'll be prompted to enter:
```

**When prompted, enter:**
```
Keystore password:                    MyBlindMeet@123
Key password:                         MyBlindMeet@123  (same as above)
First and Last Name:                  BlindMeet App
Organizational Unit:                  Development
Organization:                         BlindMeet
City/Locality:                        New York
State/Province:                       NY
Country Code:                         US
```

**Result**: Creates `blindmeet.jks` file in `frontend/android/app/`

```powershell
# Verify file created
dir blindmeet.jks
# Shows: blindmeet.jks (about 2.5 KB)
```

---

## 🔧 Step 2: Configure Signing in build.gradle

### Open the file
```powershell
cd frontend/android/app

# Open with Notepad or VS Code
code build.gradle
```

### Find and Edit the gradle file

**Look for this section:**
```gradle
signingConfigs {
    release {
        keyAlias 'blindmeet-key'
        keyPassword 'MyBlindMeet@123'
        storeFile file('blindmeet.jks')
        storePassword 'MyBlindMeet@123'
    }
}
```

**Replace with:**
```gradle
signingConfigs {
    release {
        keyAlias 'blindmeet-key'
        keyPassword 'MyBlindMeet@123'
        storeFile file('blindmeet.jks')
        storePassword 'MyBlindMeet@123'
    }
}
```

**Also ensure buildTypes → release has this:**
```gradle
buildTypes {
    release {
        signingConfig signingConfigs.release
        // Keep shrinkResources and minifyEnabled if they exist
        minifyEnabled false
        shrinkResources false
    }
}
```

**Save the file** (Ctrl + S)

---

## 📦 Step 3: Build Release APK

### Navigate to frontend folder
```powershell
cd frontend
```

### Clean Flutter build
```powershell
flutter clean
```

### Get dependencies
```powershell
flutter pub get
```

### Build APK
```powershell
flutter build apk --release

# This will take 5-15 minutes depending on your PC
# Shows progress like:
# ✓ Built build\app\outputs\flutter-apk\app-release.apk
```

### Result
```
APK Location: frontend\build\app\outputs\flutter-apk\app-release.apk
File Size: 50-80 MB
```

---

## ✅ Verify APK Created

```powershell
# Check if file exists
dir frontend\build\app\outputs\flutter-apk\app-release.apk

# Shows something like:
# Mode    LastWriteTime         Length Name
# ----    -------                ------ ----
# -a---   5/16/2026 2:30 PM    73456789 app-release.apk
```

**✅ APK is ready!** You can now:
1. Copy to your phone
2. Test on emulator
3. Share with others

---

---

# SECTION 2: INSTALL & TEST ON ANDROID EMULATOR (Windows)

## Option A: Android Emulator (Built-in)

### Step 1: Check Available Emulators
```powershell
flutter emulators

# Shows available emulators:
# emulator • pixel_4_api_32 • ...  (Started)
# emulator • pixel_5_api_31 • ...
```

### Step 2: Launch Emulator
```powershell
# If already running, skip this
# Otherwise, launch one:
flutter emulators --launch pixel_4_api_32

# Wait 2-3 minutes for emulator to fully start
# You should see Android home screen
```

### Step 3: Install APK on Emulator
```powershell
cd frontend

# Method 1: Using Flutter
flutter install build\app\outputs\flutter-apk\app-release.apk

# Method 2: Using ADB (Android Debug Bridge)
adb install -r build\app\outputs\flutter-apk\app-release.apk
```

### Step 4: Run the App on Emulator
```powershell
# After installation, app should auto-launch
# Or type:
flutter run build\app\outputs\flutter-apk\app-release.apk
```

### Step 5: Test the App
On emulator:
1. ✅ See Splash Screen (3 seconds)
2. ✅ See Login Screen
3. ✅ See "Sign in with Google" button
4. ✅ Click to test login flow
5. ✅ Create profile
6. ✅ Navigate tabs (Discover, Chat, etc.)

---

## Option B: Genymotion (Faster Alternative)

### Download & Install
```
1. Go to https://www.genymotion.com/download/
2. Download Genymotion Desktop
3. Install on Windows
4. Create account (free tier available)
```

### Launch & Install APK
```powershell
# Start Genymotion, choose device, click Play

# In Genymotion, drag and drop APK file
# Or use:
adb install -r build\app\outputs\flutter-apk\app-release.apk
```

**Note**: Genymotion is 2-3x faster than default emulator

---

---

# SECTION 3: INSTALL ON REAL ANDROID PHONE (Windows)

## Step 1: Enable Developer Mode on Phone

### On Your Android Phone:
```
1. Settings → About Phone
2. Find "Build Number"
3. Tap it 7 times (you'll see "Developer mode enabled" message)
4. Go back to Settings
5. Settings → Developer Options
6. Enable "USB Debugging"
7. Enable "USB Debugging (Security settings)"
8. Accept the security prompt
```

---

## Step 2: Connect Phone to Windows PC

### Using USB Cable:
```
1. Connect Android phone to Windows PC with USB cable
2. Phone will show: "Allow USB debugging from this computer?"
3. Tap: Always allow from this computer
4. Click OK
```

### Verify Connection:
```powershell
adb devices

# Shows:
# adb server version (41) doesn't match this client (57); killing...
# * daemon started successfully
# List of attached devices:
# emulator-5554   device
# 3456789ABCDE    device  (your phone)
```

---

## Step 3: Install APK on Real Phone

```powershell
cd frontend

adb install -r build\app\outputs\flutter-apk\app-release.apk

# Shows progress:
# adb: error: cannot stat 'build\app\outputs\flutter-apk\app-release.apk': ...
# (if error, check file path)

# Success shows:
# Success
# Installing app...
# Done. App installed successfully.
```

---

## Step 4: Open App on Phone

### Option 1: Auto-launch
```powershell
flutter run
# App automatically launches on connected device
```

### Option 2: Manual Launch
```
1. Unlock your phone
2. Look for "BlindMeet" app icon
3. Tap to open
4. App launches with Splash Screen
```

---

## Step 5: Test on Real Phone

✅ **Verify These:**

1. **Splash Screen** - 3 second animation
2. **Login Screen** - Glassmorphism background, "Sign in with Google" button
3. **Google Login** - Click button → prompts Google auth
4. **Profile Creation** - Fill profile form
5. **Home Screen** - Bottom navigation with 4 tabs
6. **Discover Tab** - Browse users
7. **Chat Tab** - See conversations
8. **Send Message** - Real-time updates
9. **Typing Indicator** - Shows "User is typing..."
10. **Online Status** - Shows user status

---

---

# SECTION 4: TROUBLESHOOTING & COMMON ERRORS

## Issue: "Cannot find keytool command"

**Solution:**
```powershell
# Find Java installation
where java

# If not found, install Java JDK 11+
# Download from: https://adoptopenjdk.net/

# After installing, restart PowerShell and try again
keytool -version
```

---

## Issue: "build.gradle file not found"

**Solution:**
```powershell
# Make sure you're in correct folder
cd frontend/android/app

# Verify file exists
dir build.gradle

# If not found, your Flutter project may be corrupted
# Try:
flutter clean
flutter pub get
cd ios && pod install && cd ..
```

---

## Issue: "Keystore password was incorrect"

**Solution:**
```powershell
# Make sure passwords match exactly as entered
# Demo: MyBlindMeet@123 (case sensitive, special characters matter)

# If you forgot password, regenerate:
cd frontend/android/app
del blindmeet.jks
# Then re-run keytool command
```

---

## Issue: "APK build fails"

**Solution:**
```powershell
# Try in order:
flutter clean                          # Clear cache
flutter pub get                        # Reinstall packages
flutter pub upgrade                    # Update packages
flutter build apk --release -v         # Rebuild with verbose output

# Check output for specific error
# Common: Android SDK missing → flutter doctor
```

---

## Issue: "App crashes after launch"

**Solution:**
```powershell
# Check backend is running
curl http://localhost:5000/health

# If not running:
cd backend
npm run dev

# Check logs on device:
flutter logs

# Look for red error messages
```

---

## Issue: "Cannot connect to emulator"

**Solution:**
```powershell
# List devices
flutter devices

# If empty, launch emulator:
flutter emulators --launch pixel_4_api_32

# Wait 3 minutes for startup

# Try again:
flutter devices
flutter run
```

---

## Issue: "ADB: Permission denied"

**Solution:**
```powershell
# Restart ADB daemon
adb kill-server
adb start-server

# Reconnect phone and try again
adb devices
```

---

## Issue: "APK too large (over 100MB)"

**Solution:**
```powershell
# APK is usually 50-80MB, if larger:
# In build.gradle, ensure:
minifyEnabled true        # Enable code shrinking
shrinkResources true      # Shrink resources

# Then rebuild
flutter build apk --release --split-per-abi
```

---

---

# SECTION 5: LOCAL TESTING ON WINDOWS (No Device/Emulator)

## Option 1: Flutter Web (Desktop Browser Testing)

### Build Flutter Web
```powershell
cd frontend
flutter build web --release
```

### Run in Browser
```powershell
cd frontend
flutter run -d chrome

# Opens http://localhost:YOUR_PORT in Chrome
# You can test UI and navigation
# Note: Some mobile-specific features won't work
```

### Test Features:
✅ Login flow  
✅ Navigation  
✅ UI responsiveness  
❌ Push notifications  
❌ Mobile sensors  

---

## Option 2: Android Emulator on Windows

### Already covered in Section 2 above

---

## Option 3: Windows App (Experimental)

### Build for Windows Desktop
```powershell
cd frontend
flutter run -d windows

# Requires Windows dev setup
# May have compatibility issues with mobile features
```

---

---

# QUICK START (TL;DR)

## 1-Minute Setup
```powershell
# Terminal 1: Backend
cd backend
npm run dev

# Terminal 2: Frontend - Build APK
cd frontend
flutter clean
flutter pub get
flutter build apk --release

# APK ready at: frontend\build\app\outputs\flutter-apk\app-release.apk
```

## Install on Emulator (5 minutes)
```powershell
# Terminal 3: Install
adb install -r frontend\build\app\outputs\flutter-apk\app-release.apk

# See app open on emulator automatically
```

## Install on Real Phone (5 minutes)
```powershell
# 1. Connect phone via USB
# 2. Enable USB Debugging on phone
# 3. Run:
adb install -r frontend\build\app\outputs\flutter-apk\app-release.apk

# 4. App appears on phone home screen
# 5. Tap to open
```

---

# COMPLETE CHECKLIST

### Before Building
- [ ] Flutter installed: `flutter --version`
- [ ] Flutter doctor shows all ✓: `flutter doctor`
- [ ] Backend running: `npm run dev` in backend folder
- [ ] PostgreSQL running
- [ ] Firebase credentials in place

### Building APK
- [ ] Create keystore (one-time): `keytool -genkey...`
- [ ] Configure signing in build.gradle
- [ ] Run: `flutter build apk --release`
- [ ] Wait 10-15 minutes
- [ ] Verify APK exists

### Testing on Emulator
- [ ] Launch emulator: `flutter emulators --launch pixel_4_api_32`
- [ ] Wait for Android home screen
- [ ] Install APK: `adb install -r app-release.apk`
- [ ] App launches automatically
- [ ] Test login and features

### Testing on Real Phone
- [ ] Enable USB Debugging on phone
- [ ] Connect phone via USB cable
- [ ] Verify connection: `adb devices`
- [ ] Install APK: `adb install -r app-release.apk`
- [ ] Unlock phone and find app icon
- [ ] Open app and test features

### After Testing
- [ ] Note any bugs/issues
- [ ] Check device logs: `flutter logs`
- [ ] Fix issues in code
- [ ] Rebuild and redeploy

---

# IMPORTANT NOTES

1. **Keystore Password**: Save this password! You'll need it for every build.
   ```
   Password: MyBlindMeet@123
   ```

2. **APK Size**: 50-80 MB is normal for Flutter apps with packages

3. **Backend Required**: App will crash without backend running at `http://localhost:5000`

4. **Firebase**: Make sure Firebase credentials are in place

5. **USB Debugging**: Must be enabled on phone for direct installation

6. **Build Time**: First build takes 10-15 minutes, subsequent builds 3-5 minutes

---

# USEFUL COMMANDS

```powershell
# Check Flutter setup
flutter doctor

# List connected devices
adb devices

# View device logs
flutter logs

# Install APK
adb install -r app-release.apk

# Uninstall app from device
adb uninstall com.blindmeet.app

# Forward device port
adb forward tcp:8080 tcp:8080

# Restart ADB
adb kill-server
adb start-server

# View directory contents
dir frontend\build\app\outputs\flutter-apk\

# Copy APK to shared location
copy frontend\build\app\outputs\flutter-apk\app-release.apk "C:\Users\YourName\Downloads\BlindMeet.apk"
```

---

# NEXT STEPS

1. ✅ Follow steps 1-3 to build APK
2. ✅ Section 2 or 3 to test (emulator or real phone)
3. ✅ Report any issues or crashes
4. ✅ Fix bugs and rebuild
5. ✅ Once stable, ready for distribution

**Questions? Check SETUP_VERIFICATION.md for more troubleshooting**

---

**Last Updated**: May 16, 2026  
**Status**: Ready for Testing ✅
