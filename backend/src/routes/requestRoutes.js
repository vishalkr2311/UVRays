// src/routes/requestRoutes.js
import express from 'express';
import {
  sendRequest,
  acceptRequest,
  rejectRequest,
  getIncomingRequests,
  getAcceptedConnections,
} from '../controllers/requestController.js';
import { authenticateToken } from '../middleware/auth.js';

const router = express.Router();

router.use(authenticateToken);

router.post('/send', sendRequest);
router.post('/accept', acceptRequest);
router.post('/reject', rejectRequest);
router.get('/incoming', getIncomingRequests);
router.get('/accepted', getAcceptedConnections);

export default router;
