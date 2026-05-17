// src/controllers/chatController.js
import Conversation from '../models/Conversation.js';
import Message from '../models/Message.js';

export const getConversations = async (req, res) => {
  try {
    const userId = req.user.userId;

    const conversations = await Conversation.getUserConversations(userId);

    res.status(200).json({
      success: true,
      conversations,
    });
  } catch (error) {
    console.error('Get conversations error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch conversations',
    });
  }
};

export const getMessages = async (req, res) => {
  try {
    const { conversationId } = req.params;
    const { limit = 50, offset = 0 } = req.query;
    const userId = req.user.userId;

    const conversation = await Conversation.getConversationById(conversationId);

    if (!conversation) {
      return res.status(404).json({
        success: false,
        message: 'Conversation not found',
      });
    }

    // Verify user is part of conversation
    if (
      conversation.user1_id !== userId &&
      conversation.user2_id !== userId
    ) {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized',
      });
    }

    // Mark messages as read
    await Message.markAsRead(conversationId, userId);

    const messages = await Message.getMessagesByConversation(
      conversationId,
      parseInt(limit, 10),
      parseInt(offset, 10)
    );

    res.status(200).json({
      success: true,
      messages,
    });
  } catch (error) {
    console.error('Get messages error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch messages',
    });
  }
};

export const sendMessage = async (req, res) => {
  try {
    const { conversationId, message } = req.body;
    const userId = req.user.userId;

    if (!conversationId || !message) {
      return res.status(400).json({
        success: false,
        message: 'Conversation ID and message are required',
      });
    }

    const conversation = await Conversation.getConversationById(conversationId);

    if (!conversation) {
      return res.status(404).json({
        success: false,
        message: 'Conversation not found',
      });
    }

    if (
      conversation.user1_id !== userId &&
      conversation.user2_id !== userId
    ) {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized',
      });
    }

    const newMessage = await Message.create(conversationId, userId, message);
    await Conversation.updateLastMessage(conversationId, message);

    res.status(201).json({
      success: true,
      message: newMessage,
    });
  } catch (error) {
    console.error('Send message error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to send message',
    });
  }
};

export const getUnreadCount = async (req, res) => {
  try {
    const userId = req.user.userId;

    const count = await Message.getUnreadCount(userId);

    res.status(200).json({
      success: true,
      unreadCount: count,
    });
  } catch (error) {
    console.error('Get unread count error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch unread count',
    });
  }
};
