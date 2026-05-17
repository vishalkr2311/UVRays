// src/routes/searchRoutes.js
import express from 'express';
import { searchUsers, getAllUsers } from '../controllers/searchController.js';
import { authenticateToken } from '../middleware/auth.js';

const router = express.Router();

router.use(authenticateToken);

router.get('/search', searchUsers);
router.get('/all', getAllUsers);

export default router;
