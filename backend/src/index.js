// src/index.js
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import morgan from 'morgan';
import { createServer } from 'http';
import { Server } from 'socket.io';
import dotenv from 'dotenv';
import pool from './config/database.js';
import bcrypt from 'bcryptjs';
import User from './models/User.js';
import { initializeSocket, setSocketServer } from './socket/socketHandler.js';
import { errorHandler, notFound } from './middleware/errorHandler.js';

// Routes
import authRoutes from './routes/authRoutes.js';
import profileRoutes from './routes/profileRoutes.js';
import searchRoutes from './routes/searchRoutes.js';
import requestRoutes from './routes/requestRoutes.js';
import chatRoutes from './routes/chatRoutes.js';
import adminRoutes from './routes/adminRoutes.js';

dotenv.config();

const app = express();
const httpServer = createServer(app);
const io = new Server(httpServer, {
  cors: {
    origin: process.env.FRONTEND_URL || 'http://localhost:3000',
    methods: ['GET', 'POST'],
    credentials: true,
  },
});

const PORT = process.env.PORT || 5000;
const NODE_ENV = process.env.NODE_ENV || 'development';

// Middleware
app.use(helmet());
app.use(morgan('dev'));
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  credentials: true,
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000', 10),
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100', 10),
  message: 'Too many requests from this IP, please try again later.',
});

app.use('/api/', limiter);

// Body parser
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));

// Test database connection
app.get('/health', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW()');
    res.status(200).json({
      success: true,
      message: 'Server is running',
      database: 'Connected',
      timestamp: result.rows[0],
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
      database: 'Disconnected',
      error: error.message,
    });
  }
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/profile', profileRoutes);
app.use('/api/search', searchRoutes);
app.use('/api/requests', requestRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/admin', adminRoutes);

// Socket.IO
setSocketServer(io);
initializeSocket(io);

const initializeAdminAccount = async () => {
  const adminEmail = process.env.ADMIN_EMAIL;
  const adminPassword = process.env.ADMIN_PASSWORD;

  if (!adminEmail || !adminPassword) {
    console.warn('ADMIN_EMAIL and ADMIN_PASSWORD are not configured; admin account will not be seeded.');
    return;
  }

  try {
    const existingAdmin = await User.findByEmail(adminEmail);
    const passwordHash = bcrypt.hashSync(adminPassword, 10);

    if (existingAdmin) {
      await User.updateRole(existingAdmin.id, 'admin');
      await User.setPassword(existingAdmin.id, passwordHash);
      console.log(`Admin account updated for ${adminEmail}`);
    } else {
      await User.createAdmin(adminEmail, passwordHash);
      console.log(`Admin account created for ${adminEmail}`);
    }
  } catch (error) {
    console.error('Admin initialization failed:', error);
  }
};

initializeAdminAccount();

// Error handling
app.use(notFound);
app.use(errorHandler);

// Start server
httpServer.listen(PORT, () => {
  console.log(`🚀 BlindMeet Backend running on port ${PORT} in ${NODE_ENV} mode`);
  console.log(`📊 API Base URL: http://localhost:${PORT}/api`);
  console.log(`🔌 WebSocket URL: ws://localhost:${PORT}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  httpServer.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});

export default app;
