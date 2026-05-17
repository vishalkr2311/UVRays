// src/models/Message.js
import pool from '../config/database.js';

class Message {
  static async create(conversationId, senderId, message) {
    const query = `
      INSERT INTO messages (conversation_id, sender_id, message, created_at)
      VALUES ($1, $2, $3, CURRENT_TIMESTAMP)
      RETURNING *;
    `;

    const result = await pool.query(query, [conversationId, senderId, message]);
    return result.rows[0];
  }

  static async getMessagesByConversation(conversationId, limit = 50, offset = 0) {
    const query = `
      SELECT m.*, u.nickname, u.profile_images
      FROM messages m
      JOIN users u ON m.sender_id = u.id
      WHERE m.conversation_id = $1
      ORDER BY m.created_at DESC
      LIMIT $2 OFFSET $3;
    `;

    const result = await pool.query(query, [conversationId, limit, offset]);
    return result.rows.reverse();
  }

  static async markAsRead(conversationId, userId) {
    const query = `
      UPDATE messages 
      SET is_read = true
      WHERE conversation_id = $1 AND sender_id != $2 AND is_read = false;
    `;

    await pool.query(query, [conversationId, userId]);
  }

  static async getUnreadCount(userId) {
    const query = `
      SELECT COUNT(*) 
      FROM messages m
      JOIN conversations c ON m.conversation_id = c.id
      WHERE (c.user1_id = $1 OR c.user2_id = $1) 
        AND m.sender_id != $1 
        AND m.is_read = false;
    `;

    const result = await pool.query(query, [userId]);
    return parseInt(result.rows[0].count, 10);
  }
}

export default Message;
