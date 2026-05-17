// src/controllers/authController.js
import bcrypt from 'bcryptjs';
import nodemailer from 'nodemailer';
import { auth } from '../config/firebase.js';
import User from '../models/User.js';
import { generateToken } from '../utils/jwt.js';

const createTransporter = () => {
  if (
    process.env.SMTP_HOST &&
    process.env.SMTP_PORT &&
    process.env.SMTP_USER &&
    process.env.SMTP_PASS
  ) {
    return nodemailer.createTransport({
      host: process.env.SMTP_HOST,
      port: parseInt(process.env.SMTP_PORT, 10),
      secure: process.env.SMTP_SECURE === 'true',
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS,
      },
    });
  }

  return null;
};

const sendOtpEmail = async (email, otpCode) => {
  const transporter = createTransporter();

  if (!transporter) {
    console.warn('SMTP is not configured. OTP is logged to console.');
    console.log(`OTP for ${email}: ${otpCode}`);
    return;
  }

  const message = {
    from: process.env.SMTP_FROM || process.env.SMTP_USER || 'no-reply@blindmeet.app',
    to: email,
    subject: 'BlindMeet OTP Login Code',
    text: `Your BlindMeet login code is ${otpCode}. It expires in 10 minutes.`,
    html: `<p>Your BlindMeet login code is <strong>${otpCode}</strong>. It expires in 10 minutes.</p>`,
  };

  await transporter.sendMail(message);
};

export const googleLogin = async (req, res) => {
  try {
    const { idToken } = req.body;

    if (!idToken) {
      return res.status(400).json({ message: 'ID token is required' });
    }

    if (!process.env.FIREBASE_PROJECT_ID || !process.env.FIREBASE_PRIVATE_KEY || !process.env.FIREBASE_CLIENT_EMAIL) {
      return res.status(503).json({
        success: false,
        message:
          'Google authentication is not configured on the backend. Please set Firebase Admin service account credentials.',
      });
    }

    const decodedToken = await auth.verifyIdToken(idToken);
    const { uid, email } = decodedToken;

    let user = await User.findByGoogleId(uid);
    if (!user) {
      user = await User.create({
        googleId: uid,
        email,
      });
    }

    const accessToken = generateToken(user.id, email, user.role || 'user');
    const isProfileComplete = user.is_complete === true;

    res.status(200).json({
      success: true,
      user: {
        id: user.id,
        email: user.email,
        nickname: user.nickname,
        role: user.role,
        isProfileComplete,
      },
      accessToken,
    });
  } catch (error) {
    console.error('Google login error:', error);
    res.status(500).json({ success: false, message: 'Login failed' });
  }
};

export const requestEmailOtp = async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ success: false, message: 'Email is required' });
    }

    let user = await User.findByEmail(email);
    if (!user) {
      user = await User.createWithEmail(email);
    }

    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000);
    await User.setOtpForEmail(email, otpCode, expiresAt);
    await sendOtpEmail(email, otpCode);

    res.status(200).json({ success: true, message: 'OTP sent to email' });
  } catch (error) {
    console.error('OTP request error:', error);
    res.status(500).json({ success: false, message: 'Unable to send OTP' });
  }
};

export const verifyEmailOtp = async (req, res) => {
  try {
    const { email, otpCode } = req.body;
    if (!email || !otpCode) {
      return res.status(400).json({ success: false, message: 'Email and OTP are required' });
    }

    const user = await User.verifyOtp(email, otpCode);
    if (!user) {
      return res.status(401).json({ success: false, message: 'Invalid or expired OTP' });
    }

    const accessToken = generateToken(user.id, email, user.role || 'user');
    res.status(200).json({
      success: true,
      user: {
        id: user.id,
        email: user.email,
        nickname: user.nickname,
        role: user.role,
        isProfileComplete: user.is_complete === true,
      },
      accessToken,
    });
  } catch (error) {
    console.error('OTP verify error:', error);
    res.status(500).json({ success: false, message: 'Unable to verify OTP' });
  }
};

export const adminLogin = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Email and password are required' });
    }

    const user = await User.findByEmail(email);
    if (!user || user.role !== 'admin') {
      return res.status(401).json({ success: false, message: 'Unauthorized admin credentials' });
    }

    const passwordMatches = user.password_hash && bcrypt.compareSync(password, user.password_hash);
    if (!passwordMatches) {
      return res.status(401).json({ success: false, message: 'Invalid password' });
    }

    const accessToken = generateToken(user.id, email, 'admin');
    res.status(200).json({
      success: true,
      user: {
        id: user.id,
        email: user.email,
        nickname: user.nickname,
        role: user.role,
      },
      accessToken,
    });
  } catch (error) {
    console.error('Admin login error:', error);
    res.status(500).json({ success: false, message: 'Admin login failed' });
  }
};

export const logout = async (req, res) => {
  try {
    res.status(200).json({ success: true, message: 'Logged out successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Logout failed' });
  }
};
