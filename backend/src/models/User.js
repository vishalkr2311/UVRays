// src/models/User.js
import pool from '../config/database.js';

class User {
  static async create(userData) {
    const {
      googleId,
      email,
      nickname,
      gender,
      age,
      location,
      skinColor,
      weight,
      profession,
      alcoholic,
      bio,
      profileImages,
    } = userData;

    const query = `
      INSERT INTO users (
        google_id, email, nickname, gender, age, location, 
        skin_color, weight, profession, alcoholic, bio, profile_images, is_complete
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
      RETURNING *;
    `;

    const timestamp = Date.now();
    const nicknameValue = nickname || `user${timestamp % 10000}`;
    const values = [
      googleId || null,
      email,
      nicknameValue,
      gender,
      age,
      location,
      skinColor,
      weight,
      profession,
      alcoholic,
      bio,
      profileImages || [],
      true,
    ];

    const result = await pool.query(query, values);
    return result.rows[0];
  }

  static async createWithEmail(email) {
    const timestamp = Date.now();
    const baseNickname = email.split('@')[0].replace(/[^a-zA-Z0-9]/g, '');
    const nickname = `${baseNickname.substring(0, 6)}${timestamp % 10000}`;

    const query = `
      INSERT INTO users (
        google_id, email, password_hash, role, nickname, is_complete, is_active
      ) VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *;
    `;
    const values = [null, email, null, 'user', nickname, false, true];
    const result = await pool.query(query, values);
    return result.rows[0];
  }

  static async createAdmin(email, passwordHash) {
    const timestamp = Date.now();
    const nickname = `admin${timestamp % 10000}`;
    const query = `
      INSERT INTO users (
        google_id, email, password_hash, role, nickname, is_complete, is_active
      ) VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *;
    `;
    const values = [null, email, passwordHash, 'admin', nickname, true, true];
    const result = await pool.query(query, values);
    return result.rows[0];
  }

  static async setOtpForEmail(email, otpCode, expiresAt) {
    const query = `
      UPDATE users
      SET otp_code = $1, otp_expires_at = $2
      WHERE email = $3
      RETURNING *;
    `;
    const result = await pool.query(query, [otpCode, expiresAt, email]);
    return result.rows[0];
  }

  static async verifyOtp(email, otpCode) {
    const query = `
      SELECT * FROM users
      WHERE email = $1 AND otp_code = $2 AND otp_expires_at >= CURRENT_TIMESTAMP
      LIMIT 1;
    `;
    const result = await pool.query(query, [email, otpCode]);
    return result.rows[0];
  }

  static async setPassword(userId, passwordHash) {
    const query = `
      UPDATE users
      SET password_hash = $1
      WHERE id = $2
      RETURNING *;
    `;
    const result = await pool.query(query, [passwordHash, userId]);
    return result.rows[0];
  }

  static async updateRole(userId, role) {
    const query = `
      UPDATE users
      SET role = $1
      WHERE id = $2
      RETURNING *;
    `;
    const result = await pool.query(query, [role, userId]);
    return result.rows[0];
  }

  static async deactivateUser(userId) {
    const query = `
      UPDATE users
      SET is_active = false
      WHERE id = $1
      RETURNING *;
    `;
    const result = await pool.query(query, [userId]);
    return result.rows[0];
  }

  static async findByGoogleId(googleId) {
    const query = 'SELECT * FROM users WHERE google_id = $1;';
    const result = await pool.query(query, [googleId]);
    return result.rows[0];
  }

  static async findByEmail(email) {
    const query = 'SELECT * FROM users WHERE email = $1;';
    const result = await pool.query(query, [email]);
    return result.rows[0];
  }

  static async findById(id) {
    const query = 'SELECT * FROM users WHERE id = $1;';
    const result = await pool.query(query, [id]);
    return result.rows[0];
  }

  static async findByNickname(nickname) {
    const query = 'SELECT * FROM users WHERE nickname = $1;';
    const result = await pool.query(query, [nickname]);
    return result.rows[0];
  }

  static async updateProfile(userId, userData) {
    const {
      nickname,
      gender,
      age,
      location,
      skinColor,
      weight,
      profession,
      alcoholic,
      bio,
      profileImages,
    } = userData;

    const query = `
      UPDATE users SET 
        nickname = COALESCE($2, nickname),
        gender = COALESCE($3, gender),
        age = COALESCE($4, age),
        location = COALESCE($5, location),
        skin_color = COALESCE($6, skin_color),
        weight = COALESCE($7, weight),
        profession = COALESCE($8, profession),
        alcoholic = COALESCE($9, alcoholic),
        bio = COALESCE($10, bio),
        profile_images = COALESCE($11, profile_images)
      WHERE id = $1
      RETURNING *;
    `;

    const values = [
      userId,
      nickname,
      gender,
      age,
      location,
      skinColor,
      weight,
      profession,
      alcoholic,
      bio,
      profileImages,
    ];

    const result = await pool.query(query, values);
    return result.rows[0];
  }

  static async searchUsers(filters) {
    let query = 'SELECT * FROM users WHERE is_active = true AND is_complete = true';
    const values = [];
    let paramCount = 1;

    if (filters.location) {
      query += ` AND location ILIKE $${paramCount}`;
      values.push(`%${filters.location}%`);
      paramCount++;
    }

    if (filters.gender) {
      query += ` AND gender = $${paramCount}`;
      values.push(filters.gender);
      paramCount++;
    }

    if (filters.minAge) {
      query += ` AND age >= $${paramCount}`;
      values.push(filters.minAge);
      paramCount++;
    }

    if (filters.maxAge) {
      query += ` AND age <= $${paramCount}`;
      values.push(filters.maxAge);
      paramCount++;
    }

    query += ' ORDER BY last_seen DESC LIMIT 50;';

    const result = await pool.query(query, values);
    return result.rows;
  }

  static async updateLastSeen(userId) {
    const query = 'UPDATE users SET last_seen = CURRENT_TIMESTAMP WHERE id = $1;';
    await pool.query(query, [userId]);
  }

  static async getAllUsers() {
    const query = 'SELECT id, nickname, age, gender, location, profession, profile_images FROM users WHERE is_active = true AND is_complete = true;';
    const result = await pool.query(query);
    return result.rows;
  }
}

export default User;
