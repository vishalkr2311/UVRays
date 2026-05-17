// lib/providers/chat_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

class ChatState {
  final bool isLoading;
  final List<Message> messages;
  final int? currentConversationId;
  final bool isTyping;
  final String? error;

  ChatState({
    this.isLoading = false,
    this.messages = const [],
    this.currentConversationId,
    this.isTyping = false,
    this.error,
  });

  ChatState copyWith({
    bool? isLoading,
    List<Message>? messages,
    int? currentConversationId,
    bool? isTyping,
    String? error,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
      currentConversationId: currentConversationId ?? this.currentConversationId,
      isTyping: isTyping ?? this.isTyping,
      error: error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();

  ChatNotifier() : super(ChatState());

  Future<void> loadMessages(int conversationId) async {
    state = state.copyWith(isLoading: true, error: null, currentConversationId: conversationId);

    try {
      final response = await _apiService.getMessages(conversationId);

      if (response.statusCode == 200) {
        final messages = (response.data['messages'] as List)
            .map((m) => Message.fromJson(m))
            .toList();
        state = state.copyWith(isLoading: false, messages: messages);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load messages: ${e.toString()}',
      );
      print('Load Messages Error: $e');
    }
  }

  Future<void> sendMessage(int conversationId, String message, int userId) async {
    try {
      _socketService.sendMessage(
        conversationId: conversationId,
        senderId: userId,
        message: message,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to send message: ${e.toString()}');
      print('Send Message Error: $e');
    }
  }

  void addMessage(Message message) {
    final updatedMessages = [...state.messages, message];
    state = state.copyWith(messages: updatedMessages);
  }

  void setTyping(bool isTyping) {
    state = state.copyWith(isTyping: isTyping);
  }

  void clearChat() {
    state = ChatState();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>(
  (ref) => ChatNotifier(),
);
