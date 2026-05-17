// src/utils/jwt.js
import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';

dotenv.config();

export const generateToken = (userId, email, role = 'user') => {
  return jwt.sign(
    { userId, email, role },
    process.env.JWT_SECRET || 'your_secret_key',
    { expiresIn: process.env.JWT_EXPIRE || '7d' }
  );
};

export const verifyToken = (token) => {
  try {
    return jwt.verify(token, process.env.JWT_SECRET || 'your_secret_key');
  } catch (error) {
    return null;
  }
};

export const decodeToken = (token) => {
  return jwt.decode(token);
};
