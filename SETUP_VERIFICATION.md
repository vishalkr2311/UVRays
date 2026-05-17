# BlindMeet - Setup Verification Checklist

Use this checklist to verify your BlindMeet development environment is properly configured.

## ✅ Pre-Installation Requirements

- [ ] **Node.js 16+** installed
  ```bash
  node --version  # Should show v16.0.0 or higher
  ```

- [ ] **Flutter 3.10+** installed
  ```bash
  flutter --version  # Should show 3.10.0 or higher
  ```

- [ ] **PostgreSQL 12+** installed
  ```bash
  psql --version  # Should show 12.0 or higher
  ```

- [ ] **Git** installed
  ```bash
  git --version
  ```

- [ ] **Code editor** (VS Code, Android Studio, or Xcode)

---

## ✅ Backend Setup Verification

### 1. Dependencies Installation
```bash
cd backend
npm install

✅ Check: You should see 30+ packages installed
```

### 2. Environment Configuration
```bash
cd backend
cp .env.example .env
# Edit .env with your configuration

✅ Check: .env file exists and contains:
  - PORT (should be 5000)
  - DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD
  - JWT_SECRET (random string)
  - FIREBASE credentials
```

### 3. Start Backend Server
```bash
npm run dev

✅ Check: You should see message like:
  "🚀 BlindMeet Backend running on port 5000"
  "📊 API Base URL: http://localhost:5000/api"
  "🔌 WebSocket URL: ws://localhost:5000"
```

### 4. Test Backend Health
```bash
# In new terminal, run:
curl http://localhost:5000/health

✅ Check: Response should be:
{
  "success": true,
  "message": "Server is running",
  "database": "Connected",
  "timestamp": "..."
}
```

---

## ✅ Database Setup Verification

### 1. Create Database
```bash
createdb blindmeet

✅ Check: Database created without errors
```

### 2. Run PostgreSQL Schema
```bash
psql -U postgres -d blindmeet -f database/schema.sql

✅ Check: All tables created (4 tables total):
  - users
  - requests
  - conversations
  - messages
```

### 3. Verify Tables
```bash
psql -U postgres -d blindmeet
\dt

✅ Check: Should list:
  public | users | table
  public | requests | table
  public | conversations | table
  public | messages | table
```

### 4. Verify Indexes
```sql
\d users

✅ Check: See "Indexes:" section with:
  users_pkey PRIMARY KEY
  idx_users_google_id UNIQUE
  idx_users_email UNIQUE
  idx_users_nickname UNIQUE
```

---

## ✅ Firebase Setup Verification

### 1. Firebase Project Created
```
✅ Check: Go to https://console.firebase.google.com/
- Name: BlindMeet
- Email: your-email@gmail.com
```

### 2. Authentication Enabled
```
✅ Check: In Firebase Console:
- Build → Authentication
- Google provider is Enabled
```

### 3. Service Account Created
```
✅ Check: 
- Project Settings → Service Accounts
- Downloaded JSON key
- File contains: private_key, client_email, project_id
```

### 4. Environment Variables Set
```bash
# In backend/.env, verify:
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----..."
FIREBASE_CLIENT_EMAIL=your-email@appspot.gserviceaccount.com

✅ Check: All values present (no "YOUR_..." placeholders)
```

---

## ✅ Frontend Setup Verification

### 1. Dependencies Installation
```bash
cd frontend
flutter pub get

✅ Check: 50+ packages downloaded
```

### 2. Flutter Doctor
```bash
flutter doctor

✅ Check: Should show:
  ✓ Flutter (Channel stable)
  ✓ Android toolchain
  ✓ Xcode (for iOS)
  ✓ VS Code (or IDE)
  ✓ Connected devices
```

### 3. Firebase Configuration
```
Verify: lib/services/firebase_options.dart
✅ Check: Contains actual Firebase credentials (not YOUR_... placeholders)
```

### 4. API Configuration
```dart
Verify: lib/services/api_service.dart
✅ Check: Line contains:
  baseUrl: 'http://localhost:5000/api',
```

### 5. Run Frontend (Android)
```bash
cd frontend
flutter run -d android

✅ Check: 
- You see main.dart being compiled
- App launches on emulator/device
- Shows Splash Screen first
- No error messages in console
```

### 6. Run Frontend (iOS)
```bash
cd frontend
flutter run -d iphone

✅ Check:
- iOS build succeeds
- Simulator starts
- App loads without errors
```

---

## ✅ API Testing Verification

### 1. Test Health Endpoint
```bash
curl http://localhost:5000/health

✅ Expect: 200 OK with success message
```

### 2. Test Google Login (with real token)
```bash
curl -X POST http://localhost:5000/api/auth/google-login \
  -H "Content-Type: application/json" \
  -d '{"idToken":"REAL_FIREBASE_TOKEN"}'

✅ Expect: 200 OK with accessToken
```

### 3. Test Protected Route (without token)
```bash
curl http://localhost:5000/api/profile/me

✅ Expect: 401 "Access token required"
```

### 4. Test Protected Route (with token)
```bash
curl http://localhost:5000/api/profile/me \
  -H "Authorization: Bearer YOUR_TOKEN"

✅ Expect: 401 or user data (depends on if profile created)
```

### 5. Database Query in Terminal
```bash
psql -U postgres -d blindmeet
SELECT COUNT(*) FROM users;

✅ Expect: Count results showing
```

---

## ✅ Socket.IO Verification

### 1. Check Socket Server Running
```bash
# Backend still running from earlier
✅ Check: Port 5000 active with WebSocket support
```

### 2. Test Connection (requires Socket.IO client)
```bash
npm install -g socket.io-client-cli

socket-io-client-cli --url ws://localhost:5000

✅ Expect: Connected message
```

---

## ✅ Emulator/Device Verification

### Android
```bash
flutter emulators --launch Pixel_4

✅ Check:
- Emulator launches
- Shows Android welcome screen
- App installs and runs
```

### iOS
```bash
open -a Simulator

✅ Check:
- Simulator launches
- Shows iOS home screen
- App installs and runs
```

---

## 🔍 Common Issues & Solutions

### Issue: "Cannot connect to database"
```
Solution:
1. Start PostgreSQL: sudo systemctl start postgresql
2. Verify connection: psql -U postgres
3. Check .env has correct credentials
```

### Issue: "Port 5000 already in use"
```
Solution:
# Find process using port 5000
lsof -i :5000

# Kill process
kill -9 <PID>

# Or change port in .env and backend/src/index.js
```

### Issue: "Firebase not found"
```
Solution:
1. Run: flutterfire configure
2. Or update firebase_options.dart manually
3. Ensure firebase_core and firebase_auth installed
```

### Issue: "Flutter build fails"
```
Solution:
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

### Issue: "Cannot find module 'express'"
```
Solution:
cd backend
rm -rf node_modules
npm install
```

### Issue: "App shows blank white screen"
```
Solution:
1. Check console for errors
2. Verify Firebase credentials
3. Run: flutter run -v (verbose mode)
4. Check Android/iOS logs
```

---

## 📊 Verification Summary Table

| Component | Check | Command | Expected |
|-----------|-------|---------|----------|
| Node.js | Version | `node --version` | v16+ |
| Flutter | Version | `flutter --version` | 3.10+ |
| PostgreSQL | Running | `psql --version` | 12+ |
| Backend | Online | `curl http://localhost:5000/health` | 200 OK |
| Database | Connected | `psql -d blindmeet -c "\dt"` | 4 tables |
| Firebase | Configured | Check .env | No YOUR_... |
| Frontend | Building | `flutter run` | App starts |
| Socket | Connected | Test with client | Connected |

---

## ✅ Final Verification Checklist

- [ ] All prerequisites installed (Node, Flutter, PostgreSQL)
- [ ] Backend running on port 5000
- [ ] Database connected with 4 tables
- [ ] Firebase credentials in .env
- [ ] Firebase options in Flutter
- [ ] Backend health endpoint returns 200
- [ ] Frontend app builds and runs
- [ ] Splash screen appears
- [ ] No console errors
- [ ] Can navigate to login screen

---

## 🚀 Ready to Go?

If all checks pass, you're ready to:

1. **Implement remaining screens** - See IMPLEMENTATION_STATUS.md
2. **Test API endpoints** - See TESTING.md  
3. **Deploy to production** - See DEPLOYMENT.md
4. **Run end-to-end tests** - See TESTING.md

---

## 📞 Quick Debug Commands

```bash
# Check if port is in use
lsof -i :5000

# View backend logs
pm2 logs blindmeet

# Check database connection
psql -U postgres -c "SELECT version();"

# Flutter verbose output
flutter run -v

# Check current directory structure
tree -L 2 -I 'node_modules|build|.dart_tool'

# verify all npm packages
npm list --depth=0

# Check Flutter packages
flutter pub list
```

---

## 📝 Notes

- Estimated setup time: 30-45 minutes
- Most common issues: Database not running, wrong credentials, ports in use
- All tools should be added to system PATH
- Restart services after changing .env
- Clear browser cache if testing web

---

**Last Updated**: May 16, 2026  
**Status**: Setup Verification Complete ✅

If you encounter any issues not listed above, check:
1. [Backend README](./backend/README.md)
2. [Main README](./README.md)
3. [Testing Guide](./TESTING.md)
4. [Deployment Guide](./DEPLOYMENT.md)
