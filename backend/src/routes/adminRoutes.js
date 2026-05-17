// src/routes/adminRoutes.js
import express from 'express';
import {
  getAdminDashboard,
  getAllUsers,
  broadcastNotification,
  deleteUser,
  setUserPassword,
} from '../controllers/adminController.js';
import { authenticateAdmin } from '../middleware/auth.js';

const router = express.Router();

router.use(authenticateAdmin);

router.get('/dashboard', getAdminDashboard);
router.get('/users', getAllUsers);
router.post('/broadcast', broadcastNotification);
router.delete('/users/:id', deleteUser);
router.put('/users/:id/password', setUserPassword);

export default router;
