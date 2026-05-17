// src/models/Request.js
import pool from '../config/database.js';

class Request {
  static async sendRequest(senderId, receiverId, message) {
    const query = `
      INSERT INTO requests (sender_id, receiver_id, message, status)
      VALUES ($1, $2, $3, 'pending')
      ON CONFLICT (sender_id, receiver_id) DO UPDATE
      SET message = EXCLUDED.message, status = 'pending', updated_at = CURRENT_TIMESTAMP
      RETURNING *;
    `;

    const result = await pool.query(query, [senderId, receiverId, message]);
    return result.rows[0];
  }

  static async acceptRequest(requestId) {
    const query = `
      UPDATE requests 
      SET status = 'accepted', updated_at = CURRENT_TIMESTAMP
      WHERE id = $1
      RETURNING *;
    `;

    const result = await pool.query(query, [requestId]);
    return result.rows[0];
  }

  static async rejectRequest(requestId) {
    const query = `
      UPDATE requests 
      SET status = 'rejected', updated_at = CURRENT_TIMESTAMP
      WHERE id = $1
      RETURNING *;
    `;

    const result = await pool.query(query, [requestId]);
    return result.rows[0];
  }

  static async getRequestsByReceiver(receiverId) {
    const query = `
      SELECT r.*, 
             u.nickname, u.age, u.gender, u.location, u.profession, u.profile_images
      FROM requests r
      JOIN users u ON r.sender_id = u.id
      WHERE r.receiver_id = $1 AND r.status = 'pending'
      ORDER BY r.created_at DESC;
    `;

    const result = await pool.query(query, [receiverId]);
    return result.rows;
  }

  static async getAcceptedRequests(userId) {
    const query = `
      SELECT r.*, 
             u.id AS user_id, u.nickname, u.age, u.gender, u.location, u.profession, u.profile_images
      FROM requests r
      JOIN users u ON CASE 
        WHEN r.sender_id = $1 THEN r.receiver_id = u.id
        WHEN r.receiver_id = $1 THEN r.sender_id = u.id
      END
      WHERE (r.sender_id = $1 OR r.receiver_id = $1) AND r.status = 'accepted'
      ORDER BY r.updated_at DESC;
    `;

    const result = await pool.query(query, [userId]);
    return result.rows;
  }

  static async getRequestById(requestId) {
    const query = 'SELECT * FROM requests WHERE id = $1;';
    const result = await pool.query(query, [requestId]);
    return result.rows[0];
  }

  static async checkRequestStatus(senderId, receiverId) {
    const query = `
      SELECT status FROM requests 
      WHERE (sender_id = $1 AND receiver_id = $2) 
         OR (sender_id = $2 AND receiver_id = $1)
      LIMIT 1;
    `;

    const result = await pool.query(query, [senderId, receiverId]);
    return result.rows[0];
  }
}

export default Request;
