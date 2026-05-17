// src/middleware/auth.js
import { verifyToken } from '../utils/jwt.js';

export const authenticateToken = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
      return res.status(401).json({ message: 'Access token required' });
    }

    const decoded = verifyToken(token);
    if (!decoded) {
      return res.status(403).json({ message: 'Invalid or expired token' });
    }

    req.user = decoded;
    next();
  } catch (error) {
    return res.status(500).json({ message: 'Authentication error' });
  }
};

export const authenticateAdmin = (req, res, next) => {
  authenticateToken(req, res, () => {
    if (!req.user || req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Admin access required' });
    }
    next();
  });
};

export const optionalAuth = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    const token = authHeader && authHeader.split(' ')[1];

    if (token) {
      const decoded = verifyToken(token);
      if (decoded) {
        req.user = decoded;
      }
    }
    next();
  } catch (error) {
    next();
  }
};
