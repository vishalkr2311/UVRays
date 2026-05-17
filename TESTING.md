# BlindMeet Testing Guide

## Overview

This document outlines all testing procedures for the BlindMeet application including unit tests, integration tests, and end-to-end tests.

## Backend Testing

### Setup

```bash
cd backend
npm install --save-dev jest supertest
```

### API Testing

#### Health Check
```bash
curl http://localhost:5000/health
```

Expected Response:
```json
{
  "success": true,
  "message": "Server is running",
  "database": "Connected"
}
```

#### Authentication Tests

1. **Google Login**
```bash
curl -X POST http://localhost:5000/api/auth/google-login \
  -H "Content-Type: application/json" \
  -d '{"idToken":"YOUR_FIREBASE_TOKEN"}'
```

Expected: `{ "success": true, "accessToken": "...", "user": {...} }`

2. **Protected Route Test**
```bash
curl http://localhost:5000/api/profile/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

#### Profile Management Tests

1. **Create Profile**
```bash
curl -X POST http://localhost:5000/api/profile/create \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "nickname": "Sarah123",
    "gender": "Female",
    "age": 25,
    "location": "New York",
    "skinColor": "Fair",
    "weight": 55,
    "profession": "Student",
    "alcoholic": false,
    "bio": "Love reading and hiking"
  }'
```

2. **Update Profile**
```bash
curl -X PUT http://localhost:5000/api/profile/update \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"bio": "Updated bio text"}'
```

3. **Get Profile**
```bash
curl http://localhost:5000/api/profile/me \
  -H "Authorization: Bearer YOUR_TOKEN"
```

4. **Get Public Profile**
```bash
curl http://localhost:5000/api/profile/2
```

#### Search Tests

1. **Get All Users**
```bash
curl http://localhost:5000/api/search/all \
  -H "Authorization: Bearer YOUR_TOKEN"
```

2. **Search with Filters**
```bash
curl "http://localhost:5000/api/search/search?location=New York&gender=Female&minAge=20&maxAge=30" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

#### Connection Request Tests

1. **Send Request**
```bash
curl -X POST http://localhost:5000/api/requests/send \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"receiverId": 2, "message": "Hi, interested in connecting"}'
```

2. **Accept Request**
```bash
curl -X POST http://localhost:5000/api/requests/accept \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"requestId": 1}'
```

3. **Reject Request**
```bash
curl -X POST http://localhost:5000/api/requests/reject \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"requestId": 1}'
```

#### Chat Tests

1. **Get Conversations**
```bash
curl http://localhost:5000/api/chat/conversations \
  -H "Authorization: Bearer YOUR_TOKEN"
```

2. **Get Messages**
```bash
curl "http://localhost:5000/api/chat/conversations/1/messages?limit=50&offset=0" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

3. **Send Message**
```bash
curl -X POST http://localhost:5000/api/chat/messages/send \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"conversationId": 1, "message": "Hello!"}'
```

### Database Testing

```bash
# Test database connection
psql -U postgres -c "SELECT version();"

# Verify schema
psql -U postgres -d blindmeet -c "\dt"

# Check users table
psql -U postgres -d blindmeet -c "SELECT COUNT(*) FROM users;"

# Verify constraints
psql -U postgres -d blindmeet -c "\d users"
```

### Socket.IO Testing

Use WebSocket client or test with curl:

```bash
# Install WebSocket client
npm install -g wscat

# Connect to Socket.IO
wscat -c "http://localhost:5000/socket.io"

# Send events
{"emit":["user:join",123]}
{"emit":["conversation:join",{"conversationId":1,"userId":123}]}
{"emit":["message:send",{"conversationId":1,"senderId":123,"message":"Hello"}]}
```

## Frontend Testing

### Unit Tests

```bash
cd frontend

# Create test file
touch test/models/user_model_test.dart

# Run tests
flutter test

# Run specific test
flutter test test/models/user_model_test.dart

# Run with coverage
flutter test --coverage
```

### Widget Tests

```bash
# Test widget rendering
flutter test test/widgets/neon_gradient_button_test.dart

# Test user interactions
flutter test test/screens/login_screen_test.dart
```

### Integration Tests

```bash
# Run integration tests
flutter drive --target=test_driver/app.dart

# On Firebase emulator
flutter test --emulator-only
```

### Manual Testing Checklist

#### Authentication Flow
- [ ] Google Sign-In works
- [ ] Token stored locally
- [ ] User redirected to profile setup if first login
- [ ] User redirected to home if returning
- [ ] Logout functionality works
- [ ] Token refresh on app restart

#### Profile Setup
- [ ] All fields validate correctly
- [ ] Nickname uniqueness validation works
- [ ] Age range validation (18-60)
- [ ] Navigation between steps works
- [ ] Back button functionality
- [ ] Profile saves successfully

#### Home Navigation
- [ ] All 4 tabs visible
- [ ] Tab switching works smoothly
- [ ] Bottom navigation displays correctly
- [ ] Tab icons are visible

#### User Discovery
- [ ] Users load on app start
- [ ] Search filters work
- [ ] User cards display correctly
- [ ] Loading states shown
- [ ] Error handling works

#### Messaging
- [ ] Conversation list loads
- [ ] Can select conversation
- [ ] Messages load
- [ ] Can send message
- [ ] Real-time message received
- [ ] Typing indicator shows
- [ ] Online/offline status updates

#### Connection Requests
- [ ] Can send request
- [ ] Request shows in receiver's list
- [ ] Can accept request
- [ ] Can reject request
- [ ] Accepted request creates conversation

## Performance Testing

### Backend Performance

```bash
# Load testing with Apache Bench
ab -n 1000 -c 10 http://localhost:5000/health

# Using autocannon
npm install -g autocannon
autocannon http://localhost:5000/api/search/all
```

### Frontend Performance

```bash
# Measure frame rates
flutter run --profile

# Capture timeline
flutter run --profile --trace-skia
```

### Database Performance

```bash
# Check query execution time
\timing

SELECT * FROM users WHERE location = 'New York';
```

## Security Testing

### SQL Injection Tests

```bash
# Should NOT return data
curl "http://localhost:5000/api/search/search?location='; DROP TABLE users; --"
```

### Authentication Tests

```bash
# Should be rejected (no token)
curl http://localhost:5000/api/profile/me

# Should be rejected (invalid token)
curl http://localhost:5000/api/profile/me \
  -H "Authorization: Bearer invalid_token"

# Should be rejected (expired token)
curl http://localhost:5000/api/profile/me \
  -H "Authorization: Bearer expired_token"
```

### CORS Tests

```bash
# Should respect CORS origin
curl -H "Origin: http://unauthorized.com" \
  -H "Access-Control-Request-Method: POST" \
  -X OPTIONS http://localhost:5000/api/auth/google-login
```

## Bug Report Template

```markdown
## Bug Report

**Title**: [Clear title]

**Severity**: Critical / High / Medium / Low

**Platform**: Android / iOS / Web

**Steps to Reproduce**:
1. ...
2. ...
3. ...

**Expected Result**: 
[What should happen]

**Actual Result**: 
[What actually happens]

**Screenshots/Logs**: 
[Attach relevant files]

**Environment**:
- OS: 
- App Version: 
- Backend Version:
```

## Testing Metrics

### Code Coverage Goals
- Backend: 80%+
- Frontend: 70%+

### Performance Benchmarks
- API response time: < 200ms
- App startup time: < 2s
- Database query: < 50ms
- Socket latency: < 100ms

### Error Rates
- API errors: < 0.1%
- Crash rate: < 0.01%
- Network errors: < 1%

## Continuous Testing

### GitHub Actions CI/CD

```yaml
name: Tests

on: [push, pull_request]

jobs:
  backend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-node@v2
        with:
          node-version: '16'
      - run: cd backend && npm install && npm test

  flutter-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: cd frontend && flutter pub get && flutter test
```

## Testing Automation

Set up automated testing:
1. Unit tests on every commit
2. Integration tests on pull request
3. Performance tests weekly
4. Security scan monthly
5. Load testing quarterly

---

For detailed test implementation, see:
- `/backend/tests/` - backend unit tests
- `/frontend/test/` - flutter tests
- `/docs/API_TESTING.md` - API documentation

Last Updated: May 2026
