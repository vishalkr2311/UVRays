// src/controllers/profileController.js
import User from '../models/User.js';
import { validateProfile, validateNickname } from '../utils/validation.js';
import { storage } from '../config/firebase.js';

export const createProfile = async (req, res) => {
  try {
    const userId = req.user.userId;
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
    } = req.body;

    // Validate profile data
    const validation = validateProfile({
      nickname,
      gender,
      age,
      location,
      skinColor,
      weight,
      profession,
      bio,
    });

    if (!validation.isValid) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: validation.errors,
      });
    }

    // Check if nickname is unique
    const existingUser = await User.findByNickname(nickname);
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'Nickname already taken',
      });
    }

    // Update or create profile
    const updatedUser = await User.updateProfile(userId, {
      nickname,
      gender,
      age: parseInt(age, 10),
      location,
      skinColor,
      weight: parseFloat(weight),
      profession,
      alcoholic: alcoholic === 'Yes',
      bio,
    });

    res.status(200).json({
      success: true,
      message: 'Profile created successfully',
      user: updatedUser,
    });
  } catch (error) {
    console.error('Create profile error:', error);
    res.status(500).json({ success: false, message: 'Failed to create profile' });
  }
};

export const updateProfile = async (req, res) => {
  try {
    const userId = req.user.userId;
    const updateData = req.body;

    // Validate if provided
    if (Object.keys(updateData).length > 0) {
      const validation = validateProfile(updateData);
      if (!validation.isValid && updateData.nickname) {
        return res.status(400).json({
          success: false,
          message: 'Validation failed',
          errors: validation.errors,
        });
      }
    }

    const updatedUser = await User.updateProfile(userId, updateData);

    res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      user: updatedUser,
    });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({ success: false, message: 'Failed to update profile' });
  }
};

export const getProfile = async (req, res) => {
  try {
    const userId = req.user.userId;
    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    res.status(200).json({
      success: true,
      user,
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ success: false, message: 'Failed to get profile' });
  }
};

export const getPublicProfile = async (req, res) => {
  try {
    const { userId } = req.params;
    const user = await User.findById(parseInt(userId, 10));

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    res.status(200).json({
      success: true,
      user: {
        id: user.id,
        nickname: user.nickname,
        age: user.age,
        gender: user.gender,
        location: user.location,
        profession: user.profession,
        bio: user.bio,
        profileImages: user.profile_images,
      },
    });
  } catch (error) {
    console.error('Get public profile error:', error);
    res.status(500).json({ success: false, message: 'Failed to get profile' });
  }
};

export const uploadProfileImages = async (req, res) => {
  try {
    const userId = req.user.userId;

    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No files uploaded',
      });
    }

    if (req.files.length > 3) {
      return res.status(400).json({
        success: false,
        message: 'Maximum 3 images allowed',
      });
    }

    const imageUrls = [];

    for (const file of req.files) {
      const bucket = storage.bucket();
      const blob = bucket.file(`profile-images/${userId}-${Date.now()}-${file.originalname}`);

      await blob.save(file.buffer, {
        metadata: {
          contentType: file.mimetype,
        },
      });

      const [url] = await blob.getSignedUrl({
        version: 'v4',
        action: 'read',
        expires: Date.now() + 365 * 24 * 60 * 60 * 1000,
      });

      imageUrls.push(url);
    }

    const user = await User.updateProfile(userId, {
      profileImages: imageUrls,
    });

    res.status(200).json({
      success: true,
      message: 'Images uploaded successfully',
      profileImages: imageUrls,
      user,
    });
  } catch (error) {
    console.error('Upload images error:', error);
    res.status(500).json({ success: false, message: 'Failed to upload images' });
  }
};
