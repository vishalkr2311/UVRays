# BlindMeet Deployment Guide

## Overview

This guide covers deploying BlindMeet to production across multiple platforms.

## Prerequisites

- All local development setup completed
- Git repository initialized
- Firebase project configured
- Domain name (for production)
- SSL certificate (for HTTPS)

## Backend Deployment

### Option 1: Heroku (Recommended for MVP)

#### Setup

1. Install Heroku CLI:
```bash
brew tap heroku/brew && brew install heroku  # macOS
# or download from https://devcenter.heroku.com/articles/heroku-cli
```

2. Login to Heroku:
```bash
heroku login
```

3. Create Heroku app:
```bash
cd backend
heroku create blindmeet-backend
```

4. Add PostgreSQL addon:
```bash
heroku addons:create heroku-postgresql:hobby-dev -a blindmeet-backend
```

5. Set environment variables:
```bash
heroku config:set NODE_ENV=production -a blindmeet-backend
heroku config:set JWT_SECRET=your_strong_secret_key_here -a blindmeet-backend
heroku config:set FIREBASE_PROJECT_ID=your_project_id -a blindmeet-backend
heroku config:set FIREBASE_PRIVATE_KEY="your_private_key" -a blindmeet-backend
heroku config:set FIREBASE_CLIENT_EMAIL=your_email -a blindmeet-backend
heroku config:set FIREBASE_STORAGE_BUCKET=your_bucket -a blindmeet-backend
heroku config:set FRONTEND_URL=https://your-app.netlify.app -a blindmeet-backend
```

6. Deploy:
```bash
git add .
git commit -m "Deploy to production"
git push heroku main
```

7. Run database migrations:
```bash
heroku run "cat database/schema.sql | psql \$DATABASE_URL" -a blindmeet-backend
```

### Option 2: Railway

1. Install Railway CLI:
```bash
npm i -g @railway/cli
```

2. Login and initialize:
```bash
railway login
cd backend
railway init
```

3. Add PostgreSQL plugin from Railway dashboard

4. Set environment variables in Railway dashboard

5. Deploy:
```bash
railway up
```

### Option 3: AWS EC2

1. Launch EC2 instance (Ubuntu 20.04)

2. Install dependencies:
```bash
sudo apt-get update
sudo apt-get install -y nodejs npm postgresql postgresql-contrib nginx
```

3. Clone repository:
```bash
git clone https://github.com/yourusername/blindmeet.git
cd blindmeet/backend
```

4. Install and start:
```bash
npm install
npm install -g pm2

# Setup PM2
pm2 start src/index.js --name "blindmeet"
pm2 startup
pm2 save
```

5. Setup Nginx reverse proxy:
```bash
sudo nano /etc/nginx/sites-available/blindmeet
```

Add:
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /socket.io {
        proxy_pass http://localhost:5000/socket.io;
        proxy_http_version 1.1;
        proxy_buffering off;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'Upgrade';
    }
}
```

6. Enable SSL with Let's Encrypt:
```bash
sudo apt-get install -y certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

## Frontend Deployment

### Option 1: Android Deployment (Google Play Store)

1. Build release APK:
```bash
cd frontend
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

2. Create Google Play Developer account ($25 one-time fee)

3. Create app in Google Play Console

4. Upload APK with required:
   - App description
   - Screenshots (min 2)
   - Privacy policy
   - Content rating

5. Submit for review (usually 2-4 hours)

### Option 2: iOS Deployment (App Store)

1. Generate iOS release build:
```bash
cd frontend
flutter build ios --release
```

2. Create Apple Developer account ($99/year)

3. In Xcode:
```bash
cd ios
open Runner.xcworkspace
```

4. Configure signing:
   - Set Team ID
   - Update bundle identifier
   - Configure code signing

5. Create archive:
   - Product → Archive
   - Validate app
   - Upload to App Store

### Option 3: Web Deployment (Firebase Hosting)

1. Build web release:
```bash
cd frontend
flutter build web --release
```

2. Install Firebase CLI:
```bash
npm install -g firebase-tools
```

3. Initialize Firebase:
```bash
firebase login
firebase init hosting
```

4. Deploy:
```bash
firebase deploy --only hosting
```

## Database Backup & Maintenance

### Daily Backup

```bash
# Linux/macOS
pg_dump -U blindmeet_user -d blindmeet > backup_$(date +%Y%m%d_%H%M%S).sql

# Heroku
heroku pg:backups:capture -a blindmeet-backend
```

### Restore from Backup

```bash
# Linux/macOS
psql -U blindmeet_user -d blindmeet < backup_file.sql

# Heroku
heroku pg:backups:restore backup_file -a blindmeet-backend
```

## Monitoring & Logging

### Backend Logs

```bash
# Heroku
heroku logs --tail -a blindmeet-backend

# AWS/Local
pm2 logs blindmeet
```

### Health Checks

```bash
# Test backend health
curl https://api.blindmeet.app/health

# Monitor uptime
# Use services like UptimeRobot, Pingdom, etc.
```

## Performance Optimization

### Backend

```javascript
// Enable gzip compression in src/index.js
import compression from 'compression';
app.use(compression());

// Add Redis caching (future enhancement)
// Add database query optimization
// Monitor with New Relic, DataDog
```

### Frontend

```bash
# Build optimized release
flutter build --profile

# Monitor with Firebase Crashlytics
# Use Firebase Performance Monitoring
```

## Security Checklist

- [ ] Firebase auth configured with Google
- [ ] HTTPS/SSL enabled on backend
- [ ] Environment variables secured
- [ ] Database backups automated
- [ ] Rate limiting configured
- [ ] CORS whitelist configured
- [ ] API keys rotated
- [ ] Database encryption enabled
- [ ] Regular security audits
- [ ] DDoS protection (CloudFlare)

## Rollback Procedure

```bash
# Heroku
heroku releases --a blindmeet-backend
heroku rollback v123 -a blindmeet-backend

# Git
git revert commit_hash
git push heroku main

# Docker
docker pull blindmeet:previous-version
docker run -d blindmeet:previous-version
```

## Troubleshooting

### 502 Bad Gateway

- Check backend running: `pm2 list`
- Check logs: `pm2 logs`
- Verify database connection
- Check Nginx configuration

### Database Connection Fails

```bash
# Verify connection string
psql $DATABASE_URL

# Check database status
\l

# Check user permissions
\du
```

### Socket.IO Not Working

- Verify CORS configuration
- Check firewall rules
- Verify WebSocket proxy settings
- Test with: `websocketking.com`

## Cost Estimation

### Monthly Costs (Estimated)

- Heroku Backend: $7 (hobby-dev)
- Heroku PostgreSQL: $9 (hobby-dev)
- Firebase: $0-25 (depending on usage)
- Domain: $10-15
- Email/Support: $0-50

**Total MVP: $26-99/month**

## Next Steps

1. Setup CI/CD pipeline (GitHub Actions)
2. Configure automated testing
3. Setup monitoring and alerts
4. Implement backup automation
5. Plan scaling strategy

For production scaling:
- Migration to AWS/GCP
- Kubernetes orchestration
- Redis caching layer
- CDN distribution
- Advanced monitoring

---

Last Updated: May 2026
