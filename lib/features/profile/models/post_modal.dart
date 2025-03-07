class Post {
  final int id;
  final String title;
  final String content;
  final int userId;
  final String userEmail;
  final String createdAt;
  final String? updatedAt;
  final List<Comment> comments;
  final List<Like> likes;
  final List<PostImage> images;
  final int likeCount;
  final int commentCount;
  final bool destroyed;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.userEmail,
    required this.createdAt,
    this.updatedAt,
    required this.comments,
    required this.likes,
    required this.images,
    required this.likeCount,
    required this.commentCount,
    required this.destroyed,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      userId: json['user_id'],
      userEmail: json['userEmail'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      comments: (json['comments'] as List)
          .map((comment) => Comment.fromJson(comment))
          .toList(),
      likes: (json['likes'] as List)
          .map((like) => Like.fromJson(like))
          .toList(),
      images: (json['images'] as List)
          .map((image) => PostImage.fromJson(image))
          .toList(),
      likeCount: json['likeCount'],
      commentCount: json['commentCount'],
      destroyed: json['destroyed'] ?? false,
    );
  }
}

class Comment {
  final int id;
  final String content;
  final int postId;
  final int userId;
  final String userEmail;
  final String createdAt;
  final String? updatedAt;
  final bool destroyed;

  Comment({
    required this.id,
    required this.content,
    required this.postId,
    required this.userId,
    required this.userEmail,
    required this.createdAt,
    this.updatedAt,
    required this.destroyed,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      postId: json['postId'],
      userId: json['userId'],
      userEmail: json['userEmail'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      destroyed: json['destroyed'] ?? false,
    );
  }
}

class Like {
  final int id;
  final int postId;
  final int userId;
  final String userEmail;
  final String createdAt;

  Like({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userEmail,
    required this.createdAt,
  });

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      id: json['id'],
      postId: json['postId'],
      userId: json['userId'],
      userEmail: json['userEmail'],
      createdAt: json['createdAt'],
    );
  }
}

class PostImage {
  final int id;
  final String content;
  final String? shares;
  final int? locationId;
  final int userId;
  final int postId;
  final int? mapId;
  final int? activityId;
  final String userEmail;
  final String type;
  final String? createdAt;
  final String? updatedAt;

  PostImage({
    required this.id,
    required this.content,
    this.shares,
    this.locationId,
    required this.userId,
    required this.postId,
    this.mapId,
    this.activityId,
    required this.userEmail,
    required this.type,
    this.createdAt,
    this.updatedAt,
  });

  factory PostImage.fromJson(Map<String, dynamic> json) {
    return PostImage(
      id: json['id'],
      content: json['content'],
      shares: json['shares'],
      locationId: json['locationId'],
      userId: json['userId'],
      postId: json['postId'],
      mapId: json['mapId'],
      activityId: json['activityId'],
      userEmail: json['userEmail'],
      type: json['type'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

