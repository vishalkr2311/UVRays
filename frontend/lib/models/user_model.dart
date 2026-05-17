// lib/models/user_model.dart

class User {
  final int id;
  final String email;
  final String? nickname;
  final String? gender;
  final int? age;
  final String? location;
  final String? skinColor;
  final double? weight;
  final String? profession;
  final bool? alcoholic;
  final String? bio;
  final List<String>? profileImages;
  final bool isProfileComplete;
  final bool isActive;
  final DateTime? lastSeen;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    this.nickname,
    this.gender,
    this.age,
    this.location,
    this.skinColor,
    this.weight,
    this.profession,
    this.alcoholic,
    this.bio,
    this.profileImages,
    this.isProfileComplete = false,
    this.isActive = true,
    this.lastSeen,
    required this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      nickname: json['nickname'],
      gender: json['gender'],
      age: json['age'],
      location: json['location'],
      skinColor: json['skin_color'] ?? json['skinColor'],
      weight: json['weight']?.toDouble(),
      profession: json['profession'],
      alcoholic: json['alcoholic'],
      bio: json['bio'],
      profileImages: List<String>.from(json['profile_images'] ?? json['profileImages'] ?? []),
      isProfileComplete: json['is_complete'] ?? json['isProfileComplete'] ?? false,
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      lastSeen: json['last_seen'] != null ? DateTime.parse(json['last_seen']) : null,
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
      'gender': gender,
      'age': age,
      'location': location,
      'skin_color': skinColor,
      'weight': weight,
      'profession': profession,
      'alcoholic': alcoholic,
      'bio': bio,
      'profile_images': profileImages,
      'is_complete': isProfileComplete,
      'is_active': isActive,
      'last_seen': lastSeen?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? nickname,
    String? gender,
    int? age,
    String? location,
    String? skinColor,
    double? weight,
    String? profession,
    bool? alcoholic,
    String? bio,
    List<String>? profileImages,
    bool? isProfileComplete,
    bool? isActive,
    DateTime? lastSeen,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      location: location ?? this.location,
      skinColor: skinColor ?? this.skinColor,
      weight: weight ?? this.weight,
      profession: profession ?? this.profession,
      alcoholic: alcoholic ?? this.alcoholic,
      bio: bio ?? this.bio,
      profileImages: profileImages ?? this.profileImages,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      isActive: isActive ?? this.isActive,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
