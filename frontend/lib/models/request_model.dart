// lib/models/request_model.dart

class ConnectionRequest {
  final int id;
  final int senderId;
  final int receiverId;
  final String? message;
  final String status; // pending, accepted, rejected
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // For UI display
  final String? senderNickname;
  final int? senderAge;
  final String? senderGender;
  final String? senderLocation;
  final String? senderProfession;
  final List<String>? senderProfileImages;
  final int? userId; // Used when listing sender's info

  ConnectionRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.message,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.senderNickname,
    this.senderAge,
    this.senderGender,
    this.senderLocation,
    this.senderProfession,
    this.senderProfileImages,
    this.userId,
  });

  factory ConnectionRequest.fromJson(Map<String, dynamic> json) {
    return ConnectionRequest(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      message: json['message'],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at']) 
        : null,
      senderNickname: json['nickname'],
      senderAge: json['age'],
      senderGender: json['gender'],
      senderLocation: json['location'],
      senderProfession: json['profession'],
      senderProfileImages: List<String>.from(json['profile_images'] ?? []),
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
