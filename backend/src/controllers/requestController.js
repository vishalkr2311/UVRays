// src/controllers/requestController.js
import Request from '../models/Request.js';
import Conversation from '../models/Conversation.js';

export const sendRequest = async (req, res) => {
  try {
    const senderId = req.user.userId;
    const { receiverId, message } = req.body;

    if (!receiverId) {
      return res.status(400).json({
        success: false,
        message: 'Receiver ID is required',
      });
    }

    // Check if request is already pending/accepted
    const existingRequest = await Request.checkRequestStatus(senderId, receiverId);
    if (existingRequest && existingRequest.status !== 'rejected') {
      return res.status(400).json({
        success: false,
        message: `Request already ${existingRequest.status}`,
      });
    }

    const newRequest = await Request.sendRequest(
      senderId,
      receiverId,
      message || null
    );

    res.status(201).json({
      success: true,
      message: 'Request sent successfully',
      request: newRequest,
    });
  } catch (error) {
    console.error('Send request error:', error);
    res.status(500).json({ success: false, message: 'Failed to send request' });
  }
};

export const acceptRequest = async (req, res) => {
  try {
    const { requestId } = req.body;
    const userId = req.user.userId;

    if (!requestId) {
      return res.status(400).json({
        success: false,
        message: 'Request ID is required',
      });
    }

    const request = await Request.getRequestById(requestId);
    if (!request) {
      return res.status(404).json({
        success: false,
        message: 'Request not found',
      });
    }

    if (request.receiver_id !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized',
      });
    }

    const acceptedRequest = await Request.acceptRequest(requestId);

    // Create or get conversation
    const conversation = await Conversation.createOrGet(
      request.sender_id,
      request.receiver_id
    );

    res.status(200).json({
      success: true,
      message: 'Request accepted',
      request: acceptedRequest,
      conversation,
    });
  } catch (error) {
    console.error('Accept request error:', error);
    res.status(500).json({ success: false, message: 'Failed to accept request' });
  }
};

export const rejectRequest = async (req, res) => {
  try {
    const { requestId } = req.body;
    const userId = req.user.userId;

    if (!requestId) {
      return res.status(400).json({
        success: false,
        message: 'Request ID is required',
      });
    }

    const request = await Request.getRequestById(requestId);
    if (!request) {
      return res.status(404).json({
        success: false,
        message: 'Request not found',
      });
    }

    if (request.receiver_id !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized',
      });
    }

    const rejectedRequest = await Request.rejectRequest(requestId);

    res.status(200).json({
      success: true,
      message: 'Request rejected',
      request: rejectedRequest,
    });
  } catch (error) {
    console.error('Reject request error:', error);
    res.status(500).json({ success: false, message: 'Failed to reject request' });
  }
};

export const getIncomingRequests = async (req, res) => {
  try {
    const userId = req.user.userId;

    const requests = await Request.getRequestsByReceiver(userId);

    res.status(200).json({
      success: true,
      requests,
    });
  } catch (error) {
    console.error('Get incoming requests error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch requests',
    });
  }
};

export const getAcceptedConnections = async (req, res) => {
  try {
    const userId = req.user.userId;

    const connections = await Request.getAcceptedRequests(userId);

    res.status(200).json({
      success: true,
      connections,
    });
  } catch (error) {
    console.error('Get accepted connections error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch connections',
    });
  }
};
