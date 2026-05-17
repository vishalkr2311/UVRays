@echo off
REM BlindMeet Setup Script for Windows

echo.
echo ===================================
echo  BlindMeet Application Setup
echo ===================================
echo.

REM Check if Node.js is installed
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Node.js is not installed. Please install Node.js 16+ first.
    exit /b 1
)

REM Check if Flutter is installed
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Flutter is not installed. Please install Flutter 3.10+ first.
    exit /b 1
)

REM Check if PostgreSQL is installed
where psql >nul 2>nul
if %errorlevel% neq 0 (
    echo [WARNING] PostgreSQL not found in PATH. Make sure it's installed and configured.
)

echo [OK] Prerequisites check completed.
echo.

REM Setup Backend
echo ===================================
echo  Setting up Backend...
echo ===================================
echo.

cd backend

if exist node_modules (
    echo [INFO] node_modules already exists. Skipping npm install.
) else (
    echo [INFO] Installing backend dependencies...
    call npm install
    if %errorlevel% neq 0 (
        echo [ERROR] Backend installation failed.
        exit /b 1
    )
)

if not exist .env (
    echo [INFO] Creating .env file...
    copy .env.example .env
    echo [WARNING] Please update .env with your Firebase and database credentials.
) else (
    echo [INFO] .env file already exists.
)

cd..

echo [OK] Backend setup completed.
echo.

REM Setup Frontend
echo ===================================
echo  Setting up Frontend...
echo ===================================
echo.

cd frontend

echo [INFO] Running flutter pub get...
call flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] Frontend setup failed.
    exit /b 1
)

cd..

echo [OK] Frontend setup completed.
echo.

REM Database Setup
echo ===================================
echo  Database Setup Instructions
echo ===================================
echo.
echo To setup PostgreSQL database:
echo 1. Create database: createdb blindmeet
echo 2. Run schema: psql -U postgres -d blindmeet -f database/schema.sql
echo.

echo ===================================
echo  Setup Complete!
echo ===================================
echo.
echo Next steps:
echo 1. Configure Firebase credentials in backend/.env
echo 2. Update Firebase config in frontend/lib/services/firebase_options.dart
echo 3. Run backend: cd backend && npm run dev
echo 4. Run frontend: cd frontend && flutter run
echo.

pause
