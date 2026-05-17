#!/bin/bash

# BlindMeet Setup Script for macOS/Linux

echo ""
echo "==================================="
echo " BlindMeet Application Setup"
echo "==================================="
echo ""

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "[ERROR] Node.js is not installed. Please install Node.js 16+ first."
    exit 1
fi

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "[ERROR] Flutter is not installed. Please install Flutter 3.10+ first."
    exit 1
fi

# Check PostgreSQL
if ! command -v psql &> /dev/null; then
    echo "[WARNING] PostgreSQL not found. Make sure it's installed."
fi

echo "[OK] Prerequisites check completed."
echo ""

# Setup Backend
echo "==================================="
echo " Setting up Backend..."
echo "==================================="
echo ""

cd backend || exit

if [ -d "node_modules" ]; then
    echo "[INFO] node_modules exists. Skipping npm install."
else
    echo "[INFO] Installing backend dependencies..."
    npm install
    if [ $? -ne 0 ]; then
        echo "[ERROR] Backend installation failed."
        exit 1
    fi
fi

if [ ! -f ".env" ]; then
    echo "[INFO] Creating .env file..."
    cp .env.example .env
    echo "[WARNING] Please update .env with Firebase and database credentials."
else
    echo "[INFO] .env file already exists."
fi

cd ..

echo "[OK] Backend setup completed."
echo ""

# Setup Frontend
echo "==================================="
echo " Setting up Frontend..."
echo "==================================="
echo ""

cd frontend || exit

echo "[INFO] Running flutter pub get..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "[ERROR] Frontend setup failed."
    exit 1
fi

cd ..

echo "[OK] Frontend setup completed."
echo ""

# Database Setup
echo "==================================="
echo " Database Setup Instructions"
echo "==================================="
echo ""
echo "To setup PostgreSQL database:"
echo "1. Create database: createdb blindmeet"
echo "2. Run schema: psql -U postgres -d blindmeet -f database/schema.sql"
echo ""

echo "==================================="
echo " Setup Complete!"
echo "==================================="
echo ""
echo "Next steps:"
echo "1. Configure Firebase credentials in backend/.env"
echo "2. Update Firebase config in frontend/lib/services/firebase_options.dart"
echo "3. Run backend: cd backend && npm run dev"
echo "4. Run frontend: cd frontend && flutter run"
echo ""
