import bcrypt from 'bcryptjs';
import User from '../models/User.js';
import { getActiveUsers, emitAdminNotification } from '../socket/socketHandler.js';

export const getAdminDashboard = async (req, res) => {
  try {
    const users = await User.getAllUsers();
    const activeUsers = getActiveUsers();

    res.status(200).json({
      success: true,
      data: {
        totalUsers: users.length,
        activeUsers: activeUsers.size,
        users,
      },
    });
  } catch (error) {
    console.error('Admin dashboard error:', error);
    res.status(500).json({ success: false, message: 'Unable to load dashboard' });
  }
};

export const getAllUsers = async (req, res) => {
  try {
    const users = await User.getAllUsers();
    res.status(200).json({ success: true, users });
  } catch (error) {
    console.error('Get all users error:', error);
    res.status(500).json({ success: false, message: 'Unable to load users' });
  }
};

export const broadcastNotification = async (req, res) => {
  try {
    const { message } = req.body;
    if (!message) {
      return res.status(400).json({ success: false, message: 'Message is required' });
    }

    emitAdminNotification({ message, timestamp: new Date().toISOString() });

    res.status(200).json({ success: true, message: 'Broadcast sent' });
  } catch (error) {
    console.error('Broadcast notification error:', error);
    res.status(500).json({ success: false, message: 'Unable to send broadcast' });
  }
};

export const deleteUser = async (req, res) => {
  try {
    const userId = parseInt(req.params.id, 10);
    if (!userId) {
      return res.status(400).json({ success: false, message: 'User ID is required' });
    }

    const updatedUser = await User.deactivateUser(userId);
    res.status(200).json({ success: true, user: updatedUser });
  } catch (error) {
    console.error('Delete user error:', error);
    res.status(500).json({ success: false, message: 'Unable to delete user' });
  }
};

export const setUserPassword = async (req, res) => {
  try {
    const userId = parseInt(req.params.id, 10);
    const { password } = req.body;

    if (!userId || !password) {
      return res.status(400).json({ success: false, message: 'User ID and password are required' });
    }

    const passwordHash = bcrypt.hashSync(password, 10);
    const updatedUser = await User.setPassword(userId, passwordHash);

    res.status(200).json({ success: true, user: updatedUser });
  } catch (error) {
    console.error('Set user password error:', error);
    res.status(500).json({ success: false, message: 'Unable to update password' });
  }
};
