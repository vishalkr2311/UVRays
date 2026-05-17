// src/routes/profileRoutes.js
import express from 'express';
import multer from 'multer';
import {
  createProfile,
  updateProfile,
  getProfile,
  getPublicProfile,
  uploadProfileImages,
} from '../controllers/profileController.js';
import { authenticateToken } from '../middleware/auth.js';

const router = express.Router();
const upload = multer({ storage: multer.memoryStorage() });

router.use(authenticateToken);

router.post('/create', createProfile);
router.put('/update', updateProfile);
router.get('/me', getProfile);
router.get('/:userId', getPublicProfile);
router.post('/images/upload', upload.array('images', 3), uploadProfileImages);

export default router;
