# BlindMeet Backend

Production-ready Node.js/Express backend for BlindMeet dark fantasy dating app with real-time chat using Socket.IO.

## Tech Stack

- **Framework**: Express.js
- **Database**: PostgreSQL
- **Real-time**: Socket.IO
- **Authentication**: Firebase Auth + JWT
- **Storage**: Firebase Storage / AWS S3
- **Security**: Helmet, CORS, Rate Limiting

## Project Structure

```
src/
├── config/           # Database & Firebase configuration
├── controllers/      # Business logic & request handlers
├── middleware/       # Auth, error handling, rate limiting
├── models/          # Database models
├── routes/          # API endpoints
├── socket/          # Socket.IO real-time chat
├── utils/           # JWT, validation helpers
└── index.js         # Express server
```

## Setup Instructions

### 1. Prerequisites

- Node.js 16+ (tested with 18.x)
- PostgreSQL 12+
- npm or yarn

### 2. Installation

```bash
cd backend

# Install dependencies
npm install
```

### 3. Environment Setup

Create a `.env` file in the backend directory (copy from `.env.example`):

```bash
cp .env.example .env
```

Edit `.env` with your configuration:

```env
# Server
PORT=5000
NODE_ENV=development

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=blindmeet
DB_USER=postgres
DB_PASSWORD=your_password

# Firebase Configuration
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_PRIVATE_KEY=your_private_key
FIREBASE_CLIENT_EMAIL=your_client_email

# JWT
JWT_SECRET=generate_a_strong_random_key_here
JWT_EXPIRE=7d

# Frontend URL (for CORS)
FRONTEND_URL=http://localhost:3000
```

### 4. Database Setup

#### Create Database

```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE blindmeet;

# Connect to the database
\c blindmeet
```

#### Run Schema

```bash
# From the backend directory
psql -U postgres -d blindmeet -f ../database/schema.sql
```

Or run it manually in psql:

```sql
\i ../database/schema.sql
```

### 5. Firebase Setup

1. Create a Firebase project: https://console.firebase.google.com/
2. Add an Android app with package name: `com.example.blindmeet`
3. Download `google-services.json` and place it in `frontend/android/app/`
4. Enable Authentication → Sign-in method → Google
5. Create a Service Account key:
   - Project Settings → Service Accounts → Generate New Private Key
   - Copy the JSON content and add these values to `.env`:
     - `FIREBASE_PROJECT_ID`
     - `FIREBASE_PRIVATE_KEY`
     - `FIREBASE_PRIVATE_KEY_ID`
     - `FIREBASE_CLIENT_EMAIL`
     - `FIREBASE_STORAGE_BUCKET`
6. Update the frontend Firebase config in `frontend/lib/services/firebase_options.dart`:
   - Replace placeholder values under `android`, `ios`, and `web` with your Firebase app values
   - Ensure `projectId`, `apiKey`, `appId`, and `storageBucket` are correct
7. On Android, confirm `frontend/android/app/build.gradle.kts` has `applicationId = "com.example.blindmeet"`
8. Use `frontend/lib/services/firebase_service.dart` to initialize Firebase at app startup

### 6. Admin Credential

The backend seeds an admin account automatically from `.env` when `ADMIN_EMAIL` and `ADMIN_PASSWORD` are set.

Example admin credentials in `.env`:

```env
ADMIN_EMAIL=admin@blindmeet.local
ADMIN_PASSWORD=Admin@1234
```

Use these credentials on the admin login screen after revealing the hidden admin form with a long press on the logo.

### 7. Start Development Server

```bash
npm run dev
```

Server will start on: `http://localhost:5000`

## API Endpoints

### Authentication
- `POST /api/auth/google-login` - Google Sign-In
- `POST /api/auth/logout` - Logout

### Profile
- `POST /api/profile/create` - Create profile (after first login)
- `PUT /api/profile/update` - Update profile
- `GET /api/profile/me` - Get current user profile
- `GET /api/profile/:userId` - Get public profile
- `POST /api/profile/images/upload` - Upload profile images (max 3)

### Search & Discover
- `GET /api/search/all` - Get all active users
- `GET /api/search/search?location=...&gender=...` - Search users by filters

### Requests
- `POST /api/requests/send` - Send connection request
- `POST /api/requests/accept` - Accept request
- `POST /api/requests/reject` - Reject request
- `GET /api/requests/incoming` - Get incoming requests
- `GET /api/requests/accepted` - Get accepted connections

### Chat
- `GET /api/chat/conversations` - Get user conversations
- `GET /api/chat/conversations/:conversationId/messages` - Get messages
- `POST /api/chat/messages/send` - Send message via REST (use Socket.IO for real-time)
- `GET /api/chat/unread-count` - Get unread message count

## Socket.IO Events

### Client → Server

```javascript
// User joins (call on app start)
socket.emit('user:join', userId);

// Join conversation room
socket.emit('conversation:join', { conversationId, userId });

// Send message (real-time)
socket.emit('message:send', {
  conversationId,
  senderId,
  message,
  timestamp
});

// Typing indicator
socket.emit('typing:start', { conversationId, userId, nickname });
socket.emit('typing:stop', { conversationId });

// Mark messages as read
socket.emit('message:read', { conversationId, userId });
```

### Server → Client

```javascript
// User online
'user:online', { userId, timestamp }

// User offline
'user:offline', { userId, timestamp }

// Conversation joined
'conversation:joined', { conversationId }

// Message received
'message:received', { id, conversationId, senderId, message, timestamp }

// User typing
'user:typing', { userId, nickname }
'user:typing:stop'

// Messages marked as read
'messages:marked_read', { conversationId, userId }
```

## Database Schema

### users
```sql
- id (PRIMARY KEY)
- google_id (UNIQUE)
- email (UNIQUE)
- nickname (UNIQUE)
- gender, age, location, skin_color
- weight, profession, alcoholic, bio
- profile_images (ARRAY)
- is_complete, is_active
- created_at, updated_at
```

### requests
```sql
- id (PRIMARY KEY)
- sender_id, receiver_id (FOREIGN KEYS)
- message, status (pending/accepted/rejected)
- created_at, updated_at
```

### conversations
```sql
- id (PRIMARY KEY)
- user1_id, user2_id (FOREIGN KEYS)
- last_message, last_message_at
- is_active
- created_at, updated_at
```

### messages
```sql
- id (PRIMARY KEY)
- conversation_id, sender_id (FOREIGN KEYS)
- message, is_read
- created_at
```

## Production Deployment

### Environment Variables for Production

```env
NODE_ENV=production
PORT=5000
DB_HOST=prod_db_host
DB_USER=prod_user
DB_PASSWORD=strong_password
JWT_SECRET=very_strong_secret_key
FRONTEND_URL=https://blindmeet.app
```

### Deployment Platforms

Deploy using:
- **Heroku**: `git push heroku main`
- **Railway**: Connect GitHub repository
- **AWS EC2**: Use PM2 for process management
- **DigitalOcean**: App Platform or Droplet + Nginx

### PM2 Process Management

```bash
# Install PM2
npm install -g pm2

# Start with PM2
pm2 start src/index.js --name "blindmeet"

# Monitor
pm2 monit

# Save configuration
pm2 save
```

## Testing API

### Using cURL

```bash
# Health check
curl http://localhost:5000/health

# Google Login
curl -X POST http://localhost:5000/api/auth/google-login \
  -H "Content-Type: application/json" \
  -d '{"idToken":"your_firebase_id_token"}'
```

### Using Postman

Import the API collection (create from endpoints list above) and test all endpoints.

## Security Features

✅ Helmet - HTTP headers security
✅ CORS - Cross-origin resource sharing control
✅ Rate Limiting - Prevent abuse
✅ JWT Authentication - Secure token-based auth
✅ Input Validation - Profile field validation
✅ Database Indexes - Performance optimization
✅ Error Handling - Secure error responses

## Troubleshooting

### Database Connection Error
```bash
# Check PostgreSQL is running
psql -U postgres

# Verify credentials in .env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
```

### Firebase Initialization Error
- Verify `.env` has correct Firebase credentials
- Check private key format (should have `\n` for newlines)

### Socket.IO Connection Issues
- Ensure client uses correct server URL and port
- Check CORS origin in `src/index.js`

## Performance Tips

1. Database queries use indexes on frequently searched columns
2. Pagination for large datasets (messages, users)
3. Connection pooling (max 20 connections)
4. Redis caching (future enhancement)

## Future Enhancements

- [ ] Redis caching for performance
- [ ] Image compression & CDN integration
- [ ] Two-factor authentication
- [ ] User blocking/reporting
- [ ] Admin dashboard
- [ ] Analytics & monitoring
- [ ] Push notifications
- [ ] Video call integration

## Support & Issues

For issues and questions, create an issue in the repository.

---

Built with ❤️ for BlindMeet
