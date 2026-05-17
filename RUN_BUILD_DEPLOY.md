# BlindMeet - Complete Guide to Running, Building & Deploying

This guide provides step-by-step instructions to:
- Run the app locally for development
- Build APK/IPA for distribution
- Deploy to cloud platforms

---

# PART 1: RUNNING THE APP LOCALLY (DEVELOPMENT)

## 1.1 Start Backend Server

### Step 1: Navigate to Backend
```bash
cd backend
```

### Step 2: Install Dependencies (if not done)
```bash
npm install
```

### Step 3: Configure Environment Variables
```bash
# Copy example to .env if not already done
cp .env.example .env

# Edit .env file and add your actual values:
# PORT=5000
# DB_HOST=localhost
# DB_PORT=5432
# DB_NAME=blindmeet
# DB_USER=postgres
# DB_PASSWORD=your_password
# JWT_SECRET=your_very_long_random_secret_key_12345
# NODE_ENV=development
# FIREBASE_PROJECT_ID=your_firebase_project_id
# FIREBASE_PRIVATE_KEY=your_firebase_private_key
# FIREBASE_CLIENT_EMAIL=your_firebase_client_email
# FIREBASE_STORAGE_BUCKET=your_storage_bucket.appspot.com
```

### Step 4: Ensure PostgreSQL is Running
```bash
# Windows (if using PostgreSQL service)
# Services → PostgreSQL → Start

# macOS
brew services start postgresql

# Linux
sudo systemctl start postgresql

# Verify connection
psql -U postgres
# Should show: postgres=#
# Exit with: \q
```

### Step 5: Ensure Database Exists
```bash
# Create database if not done
createdb blindmeet

# Run schema
psql -U postgres -d blindmeet -f database/schema.sql
```

### Step 6: Start Backend Development Server
```bash
cd backend
npm run dev

# You should see:
# 🚀 BlindMeet Backend running on port 5000
# 📊 API Base URL: http://localhost:5000/api
# 🔌 WebSocket URL: ws://localhost:5000
# ✅ PostgreSQL connected
# ✅ Firebase configured
```

### Step 7: Verify Backend is Working
```bash
# In a new terminal/PowerShell:
curl http://localhost:5000/health

# Response should be:
{
  "success": true,
  "message": "Server is running",
  "database": "Connected",
  "timestamp": "2026-05-16T10:30:45.123Z"
}
```

---

## 1.2 Start Frontend on Android Emulator

### Step 1: Setup Android Emulator (if not done)
```bash
# List available emulators
flutter emulators

# Launch emulator (e.g., Pixel_4)
flutter emulators --launch Pixel_4

# Wait for emulator to fully start (2-3 minutes)
```

### Step 2: Configure Frontend
```bash
cd frontend

# Update backend URL to local (if not already)
# Edit: lib/services/api_service.dart
# Change: baseUrl: 'http://localhost:5000/api',
# And in lib/services/socket_service.dart: 'http://localhost:5000'
```

### Step 3: Install Flutter Dependencies
```bash
cd frontend
flutter pub get
```

### Step 4: Run on Android
```bash
# Run on connected emulator/device
flutter run

# Or specific device:
flutter run -d <device_id>

# Get connected devices:
flutter devices
```

### Step 5: Expected Output
```
✓ Built build/app/outputs/flutter-apk/app-debug.apk
Installing and launching...
Xcode build done.
🔥 39,847ms (!)
The app will be built and started on your device.
```

The app should now:
- Show BlindMeet Splash Screen (3 seconds)
- Automatically navigate to Login Screen
- Display Google Sign-In button

---

## 1.3 Start Frontend on iOS Simulator

### Step 1: Setup iOS Simulator (macOS only)
```bash
# Open simulator
open -a Simulator

# Or launch specific device
open -a Simulator --args -CurrentDeviceUDID "device-id"
```

### Step 2: Install Pods (dependencies)
```bash
cd frontend/ios
pod install --repo-update
cd ..
```

### Step 3: Run on iOS
```bash
flutter run -d iphone

# Or with verbose output for debugging:
flutter run -d iphone -v
```

### Step 4: Expected Output
Similar to Android, app launches on simulator with Login screen.

---

## 1.4 Test the Complete Flow Locally

### Test Scenario: Complete User Journey

#### 1. Backend Running ✅
```bash
curl http://localhost:5000/health
# Response: {"success":true, ...}
```

#### 2. Frontend Running ✅
App shows Login screen with "Sign in with Google" button

#### 3. Click "Sign in with Google"
- Opens Google login dialog (use test account)
- After auth, app navigates to Home screen

#### 4. Create Profile
- Fill profile information
- Save profile

#### 5. Search for Users
- Go to Discover tab
- See list of other users

#### 6. Send Connection Request
- Click on user
- Send connection request

#### 7. View Chat
- Go to Chat tab
- See conversations
- Send/receive messages

#### 8. Real-time Features Working ✅
- Typing indicators appear
- Messages update in real-time
- Online/offline status changes

---

## 1.5 Troubleshooting Local Development

### Issue: "Can't connect to backend"
```bash
# Check backend is running
curl http://localhost:5000/health

# If fails, restart backend:
cd backend
npm run dev
```

### Issue: "Database connection error"
```bash
# Ensure PostgreSQL is running
psql -U postgres

# If fails, start PostgreSQL:
# Windows: net start postgresql-x64-15
# macOS: brew services start postgresql
# Linux: sudo systemctl start postgresql
```

### Issue: "Firebase auth not working"
```
Ensure:
1. lib/services/firebase_options.dart has real credentials
2. backend/.env has FIREBASE variables set
3. Firebase project has Google Sign-In enabled
```

### Issue: "Android Emulator slow"
```bash
# Use hardware acceleration
flutter run -d android-emu-hardware-accel

# Or use Genymotion (faster alternative)
# Or test on real device: flutter run -d physical-device
```

### Issue: "iOS build fails"
```bash
cd frontend/ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
flutter clean
flutter run
```

---

---

# PART 2: BUILDING APK & IPA FOR DISTRIBUTION

## 2.1 Build APK for Android Distribution

### Option A: Release APK (for direct install)

#### Step 1: Prepare app/build.gradle
```bash
cd frontend/android/app
# Edit build.gradle and ensure:
# - applicationId: com.blindmeet.app
# - version code: increment by 1 each build
# - version name: 1.0.0
```

Content should look like:
```gradle
android {
    compileSdkVersion 33
    
    defaultConfig {
        applicationId "com.blindmeet.app"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode 1
        versionName "1.0.0"
    }
    
    signingConfigs {
        release {
            // Will configure in next step
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

#### Step 2: Create Signing Key
```bash
cd frontend/android/app

# Generate keystore (one-time)
keytool -genkey -v -keystore blindmeet.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias blindmeet-key

# You'll be asked:
# - Keystore password: (create strong password, e.g., YourSecure123)
# - Key password: (same as above)
# - First and Last Name: BlindMeet App
# - Organizational Unit: Development
# - Organization: BlindMeet
# - City: Your City
# - State: Your State
# - Country Code: US

# This creates blindmeet.jks file
```

#### Step 3: Configure Signing in gradle
```bash
# Edit android/app/build.gradle
```

Add to `signingConfigs`:
```gradle
signingConfigs {
    release {
        keyAlias 'blindmeet-key'
        keyPassword 'YOUR_KEY_PASSWORD'
        storeFile file('blindmeet.jks')
        storePassword 'YOUR_KEYSTORE_PASSWORD'
    }
}
```

#### Step 4: Build Release APK
```bash
cd frontend
flutter clean
flutter build apk --release

# This takes 5-10 minutes
# Output location: build/app/outputs/flutter-apk/app-release.apk
```

#### Step 5: Verify APK Built
```bash
ls -la build/app/outputs/flutter-apk/app-release.apk

# Should show file size around 50-80 MB
```

---

### Option B: App Bundle (for Google Play Store)

#### Step 1: Build App Bundle
```bash
cd frontend
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
# Size: ~30-40 MB (smaller than APK)
```

#### Step 2: Verify Bundle
```bash
ls -la build/app/outputs/bundle/release/app-release.aab
```

---

## 2.2 Install APK on Android Device/Emulator

### Method 1: Using Flutter Command
```bash
# Connected emulator or device
flutter install build/app/outputs/flutter-apk/app-release.apk
```

### Method 2: Using ADB Command
```bash
adb install build/app/outputs/flutter-apk/app-release.apk

# If already installed:
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

### Method 3: Share APK File
```bash
# Copy to shared location
cp build/app/outputs/flutter-apk/app-release.apk ~/Downloads/BlindMeet.apk

# User can now:
# 1. Download from link
# 2. Transfer to Android device
# 3. Open file manager → Downloads
# 4. Tap APK file → Install
```

---

## 2.3 Build IPA for iOS Distribution

### Prerequisites (macOS only)
- Xcode 13+
- Apple Developer Account ($99/year)
- Certificates and provisioning profiles configured

### Step 1: Configure iOS Project
```bash
cd frontend/ios

# Open in Xcode
open Runner.xcworkspace
```

In Xcode:
- Select "Runner" project
- Select "Runner" target
- Go to "Build Settings"
- Search "Bundle Identifier"
- Set to: `com.blindmeet.app`
- Team ID: (select your Apple Developer Team)

### Step 2: Update Version
In Xcode:
- General tab
- Version: 1.0.0
- Build: 1

### Step 3: Build IPA
```bash
cd frontend

# Build iOS release
flutter build ios --release

# Or build from Xcode:
# Product → Archive
# (After dialog: Distribute App → Ad Hoc → Export)
```

### Step 4: Alternative - Direct IPA Build
```bash
cd frontend/ios

# Using Xcode command line
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -derivedDataPath build \
  -archivePath build/Runner.xcarchive \
  archive

xcodebuild -exportArchive \
  -archivePath build/Runner.xcarchive \
  -exportOptionsPlist ExportOptions.plist \
  -exportPath build/ipa
```

### Step 5: Find IPA File
```bash
# IPA location:
# frontend/build/ios/iphoneos/app_name.ipa

ls -la build/ios/iphoneos/
```

---

## 2.4 Share IPA on iOS Device

### Method 1: TestFlight (Internal Testing)
```
1. Go to App Store Connect
2. Apps → Your App → TestFlight
3. Internal Testing
4. Add testers' Apple IDs
5. They receive link to download via TestFlight app
```

### Method 2: Ad Hoc Distribution
```
1. Create Ad Hoc provisioning profile (max 100 devices)
2. Export IPA with Ad Hoc profile
3. Share .ipa file via cloud (Dropbox, Google Drive)
4. Users install via Xcode or Apple Configurator 2
```

### Method 3: Firebase App Distribution
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Authenticate
firebase login

# Upload IPA
firebase appdistribution:distribute build/app/outputs/app.ipa \
  --app 1:123456789:ios:abc123... \
  --release-notes "Beta version 1.0" \
  --testers "tester@example.com"

# Testers get email link
```

---

---

# PART 3: CLOUD DEPLOYMENT - STEP BY STEP

## 3.1 Deploy Backend to Heroku (Recommended for MVP)

### Step 1: Create Heroku Account
```
1. Go to https://www.heroku.com
2. Sign up (free account available)
3. Verify email
```

### Step 2: Install Heroku CLI
```bash
# Windows: Download from https://devcenter.heroku.com/articles/heroku-cli
# Or use choco:
choco install heroku-cli

# macOS
brew tap heroku/brew && brew install heroku

# Verify
heroku --version
```

### Step 3: Login to Heroku
```bash
heroku login

# Opens browser, sign in with your account
# Returns: Logged in as your-email@example.com
```

### Step 4: Create Heroku App
```bash
cd backend

# Create app
heroku create blindmeet-api-prod

# Verify
heroku apps

# Shows: blindmeet-api-prod
```

### Step 5: Add PostgreSQL Database
```bash
# Add free database addon
heroku addons:create heroku-postgresql:hobby-dev -a blindmeet-api-prod

# Verify
heroku addons -a blindmeet-api-prod

# Shows database URL
```

### Step 6: Set Environment Variables
```bash
# Set all required variables
heroku config:set NODE_ENV=production -a blindmeet-api-prod
heroku config:set JWT_SECRET="your_very_long_random_secret_key_12345" -a blindmeet-api-prod
heroku config:set FIREBASE_PROJECT_ID="your_firebase_project_id" -a blindmeet-api-prod
heroku config:set FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n..." -a blindmeet-api-prod
heroku config:set FIREBASE_CLIENT_EMAIL="your-service-account@PROJECT_ID.iam.gserviceaccount.com" -a blindmeet-api-prod
heroku config:set FIREBASE_STORAGE_BUCKET="blindmeet-123.appspot.com" -a blindmeet-api-prod
heroku config:set FRONTEND_URL="https://blindmeet-frontend.netlify.app" -a blindmeet-api-prod

# Verify
heroku config -a blindmeet-api-prod

# Shows all environment variables
```

### Step 7: Initialize Git (if not done)
```bash
cd backend

# If not already a git repo
git init

# Add all files
git add .

# Commit
git commit -m "Initial backend setup"
```

### Step 8: Add Heroku Remote
```bash
# If first time
heroku git:remote -a blindmeet-api-prod

# Verify
git remote -v

# Shows:
# heroku  https://git.heroku.com/blindmeet-api-prod.git (fetch)
# heroku  https://git.heroku.com/blindmeet-api-prod.git (push)
```

### Step 9: Deploy to Heroku
```bash
# Push code to Heroku
git push heroku main

# This builds and deploys
# Wait 2-3 minutes
# Shows: remote: -----> Release v1 done
```

### Step 10: Run Database Migrations
```bash
# Get database URL
heroku config:get DATABASE_URL -a blindmeet-api-prod

# Run schema
heroku pg:psql -a blindmeet-api-prod < database/schema.sql

# Verify
heroku pg:psql -a blindmeet-api-prod

# In psql prompt:
\dt

# Should show 4 tables: users, requests, conversations, messages
\q  # to exit
```

### Step 11: Test Deployed Backend
```bash
# Get your Heroku app URL
heroku open -a blindmeet-api-prod

# Test health endpoint
curl https://blindmeet-api-prod.herokuapp.com/health

# Response:
{
  "success": true,
  "message": "Server is running",
  "database": "Connected"
}
```

### Step 12: View Logs
```bash
# Real-time logs
heroku logs --tail -a blindmeet-api-prod

# Or view last 50 lines
heroku logs -n 50 -a blindmeet-api-prod
```

### Step 13: Important: Update Frontend URLs
```bash
# In frontend code, update:
# lib/services/api_service.dart
# Change from: http://localhost:5000/api
# To: https://blindmeet-api-prod.herokuapp.com/api

# lib/services/socket_service.dart
# Change from: http://localhost:5000
# To: https://blindmeet-api-prod.herokuapp.com
```

---

## 3.2 Deploy Backend to Railway (Alternative)

### Step 1: Create Railway Account
```
1. Go to https://railway.app
2. Sign up with GitHub
3. Connect GitHub account
```

### Step 2: Create New Project
```
1. Click "New Project"
2. Select "Deploy from GitHub"
3. Select your blindmeet repository
4. Select backend folder
```

### Step 3: Add PostgreSQL Plugin
```
1. In Railway dashboard
2. Click "Add Plugin"
3. Select "PostgreSQL"
4. Confirm
```

### Step 4: Set Environment Variables
```
In Railway Dashboard:
1. Go to Variables tab
2. Add all .env values:
   - NODE_ENV: production
   - JWT_SECRET: ...
   - FIREBASE_PROJECT_ID: ...
   - etc.
```

### Step 5: Deploy
```
Railway automatically deploys when you push to GitHub
View logs in Railway dashboard
```

### Step 6: Get Deployed URL
```
In Railway:
1. Settings → Domains
2. Generate Railway domain
3. Your backend is at: https://blindmeet-prod.up.railway.app
```

---

## 3.3 Deploy Frontend to Netlify

### Step 1: Create Netlify Account
```
1. Go to https://www.netlify.com
2. Sign up with GitHub
3. Connect GitHub account
```

### Step 2: Build Flutter Web
```bash
cd frontend
flutter build web --release

# Output: build/web/
```

### Step 3: Update Backend URL
Before building, update:
```bash
# lib/services/api_service.dart
baseUrl: 'https://blindmeet-api-prod.herokuapp.com/api'

# lib/services/socket_service.dart
const String socketUrl = 'https://blindmeet-api-prod.herokuapp.com';
```

### Step 4: Add Netlify Configuration
Create `netlify.toml` in project root:
```toml
[build]
  command = "flutter build web --release"
  publish = "build/web"

[build.environment]
  FLUTTER_VERSION = "3.10.0"
```

### Step 5: Deploy to Netlify
```
1. Go to https://app.netlify.com
2. Click "New site from Git"
3. Select blindmeet repository
4. Configure build settings:
   - Build command: flutter build web --release
   - Publish directory: build/web
5. Click "Deploy site"
```

### Step 6: Get Frontend URL
```
After deployment:
Your app is at: https://blindmeet.netlify.app
Domain appears in Netlify dashboard
```

---

## 3.4 Deploy to AWS (Complete Production Stack)

### Step 1: Create AWS Account
```
1. Go to https://aws.amazon.com
2. Create account
3. Set payment method
```

### Step 2: Launch EC2 Instance (Backend)
```
1. Go to AWS Management Console
2. EC2 → Instances → Launch Instance
3. Select Ubuntu 22.04 LTS
4. Instance type: t3.micro (eligible for free tier)
5. Security group:
   - SSH (port 22): from your IP
   - HTTP (port 80): from anywhere
   - HTTPS (port 443): from anywhere
   - Custom (port 5000): from anywhere (optional)
6. Launch and download key pair (.pem file)
7. Save key pair in secure location
```

### Step 3: SSH into EC2
```bash
# Change permissions on key
chmod 400 blindmeet-key.pem

# SSH into instance
ssh -i blindmeet-key.pem ubuntu@your-ec2-public-ip

# You're now in the EC2 instance
```

### Step 4: Setup Environment
```bash
# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PostgreSQL
sudo apt-get install -y postgresql postgresql-contrib

# Install Nginx
sudo apt-get install -y nginx

# Verify installations
node --version
postgres --version
nginx -version
```

### Step 5: Setup PostgreSQL
```bash
# Start PostgreSQL
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create database and user
sudo -u postgres psql

# In psql:
CREATE DATABASE blindmeet;
CREATE USER blindmeet_user WITH PASSWORD 'strong_password_123';
ALTER ROLE blindmeet_user SET client_encoding TO 'utf8';
ALTER ROLE blindmeet_user SET default_transaction_isolation TO 'read committed';
ALTER ROLE blindmeet_user SET default_transaction_deferrable TO on;
ALTER ROLE blindmeet_user SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE blindmeet TO blindmeet_user;
\q

# Exit psql and import schema
sudo -u blindmeet_user psql -d blindmeet < /home/ubuntu/blindmeet/database/schema.sql
```

### Step 6: Deploy Backend Code
```bash
cd /home/ubuntu

# Clone repository
git clone https://github.com/yourusername/blindmeet.git
cd blindmeet/backend

# Install dependencies
npm install

# Build for production
npm run build  # if you have a build script

# Copy .env
cp .env.example .env

# Edit .env with production values
nano .env

# Set these values:
# NODE_ENV=production
# DB_HOST=localhost
# DB_NAME=blindmeet
# DB_USER=blindmeet_user
# DB_PASSWORD=strong_password_123
# PORT=5000
# All FIREBASE variables
```

### Step 7: Setup PM2 (Process Manager)
```bash
# Install PM2 globally
sudo npm install -g pm2

# Start backend with PM2
pm2 start src/index.js --name "blindmeet"

# Save PM2 configuration
pm2 save

# Setup startup script
pm2 startup systemd -u ubuntu --hp /home/ubuntu
# Run command it suggests

# Verify
pm2 list
pm2 logs
```

### Step 8: Configure Nginx
```bash
# Create Nginx configuration
sudo nano /etc/nginx/sites-available/blindmeet
```

Add this content:
```nginx
server {
    listen 80;
    server_name your-domain.com;

    client_max_body_size 100M;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    location /socket.io {
        proxy_pass http://localhost:5000/socket.io;
        proxy_http_version 1.1;
        proxy_buffering off;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'Upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### Step 9: Enable Nginx Site
```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/blindmeet /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

# Enable on startup
sudo systemctl enable nginx
```

### Step 10: Setup SSL Certificate (Let's Encrypt)
```bash
# Install Certbot
sudo apt-get install -y certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d your-domain.com

# Follow prompts:
# Enter email
# Agree to terms (Y)
# Auto-redirect HTTP to HTTPS (Y)

# Verify SSL
sudo certbot renew --dry-run
```

### Step 11: Test Deployed Backend
```bash
# From your local machine:
curl https://your-domain.com/health

# Response:
{
  "success": true,
  "message": "Server is running",
  "database": "Connected"
}
```

---

## 3.5 Deploy Frontend to Firebase Hosting

### Step 1: Setup Firebase Project
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Navigate to frontend
cd frontend
```

### Step 2: Build Flutter Web
```bash
flutter build web --release

# Output: build/web/
```

### Step 3: Initialize Firebase
```bash
# Initialize Firebase in frontend folder
firebase init hosting

# Select your Firebase project
# Hosting public directory: build/web
# Configure as SPA: Yes
# GitHub setup: No (for now)
```

### Step 4: Deploy to Firebase
```bash
firebase deploy --only hosting

# You'll get:
# Hosting URL: https://blindmeet-123.web.app
# Visit your URL to see the app live
```

---

---

# PART 4: SHARING & DISTRIBUTION LINKS

## 4.1 Share APK (Android Direct Install)

### Create Download Link
```
1. Upload APK to cloud storage:
   - Google Drive
   - Dropbox
   - AWS S3
   - Firebase Storage

2. Get public link:
   - Google Drive: Right-click → Share → "Anyone with link"
   - Dropbox: Share → Get link
   - AWS S3: Generate public link

3. Share link with users

4. Users can:
   - Download APK
   - Transfer to Android device
   - Open file manager
   - Tap APK → Install
```

### Example Link
```
https://drive.google.com/uc?export=download&id=YOUR_FILE_ID
```

---

## 4.2 Share IPA (iOS Distribution)

### Using TestFlight
```
1. Upload IPA to App Store Connect
2. Configure TestFlight
3. Send invite link to testers
4. They install via TestFlight app
```

### Using Firebase App Distribution
```bash
# Already covered in Part 2.4
firebase appdistribution:distribute app.ipa \
  --app 1:123456789:ios:abc... \
  --release-notes "Release notes" \
  --testers "email@example.com"
```

---

## 4.3 Share Live Web App

### Direct Link
```
Your frontend is live at:
https://your-domain.com

Share this link - users can:
- Open in any browser
- No installation needed
- Responsive design works on mobile
```

### QR Code
```
1. Go to https://qr-code-generator.com
2. Enter: https://your-domain.com
3. Generate QR code
4. Share image
5. Users scan with phone camera → opens app
```

---

---

# DEPLOYMENT CHECKLIST

## Before Going to Production

- [ ] All backend environment variables set
- [ ] Firebase credentials configured
- [ ] Database migrations run
- [ ] Frontend URLs updated to production
- [ ] Email domain configured (if applicable)
- [ ] SSL certificate installed
- [ ] Monitoring alerts setup
- [ ] Backup strategy configured
- [ ] Rate limiting configured
- [ ] CORS properly configured

## After Deployment

- [ ] Test all API endpoints
- [ ] Test authentication flow
- [ ] Test real-time messaging
- [ ] Monitor logs for errors
- [ ] Check database connection
- [ ] Verify SSL certificate
- [ ] Test from different devices
- [ ] Performance monitoring active

---

# QUICK COMMAND REFERENCE

```bash
# Local Development
npm run dev                    # Start backend
flutter run                    # Start frontend
flutter run -d iphone          # iOS
flutter run -d android         # Android

# Building
flutter build apk --release    # Android APK
flutter build appbundle --release  # Android Bundle
flutter build ios --release    # iOS IPA
flutter build web --release    # Flutter Web

# Heroku
heroku login
heroku create app-name
heroku addons:create heroku-postgresql:hobby-dev
heroku push heroku main
heroku logs --tail

# Netlify
netlify deploy --prod

# AWS
ssh -i key.pem ubuntu@instance-ip
pm2 start src/index.js
pm2 logs

# Firebase
firebase deploy --only hosting
firebase appdistribution:distribute app.ipa
```

---

**Last Updated**: May 16, 2026
**Status**: Complete Production Deployment Guide ✅
