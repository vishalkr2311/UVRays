# BlindMeet - Dark Fantasy Dating App

A modern, production-ready MVP dating application built with Flutter, Node.js, and real-time chat using Socket.IO.

## 🌟 Features

### App Features
- **Dark Fantasy UI** with glassmorphism design and neon gradients
- **Google OAuth Authentication** via Firebase
- **Profile Setup Wizard** with comprehensive user information
- **User Discovery** with advanced search and filtering
- **Real-time Chat** using Socket.IO
- **Connection Requests** - send, accept, reject system
- **Responsive Design** for Android and iOS
- **Smooth Animations** with micro-interactions

### Tech Stack

#### Frontend
- Flutter 3.10+
- Dart
- Riverpod for state management
- Dio for HTTP client
- Socket.IO for real-time chat
- Firebase Authentication
- Provider pattern

#### Backend
- Node.js 16+
- Express.js
- PostgreSQL
- Socket.IO
- Firebase Admin SDK
- JWT Authentication

## 📁 Project Structure

```
BlindMeet/
├── backend/                  # Node.js Express API
│   ├── src/
│   │   ├── controllers/     # Business logic
│   │   ├── routes/          # API endpoints
│   │   ├── models/          # Database models
│   │   ├── services/        # Services
│   │   ├── middleware/      # Auth, error handling
│   │   ├── socket/          # Socket.IO handlers
│   │   ├── config/          # Configuration
│   │   ├── utils/           # Utilities
│   │   └── index.js         # Main server
│   ├── package.json
│   ├── .env.example
│   └── README.md
│
├── frontend/                 # Flutter App
│   ├── lib/
│   │   ├── screens/         # UI Screens
│   │   ├── widgets/         # Reusable widgets
│   │   ├── providers/       # Riverpod providers
│   │   ├── services/        # API & Socket services
│   │   ├── models/          # Data models
│   │   ├── theme/           # Theme & styling
│   │   ├── utils/           # Utilities
│   │   └── main.dart        # App entry
│   ├── pubspec.yaml
│   ├── android/             # Android config
│   ├── ios/                 # iOS config
│   └── README.md
│
└── database/
    └── schema.sql           # PostgreSQL schema
```

## 🚀 Quick Start

### Prerequisites
- Node.js 16+ and npm
- Flutter 3.10+
- PostgreSQL 12+
- Git
- Firebase Project (for authentication)

### Backend Setup

1. Navigate to backend directory:
```bash
cd backend
npm install
```

2. Configure environment:
```bash
cp .env.example .env
# Edit .env with your Firebase and database credentials
```

3. Setup PostgreSQL database:
```bash
# Create database
createdb blindmeet

# Run schema
psql -U postgres -d blindmeet -f ../database/schema.sql
```

4. Start backend server:
```bash
npm run dev
# Server runs on http://localhost:5000
```

### Frontend Setup

1. Navigate to frontend directory:
```bash
cd frontend
flutter pub get
```

2. Configure Firebase:
   - Update `lib/services/firebase_options.dart` with your Firebase project credentials
   - Or run FlutterFire CLI:
   ```bash
   flutterfire configure
   ```

3. Update API configuration:
   - Edit `lib/services/api_service.dart` to point to your backend URL

4. Run app:
```bash
# For iOS
flutter run -d iphone

# For Android
flutter run -d android

# For web (development)
flutter run -d chrome
```

## 🔧 API Endpoints

### Authentication
- `POST /api/auth/google-login` - Google Sign-In
- `POST /api/auth/logout` - Logout

### Profile
- `POST /api/profile/create` - Create profile
- `PUT /api/profile/update` - Update profile  
- `GET /api/profile/me` - Get current profile
- `GET /api/profile/:userId` - Get user profile
- `POST /api/profile/images/upload` - Upload images

### Search
- `GET /api/search/all` - Get all users
- `GET /api/search/search` - Search users with filters

### Requests
- `POST /api/requests/send` - Send connection request
- `POST /api/requests/accept` - Accept request
- `POST /api/requests/reject` - Reject request
- `GET /api/requests/incoming` - Get pending requests
- `GET /api/requests/accepted` - Get accepted connections

### Chat
- `GET /api/chat/conversations` - Get conversations
- `GET /api/chat/conversations/:id/messages` - Get messages
- `POST /api/chat/messages/send` - Send message

## 🔌 Socket.IO Events

### Emit (Client → Server)
```javascript
socket.emit('user:join', userId);
socket.emit('conversation:join', { conversationId, userId });
socket.emit('message:send', { conversationId, senderId, message, timestamp });
socket.emit('typing:start', { conversationId, userId, nickname });
socket.emit('typing:stop', { conversationId });
socket.emit('message:read', { conversationId, userId });
```

### Listen (Server → Client)
```javascript
socket.on('user:online', (data) => {});
socket.on('user:offline', (data) => {});
socket.on('message:received', (data) => {});
socket.on('user:typing', (data) => {});
socket.on('user:typing:stop', () => {});
```

## 📱 App Screens

### Implemented
1. **Splash Screen** - App intro with loading animation
2. **Login Screen** - Google OAuth sign-in
3. **Profile Setup** - Multi-step profile creation
4. **Home Screen** - Bottom navigation hub

### To Implement
5. **Discover/Search Screen** - Browse and search users
6. **User Profile View** - View other user profiles
7. **Requests Screen** - View connection requests
8. **Chat List Screen** - Conversations overview
9. **Chat Screen** - Real-time messaging
10. **My Profile Screen** - View and edit own profile

## 🎨 UI/UX Design

### Color Palette
- **Dark Background**: `#0F0017`
- **Primary Neon**: `#00D9FF` (Cyan)
- **Secondary Neon**: `#FF006E` (Hot Pink)
- **Tertiary Neon**: `#9D4EDD` (Purple)

### Design Features
- Glassmorphism cards with backdrop blur
- Neon gradient buttons
- Dark fantasy theme
- Smooth page transitions
- Emoji integration
- 3D effects with shadows

## 🔒 Security

### Implemented
- ✅ JWT token-based authentication
- ✅ Firebase Auth integration
- ✅ Helmet security headers
- ✅ CORS protection
- ✅ Rate limiting
- ✅ Input validation
- ✅ SQL injection prevention

### Best Practices
- Environment variable configuration
- Secure password handling
- Token expiration (7 days default)
- Refresh token mechanism (future)

## 🧪 Testing

### Backend Testing
```bash
# Test health endpoint
curl http://localhost:5000/health

# Test Google login
curl -X POST http://localhost:5000/api/auth/google-login \
  -H "Content-Type: application/json" \
  -d '{"idToken":"your_firebase_token"}'
```

### Frontend Testing
- Use Flutter's testing framework
- Test state management with Riverpod
- Test UI components

## 📦 Deployment

### Backend Deployment
Deploy to:
- Heroku (easiest)
- Railway
- AWS EC2 + Nginx
- DigitalOcean

### Frontend Deployment
- **Android**: Build APK or AAB for Google Play
- **iOS**: Build for App Store
- **Web**: Deploy to Firebase Hosting

## 🐛 Troubleshooting

### Backend Issues

**Database Connection Error**
```bash
# Check PostgreSQL is running
psql -U postgres

# Verify connection string in .env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=blindmeet
```

**Firebase Error**
- Verify .env has correct Firebase credentials
- Check private key format (should have `\n` for newlines)

### Frontend Issues

**Flutter Dependency Conflicts**
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

**Firebase Configuration**
- Run `flutterfire configure` or update `firebase_options.dart`
- Check iOS deployment target is 11.0+
- Check Android SDK version is 21+

## 📚 Documentation

- [Backend README](./backend/README.md)
- [Frontend Setup Guide](./frontend/README.md)
- [API Documentation](./API.md)
- [Database Schema](./database/schema.sql)

## 🚦 Development Roadmap

### Phase 1 (MVP - Current)
- ✅ Authentication 
- ✅ Profile setup
- ⏳ User discovery
- ⏳ Connection requests
- ⏳ Real-time chat

### Phase 2 (Enhancement)
- [ ] Image compression  
- [ ] Typing indicators
- [ ] Read receipts
- [ ] User blocking
- [ ] Gift/emoji reactions
- [ ] Video call integration

### Phase 3 (Advanced)
- [ ] Push notifications
- [ ] User verification
- [ ] Admin dashboard
- [ ] Analytics
- [ ] Two-factor auth
- [ ] Advanced search filters
- [ ] User ratings/reviews

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📝 License

This project is licensed under the MIT License - see LICENSE file for details.

## 👥 Support

For support and questions:
- Create an issue in repository
- Email: support@blindmeet.app
- Discord: [Community Server Link]

## 🎉 Credits

Built with ❤️ by the BlindMeet Team

---

**Note**: This is an MVP. Additional features and optimizations are planned for production release.

**Last Updated**: May 2026
#   U V R a y s  
 