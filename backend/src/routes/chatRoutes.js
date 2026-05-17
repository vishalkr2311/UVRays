// src/routes/chatRoutes.js
import express from 'express';
import {
  getConversations,
  getMessages,
  sendMessage,
  getUnreadCount,
} from '../controllers/chatController.js';
import { authenticateToken } from '../middleware/auth.js';

const router = express.Router();

router.use(authenticateToken);

router.get('/conversations', getConversations);
router.get('/conversations/:conversationId/messages', getMessages);
router.post('/messages/send', sendMessage);
router.get('/unread-count', getUnreadCount);

export default router;
