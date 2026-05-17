# Firebase Integration Guide for BlindMeet

This guide shows how to integrate Firebase into the BlindMeet frontend and backend, and where to update the project files.

## 1. Create a Firebase Project

1. Go to https://console.firebase.google.com/
2. Click **Add project** and follow the prompts.
3. Enable Google Sign-in:
   - Authentication → Sign-in method → Google → Enable

## 2. Add Android App to Firebase

1. In Firebase Console, go to **Project Settings → General → Your apps**.
2. Add an Android app using the package name:
   - `com.example.blindmeet`
3. Download `google-services.json`.
4. Place `google-services.json` in the frontend Android folder:
   - `frontend/android/app/google-services.json`

## 3. Update `frontend/lib/services/firebase_options.dart`

Replace placeholder values in `frontend/lib/services/firebase_options.dart` with your Firebase app configuration.

- For Android, update:
  - `apiKey`
  - `appId`
  - `messagingSenderId`
  - `projectId`
  - `storageBucket`

- For iOS/macOS/web, update equivalent values if you plan to support those platforms.

Example values come from the Firebase project settings and the `google-services.json` file.

## 4. Configure Backend Firebase Admin

The backend reads Firebase service account information from environment variables in `backend/.env`.

Required values:

- `FIREBASE_PROJECT_ID`
- `FIREBASE_PRIVATE_KEY`
- `FIREBASE_PRIVATE_KEY_ID`
- `FIREBASE_CLIENT_EMAIL`
- `FIREBASE_STORAGE_BUCKET`

### How to get them

1. In Firebase Console, go to **Project Settings → Service Accounts**.
2. Click **Generate new private key**.
3. Copy values from the downloaded JSON into `backend/.env`.

Example `.env` entries:

```env
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n
FIREBASE_PRIVATE_KEY_ID=your_private_key_id
FIREBASE_CLIENT_EMAIL=your_client_email
FIREBASE_STORAGE_BUCKET=your_storage_bucket
```

> Note: keep `FIREBASE_PRIVATE_KEY` on a single line in `.env` by replacing actual line breaks with `\n`.

## 5. Configure Backend Admin Credential

The backend seeds an admin account on startup if these variables are present in `backend/.env`:

```env
ADMIN_EMAIL=admin@blindmeet.local
ADMIN_PASSWORD=Admin@1234
```

Use this admin credential for hidden admin login in the app.

## 6. Create Local Backend `.env`

Copy the example file and edit values:

```bash
cd backend
copy .env.example .env
```

Then edit `backend/.env`.

## 7. Database Setup

The backend requires PostgreSQL and the `blindmeet` database.

1. Install PostgreSQL locally.
2. Create the database and user.
3. Run the schema file:
   - `psql -U postgres -d blindmeet -f ../database/schema.sql`

If PostgreSQL CLI is unavailable, use your preferred database GUI or the included SQL schema.

## 8. Run the Backend

From the backend folder:

```bash
cd backend
npm install
npm start
```

The server should start at `http://localhost:5000`

## 9. Run the Flutter App

From the frontend folder:

```bash
cd frontend
flutter clean
flutter pub get
flutter run -d emulator-5556
```

## 10. Verify Functionality

- App starts successfully
- Login screen appears
- Email OTP request works when backend is running
- Admin login appears after long-pressing the logo
- Admin login works using the seeded credentials
- Google login works only after valid Firebase configuration

## 11. Troubleshooting

- If Google Sign-In fails with `ApiException: 10`, ensure Android SHA-1 and package name match in Firebase
- If backend fails to start, check `.env` values and PostgreSQL connection
- If `FIREBASE_PROJECT_ID` or service account values are missing, the backend will disable Google auth but still run for OTP/auth routes
