// src/routes/authRoutes.js
import express from 'express';
import {
  googleLogin,
  logout,
  requestEmailOtp,
  verifyEmailOtp,
  adminLogin,
} from '../controllers/authController.js';

const router = express.Router();

router.post('/google-login', googleLogin);
router.post('/email-otp-request', requestEmailOtp);
router.post('/email-otp-verify', verifyEmailOtp);
router.post('/admin-login', adminLogin);
router.post('/logout', logout);

export default router;
