class Comment {
  final int? id; // Make nullable
  final String content;
  final int? postId; // Make nullable
  final int? userId; // Make nullable
  final String userEmail;
  final String createdAt;
  final String? updatedAt;
  final bool destroyed;

  Comment({
    this.id, // Optional
    required this.content,
    this.postId, // Optional
    this.userId, // Optional
    required this.userEmail,
    required this.createdAt,
    this.updatedAt,
    this.destroyed = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'] ?? '',
      postId: json['postId'],
      userId: json['userId'],
      userEmail: json['userEmail'] ?? '',
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'],
      destroyed: json['destroyed'] ?? false,
    );
  }
}