# BlindMeet - Quick Reference Guide

## 🚀 Quick Commands

### Backend

```bash
# Install dependencies
cd backend && npm install

# Run development server
npm run dev

# API runs on: http://localhost:5000

# Health check
curl http://localhost:5000/health
```

### Frontend

```bash
# Install dependencies
cd frontend && flutter pub get

# Run on Android
flutter run -d android

# Run on iOS
flutter run -d iphone

# Build release
flutter build apk --release    # Android
flutter build ios --release    # iOS
flutter build web --release    # Web
```

### Database

```bash
# Create database
createdb blindmeet

# Run schema
psql -U postgres -d blindmeet -f database/schema.sql

# Connect to database
psql -U postgres -d blindmeet
```

## 📁 Important Files

| File | Purpose |
|------|---------|
| `backend/src/index.js` | Main server entry point |
| `backend/.env` | Backend configuration |
| `frontend/lib/main.dart` | App entry point |
| `frontend/pubspec.yaml` | Flutter dependencies |
| `database/schema.sql` | PostgreSQL schema |
| `DEPLOYMENT.md` | Production deployment |
| `TESTING.md` | Testing procedures |
| `README.md` | Project overview |

## 🔐 Firebase Setup

1. Go to https://console.firebase.google.com/
2. Create new project
3. Enable Authentication → Google Sign-In
4. Create Service Account key
5. Download JSON and add to `backend/.env`:
   - `FIREBASE_PROJECT_ID`
   - `FIREBASE_PRIVATE_KEY`
   - `FIREBASE_CLIENT_EMAIL`

6. Update `frontend/lib/services/firebase_options.dart`

## 🌐 Environment Variables

### Backend (.env)
```env
PORT=5000
DB_HOST=localhost
DB_PORT=5432
DB_NAME=blindmeet
DB_USER=postgres
DB_PASSWORD=password
JWT_SECRET=random_secret_key
FIREBASE_PROJECT_ID=your_project_id
```

### Frontend
- Update `firebase_options.dart` with Firebase credentials
- Update API URL in `api_service.dart`

## 📊 Database Schema Quick View

```sql
-- Users: profiles, demographics, images
-- Requests: connection requests (pending/accepted/rejected)
-- Conversations: 1:1 chat rooms
-- Messages: chat messages
```

## 🔗 API Response Format

All endpoints return:
```json
{
  "success": true/false,
  "message": "...",
  "data": {...}
}
```

## 🎯 Default Login Flow

1. User opens app → Splash Screen
2. Redirect to Login Screen
3. Click "Continue with Google"
4. Firebase modal appears
5. If first login → Profile Setup
6. If returning → Home Page

## 📋 Deployment Checklist

- [ ] Firebase project created
- [ ] PostgreSQL database configured
- [ ] Backend env variables set
- [ ] Frontend Firebase config updated
- [ ] Run database schema
- [ ] Install all dependencies
- [ ] Test API endpoints
- [ ] Test Socket.IO connection
- [ ] Build release builds
- [ ] Deploy backend (Heroku/AWS)
- [ ] Deploy frontend (Play Store/App Store)

## 🐛 Common Issues

| Issue | Solution |
|-------|----------|
| Database connection fails | Check DB credentials in .env |
| Firebase auth error | Verify Firebase credentials |
| Socket.IO not connecting | Check CORS settings |
| Flutter build fails | Run `flutter clean` |
| Port already in use | Kill process or change port |

## 📞 Testing Server

```bash
# Frontend
- Test on Android/iOS emulator first
- Then on real devices
- Check all 4 navigation tabs

# Backend  
- Start with `npm run dev`
- Test endpoints with curl
- Monitor logs for errors
- Check database

# Socket.IO
- Verify connection with socket client
- Test message sending
- Verify online/offline status
```

## 📚 Files Structure Quick View

```
backend/
├── src/
│   ├── controllers/      (Business logic)
│   ├── routes/           (API endpoints)
│   ├── models/           (Database queries)
│   ├── middleware/       (Auth, errors)
│   ├── socket/           (Real-time chat)
│   ├── config/           (DB, Firebase)
│   └── index.js          (Server)
└── package.json

frontend/
├── lib/
│   ├── screens/          (UI Screens)
│   ├── widgets/          (Components)
│   ├── providers/        (State)
│   ├── services/         (API, Socket)
│   ├── models/           (Data)
│   ├── theme/            (Styling)
│   └── main.dart
└── pubspec.yaml

database/
└── schema.sql           (Tables, indexes, triggers)
```

## 🎨 Key Features Location

| Feature | File |
|---------|------|
| Dark Theme | `frontend/lib/theme/theme.dart` |
| Glassmorphism | `frontend/lib/widgets/glassmorphism_card.dart` |
| Neon Buttons | `frontend/lib/widgets/neon_gradient_button.dart` |
| Auth Logic | `frontend/lib/providers/auth_provider.dart` |
| Chat Logic | `frontend/lib/providers/chat_provider.dart` |
| Socket Events | `lib/services/socket_service.dart` |
| API Calls | `lib/services/api_service.dart` |

## 🚀 Performance Tips

- Backend: Queries already optimized with indexes
- Frontend: Use `const` widgets where possible
- Database: Monitor query performance
- Socket.IO: Implement message pagination
- Caching: Add Redis in Phase 2

## 📱 Platform Specific

### Android
- Min SDK: 21
- Target SDK: 31+
- Build: `flutter build apk --release`

### iOS
- Min Deployment: 11.0
- Build: `flutter build ios --release`
- Signing required

## 🔄 Update & Maintenance

```bash
# Update dependencies
cd backend && npm update
cd frontend && flutter pub upgrade

# Check for security issues
npm audit (backend)

# Clean builds
flutter clean
npm install (from scratch)
```

## 📈 Monitoring & Logs

```bash
# Backend logs
pm2 logs blindmeet

# Database logs
SELECT * FROM pg_stat_statements;

# Frontend console
Use dev tools in Flutter Inspector
```

## 🎯 Next Deployable Milestones

1. ✅ All core APIs working
2. ✅ Authentication complete
3. ✅ UI screens functional
4. Need: More screen implementations
5. Need: End-to-end testing
6. Need: Performance optimization
7. Ready: For store submission

## 📞 Support Resources

- Backend README: `backend/README.md`
- Deployment Guide: `DEPLOYMENT.md`
- Testing Guide: `TESTING.md`
- Full README: `README.md`
- Project Status: `PROJECT_COMPLETION.md`

---

**For complete setup instructions, see README.md**

**For deployment, see DEPLOYMENT.md**

**For testing, see TESTING.md**
