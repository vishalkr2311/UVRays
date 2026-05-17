// lib/models/message_model.dart

class Message {
  final int id;
  final int conversationId;
  final int senderId;
  final String message;
  final String? senderNickname;
  final List<String>? senderProfileImages;
  final bool isRead;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.message,
    this.senderNickname,
    this.senderProfileImages,
    this.isRead = false,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      conversationId: json['conversation_id'],
      senderId: json['sender_id'],
      message: json['message'],
      senderNickname: json['nickname'],
      senderProfileImages: List<String>.from(json['profile_images'] ?? []),
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'message': message,
      'nickname': senderNickname,
      'profile_images': senderProfileImages,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Conversation {
  final int id;
  final int user1Id;
  final int user2Id;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // For UI display
  final int? otherUserId;
  final String? otherUserNickname;
  final List<String>? otherUserProfileImages;

  Conversation({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    this.lastMessage,
    this.lastMessageAt,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.otherUserId,
    this.otherUserNickname,
    this.otherUserProfileImages,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      user1Id: json['user1_id'],
      user2Id: json['user2_id'],
      lastMessage: json['last_message'],
      lastMessageAt: json['last_message_at'] != null 
        ? DateTime.parse(json['last_message_at']) 
        : null,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at']) 
        : null,
      otherUserId: json['other_user_id'],
      otherUserNickname: json['other_user_nickname'],
      otherUserProfileImages: List<String>.from(json['other_user_profile_images'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user1_id': user1Id,
      'user2_id': user2Id,
      'last_message': lastMessage,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
