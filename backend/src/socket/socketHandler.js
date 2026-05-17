// src/socket/socketHandler.js
import Message from '../models/Message.js';
import Conversation from '../models/Conversation.js';

// Store active users
const activeUsers = new Map();
let ioServer = null;

export const setSocketServer = (io) => {
  ioServer = io;
};

export const emitAdminNotification = (payload) => {
  if (ioServer) {
    ioServer.emit('admin:notification', payload);
  }
};

export const initializeSocket = (io) => {
  ioServer = io;
  io.on('connection', (socket) => {
    console.log(`User connected: ${socket.id}`);

    // User joins with their ID
    socket.on('user:join', (userId) => {
      activeUsers.set(userId, socket.id);
      socket.join(`user:${userId}`);
      console.log(`User ${userId} joined with socket ${socket.id}`);

      // Notify all connected clients
      io.emit('user:online', {
        userId,
        timestamp: new Date(),
      });
    });

    // User starts typing
    socket.on('typing:start', (data) => {
      const { conversationId, userId, nickname } = data;
      socket.to(`conversation:${conversationId}`).emit('user:typing', {
        userId,
        nickname,
      });
    });

    // User stops typing
    socket.on('typing:stop', (data) => {
      const { conversationId } = data;
      socket.to(`conversation:${conversationId}`).emit('user:typing:stop');
    });

    // User joins a conversation
    socket.on('conversation:join', (data) => {
      const { conversationId, userId } = data;
      socket.join(`conversation:${conversationId}`);
      socket.emit('conversation:joined', { conversationId });
      console.log(`User ${userId} joined conversation ${conversationId}`);
    });

    // User leaves a conversation
    socket.on('conversation:leave', (data) => {
      const { conversationId } = data;
      socket.leave(`conversation:${conversationId}`);
    });

    // Send message via Socket.IO
    socket.on('message:send', async (data) => {
      try {
        const { conversationId, senderId, message, timestamp } = data;

        // Save message to database
        const newMessage = await Message.create(
          conversationId,
          senderId,
          message
        );

        // Update conversation's last message
        await Conversation.updateLastMessage(conversationId, message);

        // Broadcast to conversation room
        io.to(`conversation:${conversationId}`).emit('message:received', {
          id: newMessage.id,
          conversationId,
          senderId,
          message,
          timestamp: newMessage.created_at,
        });

        console.log(
          `Message sent in conversation ${conversationId} by user ${senderId}`
        );
      } catch (error) {
        console.error('Error sending message:', error);
        socket.emit('message:error', { message: 'Failed to send message' });
      }
    });

    // Read messages
    socket.on('message:read', async (data) => {
      try {
        const { conversationId, userId } = data;
        await Message.markAsRead(conversationId, userId);

        io.to(`conversation:${conversationId}`).emit('messages:marked_read', {
          conversationId,
          userId,
        });
      } catch (error) {
        console.error('Error marking messages as read:', error);
      }
    });

    // Handle disconnection
    socket.on('disconnect', () => {
      let userId = null;
      for (const [key, value] of activeUsers.entries()) {
        if (value === socket.id) {
          userId = key;
          activeUsers.delete(key);
          break;
        }
      }

      if (userId) {
        console.log(`User ${userId} disconnected`);
        io.emit('user:offline', {
          userId,
          timestamp: new Date(),
        });
      }
    });

    // Health check
    socket.on('ping', () => {
      socket.emit('pong');
    });
  });

  return activeUsers;
};

export const getActiveUsers = () => {
  return activeUsers;
};
