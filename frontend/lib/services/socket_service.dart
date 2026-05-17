// lib/services/socket_service.dart

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late IO.Socket _socket;

  factory SocketService() {
    return _instance;
  }

  SocketService._internal();

  void initialize(String serverUrl) {
    _socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .build(),
    );

    _setupListeners();
  }

  void _setupListeners() {
    _socket.on('connect', (_) {
      if (kDebugMode) print('Socket connected');
    });

    _socket.on('disconnect', (_) {
      if (kDebugMode) print('Socket disconnected');
    });

    _socket.on('error', (error) {
      if (kDebugMode) print('Socket error: $error');
    });
  }

  void connect() {
    if (!_socket.connected) {
      _socket.connect();
    }
  }

  void disconnect() {
    if (_socket.connected) {
      _socket.disconnect();
    }
  }

  // User Management
  void joinUser(int userId) {
    _socket.emit('user:join', userId);
  }

  void onUserOnline(Function(dynamic data) callback) {
    _socket.on('user:online', callback);
  }

  void onUserOffline(Function(dynamic data) callback) {
    _socket.on('user:offline', callback);
  }

  // Conversation Management
  void joinConversation(int conversationId, int userId) {
    _socket.emit('conversation:join', {
      'conversationId': conversationId,
      'userId': userId,
    });
  }

  void leaveConversation(int conversationId) {
    _socket.emit('conversation:leave', {'conversationId': conversationId});
  }

  void onConversationJoined(Function(dynamic data) callback) {
    _socket.on('conversation:joined', callback);
  }

  // Messaging
  void sendMessage({
    required int conversationId,
    required int senderId,
    required String message,
  }) {
    _socket.emit('message:send', {
      'conversationId': conversationId,
      'senderId': senderId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void onMessageReceived(Function(dynamic data) callback) {
    _socket.on('message:received', callback);
  }

  void onMessageError(Function(dynamic data) callback) {
    _socket.on('message:error', callback);
  }

  // Typing Indicators
  void startTyping(int conversationId, int userId, String nickname) {
    _socket.emit('typing:start', {
      'conversationId': conversationId,
      'userId': userId,
      'nickname': nickname,
    });
  }

  void stopTyping(int conversationId) {
    _socket.emit('typing:stop', {'conversationId': conversationId});
  }

  void onUserTyping(Function(dynamic data) callback) {
    _socket.on('user:typing', callback);
  }

  void onUserStopTyping(Function(dynamic data) callback) {
    _socket.on('user:typing:stop', callback);
  }

  // Read Status
  void markMessagesAsRead(int conversationId, int userId) {
    _socket.emit('message:read', {
      'conversationId': conversationId,
      'userId': userId,
    });
  }

  void onMessagesMarkedRead(Function(dynamic data) callback) {
    _socket.on('messages:marked_read', callback);
  }

  // Health Check
  void sendPing() {
    _socket.emit('ping');
  }

  void onPong(Function(dynamic data) callback) {
    _socket.on('pong', callback);
  }

  // Getters
  IO.Socket get socket => _socket;
  bool get isConnected => _socket.connected;

  // Cleanup
  void dispose() {
    _socket.dispose();
  }
}
