# Quick Navigation - Running, Building & Deployment Guide

## 📚 For Quick Answers

### ❓ "How to run the app locally?"
👉 See: **RUN_BUILD_DEPLOY.md** → **PART 1: RUNNING THE APP LOCALLY**
- Start backend on port 5000
- Start frontend on Android/iOS emulator
- Test complete user flow

**Time**: 15-20 minutes

---

### ❓ "How to build APK/IPA?"
👉 See: **RUN_BUILD_DEPLOY.md** → **PART 2: BUILDING APK & IPA FOR DISTRIBUTION**

**APK (Android)**:
- Build Release APK (50-80 MB)
- Build App Bundle (30-40 MB for Play Store)
- Install on emulator/device
- Share via link

**IPA (iOS)**:
- Build release IPA
- Install on simulator
- Share via TestFlight or Firebase

**Time**: 10-15 minutes per platform

---

### ❓ "How to deploy to cloud?"
👉 See: **RUN_BUILD_DEPLOY.md** → **PART 3: CLOUD DEPLOYMENT**

**5 Options Available**:
1. **Heroku** (✅ Recommended for MVP - easiest)
2. **Railway** (Quick, modern alternative)
3. **AWS EC2** (Full control, production-grade)
4. **Firebase Hosting** (Frontend only)
5. **Netlify** (Frontend, easy)

**Backend Deployment**:
- Heroku: 15 minutes
- Railway: 10 minutes
- AWS: 1-2 hours

**Frontend Deployment**:
- Netlify: 5 minutes
- Firebase: 5 minutes
- AWS S3+CloudFront: 30 minutes

---

## 🚀 Recommended Path (Complete Flow)

### Phase 1: Local Development ✅
1. Start PostgreSQL
2. Start backend with `npm run dev`
3. Start frontend with `flutter run`
4. Test login & create profile
5. Test chat & messaging

**Duration**: 20 minutes

---

### Phase 2: Build Release Versions
1. Build APK for Android testing
2. Build IPA for iOS testing
3. Test on real devices

**Duration**: 20 minutes

---

### Phase 3: Deploy Backend
**Option A (Recommended - Heroku)**:
```bash
heroku login
heroku create blindmeet-api-prod
heroku addons:create heroku-postgresql:hobby-dev
git push heroku main
# Done! App is live
```
**Duration**: 10-15 minutes

**Option B (AWS)**:
- More complex but full control
**Duration**: 1-2 hours

---

### Phase 4: Deploy Frontend
**Option A (Recommended - Netlify)**:
1. Build Flutter web: `flutter build web --release`
2. Connect GitHub to Netlify
3. Auto-deploys on push
```bash
firebase deploy --only hosting
# or
netlify deploy --prod
```
**Duration**: 5-10 minutes

---

### Phase 5: Update Configurations
1. Update frontend URLs to live backend
2. Test from production
3. Configure Firebase

**Duration**: 5 minutes

---

## 📁 Complete File Structure for Deployment

```
blindmeet/
├── backend/
│   ├── src/
│   │   ├── index.js           ← Main server
│   │   ├── config/
│   │   │   ├── database.js
│   │   │   └── firebase.js
│   │   ├── models/            ← Database queries
│   │   ├── controllers/       ← Business logic
│   │   ├── routes/            ← API endpoints
│   │   ├── socket/            ← Real-time chat
│   │   └── middleware/        ← Auth, errors
│   ├── database/
│   │   └── schema.sql         ← Database setup
│   ├── package.json           ← Dependencies
│   ├── .env.example           ← Configuration template
│   └── README.md              ← Backend docs
│
├── frontend/
│   ├── lib/
│   │   ├── main.dart          ← App entry
│   │   ├── theme/             ← Design system
│   │   ├── screens/           ← UI screens
│   │   ├── services/          ← API & Socket
│   │   ├── providers/         ← State management
│   │   ├── models/            ← Data models
│   │   └── widgets/           ← Reusable components
│   ├── pubspec.yaml           ← Dependencies
│   ├── ios/                   ← iOS config
│   └── android/               ← Android config
│
├── RUN_BUILD_DEPLOY.md        ← THIS GUIDE
├── DEPLOYMENT.md              ← Detailed deployment options
├── QUICK_REFERENCE.md         ← Command reference
└── README.md                  ← Project overview
```

---

## 🔧 Environment Variables Needed

### Backend (.env file)
```
# Server
PORT=5000
NODE_ENV=production

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=blindmeet
DB_USER=postgres
DB_PASSWORD=your_password

# JWT
JWT_SECRET=your_very_long_random_secret_key

# Firebase
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----...
FIREBASE_CLIENT_EMAIL=service-account@project.iam.gserviceaccount.com
FIREBASE_STORAGE_BUCKET=your-bucket.appspot.com

# Frontend
FRONTEND_URL=https://your-frontend-url.com
```

### Frontend (lib/services/api_service.dart)
```dart
const String baseUrl = 'https://api.blindmeet.app';  // Change this to your backend
```

---

## ⚡ Time Estimates

| Task | Time | Difficulty |
|------|------|-----------|
| Run locally | 20 min | Easy |
| Build APK | 10 min | Easy |
| Build IPA | 10 min | Medium |
| Deploy to Heroku | 15 min | Easy |
| Deploy to Railway | 10 min | Easy |
| Deploy to AWS | 2 hours | Hard |
| Deploy to Netlify | 5 min | Easy |
| **Complete Setup** | **3-4 hours** | **Medium** |

---

## ✅ Verification Checklist

- [ ] Local backend running on `http://localhost:5000`
- [ ] Local frontend running on emulator/device
- [ ] Can login with Google account (test)
- [ ] Can create profile
- [ ] APK/IPA built successfully
- [ ] Backend deployed to Heroku/AWS/Railway
- [ ] Frontend deployed to Netlify/Firebase
- [ ] Production URLs configured
- [ ] SSL certificate active
- [ ] Database backed up

---

## 📞 Troubleshooting

**Backend won't start**:
- PostgreSQL not running
- Port 5000 in use
- .env variables missing

**Frontend won't build**:
- Flutter cache issues: `flutter clean`
- Pod issues (iOS): `cd ios && pod install`
- Dependencies: `flutter pub get`

**Deployment fails**:
- Firebase credentials incorrect
- Environment variables not set
- Git repository not initialized

**See SETUP_VERIFICATION.md** for detailed troubleshooting

---

## 🎯 Next Steps

1. Choose deployment platform (Heroku recommended)
2. Follow PART 3 of RUN_BUILD_DEPLOY.md step-by-step
3. Test your live backend: `curl https://your-backend.com/health`
4. Deploy frontend
5. Update frontend URLs to production
6. Test complete flow on production

---

**All guides available in this project:**
- RUN_BUILD_DEPLOY.md ← You are here
- DEPLOYMENT.md (Detailed options)
- TESTING.md (Testing procedures)
- SETUP_VERIFICATION.md (Verification checklist)
- README.md (Project overview)
- backend/README.md (Backend docs)
- QUICK_REFERENCE.md (Command reference)
