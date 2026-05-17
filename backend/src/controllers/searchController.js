// src/controllers/searchController.js
import User from '../models/User.js';
import Request from '../models/Request.js';

export const searchUsers = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { location, gender, minAge, maxAge } = req.query;

    const filters = {};
    if (location) filters.location = location;
    if (gender) filters.gender = gender;
    if (minAge) filters.minAge = parseInt(minAge, 10);
    if (maxAge) filters.maxAge = parseInt(maxAge, 10);

    const users = await User.searchUsers(filters);

    // Filter out current user and add request status
    const filteredUsers = [];
    for (const user of users) {
      if (user.id !== userId) {
        const requestStatus = await Request.checkRequestStatus(userId, user.id);
        filteredUsers.push({
          ...user,
          requestStatus: requestStatus?.status || 'none',
        });
      }
    }

    res.status(200).json({
      success: true,
      users: filteredUsers,
    });
  } catch (error) {
    console.error('Search users error:', error);
    res.status(500).json({ success: false, message: 'Failed to search users' });
  }
};

export const getAllUsers = async (req, res) => {
  try {
    const userId = req.user.userId;

    const users = await User.getAllUsers();

    // Filter out current user and add request status
    const filteredUsers = [];
    for (const user of users) {
      if (user.id !== userId) {
        const requestStatus = await Request.checkRequestStatus(userId, user.id);
        filteredUsers.push({
          ...user,
          requestStatus: requestStatus?.status || 'none',
        });
      }
    }

    res.status(200).json({
      success: true,
      users: filteredUsers,
    });
  } catch (error) {
    console.error('Get all users error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch users' });
  }
};
