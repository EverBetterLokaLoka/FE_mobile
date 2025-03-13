class Friend {
  final int id;          // This is the follower/friendship record ID in some responses
  final int userId;      // This is the actual user ID
  final String username;
  final String email;
  final String? avatar;
  final String? relationshipType;

  Friend({
    required this.id,
    required this.userId,
    required this.username,
    required this.email,
    this.avatar,
    this.relationshipType,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'],
      userId: json['userId'] ?? 0,
      username: json['username'],
      email: json['email'],
      avatar: json['avatar'],
      relationshipType: json['relationshipType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'email': email,
      'avatar': avatar,
      'relationshipType': relationshipType,
    };
  }
}

