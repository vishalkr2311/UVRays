// src/models/Conversation.js
import pool from '../config/database.js';

class Conversation {
  static async createOrGet(user1Id, user2Id) {
    // Ensure consistent ordering
    const [firstId, secondId] = user1Id < user2Id ? [user1Id, user2Id] : [user2Id, user1Id];

    const query = `
      INSERT INTO conversations (user1_id, user2_id, created_at, updated_at)
      VALUES ($1, $2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      ON CONFLICT (user1_id, user2_id) DO UPDATE
      SET updated_at = CURRENT_TIMESTAMP
      RETURNING *;
    `;

    const result = await pool.query(query, [firstId, secondId]);
    return result.rows[0];
  }

  static async getConversationById(conversationId) {
    const query = 'SELECT * FROM conversations WHERE id = $1;';
    const result = await pool.query(query, [conversationId]);
    return result.rows[0];
  }

  static async getUserConversations(userId) {
    const query = `
      SELECT c.*, 
             CASE 
               WHEN c.user1_id = $1 THEN u.id
               ELSE u.id
             END AS other_user_id,
             CASE 
               WHEN c.user1_id = $1 THEN u.nickname
               ELSE u.nickname
             END AS other_user_nickname,
             CASE 
               WHEN c.user1_id = $1 THEN u.profile_images
               ELSE u.profile_images
             END AS other_user_profile_images
      FROM conversations c
      JOIN users u ON (
        (c.user1_id = $1 AND c.user2_id = u.id) OR
        (c.user2_id = $1 AND c.user1_id = u.id)
      )
      WHERE c.is_active = true AND (c.user1_id = $1 OR c.user2_id = $1)
      ORDER BY c.updated_at DESC;
    `;

    const result = await pool.query(query, [userId]);
    return result.rows;
  }

  static async getConversationBetweenUsers(user1Id, user2Id) {
    const [firstId, secondId] = user1Id < user2Id ? [user1Id, user2Id] : [user2Id, user1Id];

    const query = `
      SELECT * FROM conversations 
      WHERE (user1_id = $1 AND user2_id = $2) OR (user1_id = $2 AND user2_id = $1)
      LIMIT 1;
    `;

    const result = await pool.query(query, [firstId, secondId]);
    return result.rows[0];
  }

  static async updateLastMessage(conversationId, message) {
    const query = `
      UPDATE conversations 
      SET last_message = $2, last_message_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP
      WHERE id = $1;
    `;

    await pool.query(query, [conversationId, message]);
  }
}

export default Conversation;
