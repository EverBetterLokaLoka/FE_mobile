import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lokaloka/features/auth/models/user.dart';
import 'package:lokaloka/features/profile/models/post_modal.dart';
import 'package:lokaloka/features/profile/services/profile_services.dart';

class CommentScreen extends StatefulWidget {
  final Post post;
  final Function(Comment) onCommentAdded;

  const CommentScreen({
    Key? key,
    required this.post,
    required this.onCommentAdded,
  }) : super(key: key);

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ProfileService _profileService = ProfileService();
  late List<Comment> _comments;
  bool _isSending = false;
  int currentUserId = 0; // Thêm để lưu ID người dùng hiện tại

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.post.comments); // Tạo bản sao của danh sách bình luận
    _getCurrentUserProfile(); // Lấy thông tin người dùng hiện tại
  }

  Future<void> _getCurrentUserProfile() async {
    UserNormal? userProfile = await _profileService.getUserProfile();
    setState(() {
      currentUserId = userProfile?.id ?? 0; // Lưu ID người dùng hiện tại
    });
  }

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      UserNormal? userProfile = await _profileService.getUserProfile();
      final int userId = userProfile?.id ?? 0;
      final String userEmail = userProfile?.email ?? 'user@example.com';
      final String userName = userProfile?.full_name ?? 'Unknown User';
      final String avatar = userProfile?.avatar ?? '';

      Comment newComment = await _profileService.addComment(widget.post.id, _commentController.text);

      // Tạo một đối tượng Comment mới với thông tin người dùng
      newComment = Comment(
        id: newComment.id,
        content: newComment.content,
        postId: widget.post.id,
        userId: userId,
        userEmail: userEmail,
        userName: userName,
        createdAt: DateTime.now().toIso8601String(),
        avatar: avatar,
        destroyed: null,
      );

      setState(() {
        _comments.add(newComment);
        _commentController.clear();
        _isSending = false;
      });

      widget.onCommentAdded(newComment);
    } catch (error) {
      print('Error adding comment: $error');
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _editComment(Comment comment) async {
    _commentController.text = comment.content; // Đặt văn bản bình luận trong bộ điều khiển để chỉnh sửa
    final bool? shouldUpdate = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Comment'),
          content: TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: 'Edit your comment...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );

    if (shouldUpdate == true) {
      try {
        // Cập nhật bình luận
        UserNormal? userProfile = await _profileService.getUserProfile();
        final String userName = userProfile?.full_name ?? 'Unknown User';
        final String avatar = userProfile?.avatar ?? '';
        print("post id" + widget.post.id.toString());
        print("comment id" + comment.id.toString());
        // Cập nhật comment
        Comment updatedComment = await _profileService.updateComment(widget.post.id, comment.id, _commentController.text);

        setState(() {
          int index = _comments.indexWhere((c) => c.id == comment.id);
          if (index != -1) {
            _comments[index] = Comment(
              id: updatedComment.id,
              content: updatedComment.content,
              postId: widget.post.id,
              userId: userProfile?.id ?? 0,
              userEmail: userProfile?.email ?? '',
              userName: userName,
              createdAt: DateTime.now().toIso8601String(),
              avatar: avatar,
              destroyed: null,
            );
          }
        });
        _commentController.clear(); // Xóa dữ liệu đầu vào sau khi lưu
        widget.onCommentAdded(updatedComment);
      } catch (error) {
        print('Error updating comment: $error');
      }
    }
  }

  Future<void> _deleteComment(int commentId) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Comment'),
          content: Text('Are you sure you want to delete this comment?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Đóng dialog và trả về true
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Đóng dialog và trả về false
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        await _profileService.deleteComment(commentId); // Xóa comment
        setState(() {
          _comments.removeWhere((c) => c.id == commentId); // Cập nhật danh sách bình luận
        });
      } catch (error) {
        print('Error deleting comment: $error');
      }
    }

  if (shouldDelete == true) {
  try {
  await _profileService.deleteComment(commentId);
  setState(() {
  _comments.removeWhere((c) => c.id == commentId);
  });
  } catch (error) {
  print('Error deleting comment: $error');
  }
  }
}

Widget _buildPostSummary() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(widget.post.avatar.isNotEmpty ? widget.post.avatar : 'https://example.com/default_avatar.png'),
          backgroundColor: Colors.blue,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.post.userName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildCommentItem(Comment comment) {
  DateTime commentDate;
  try {
    commentDate = DateTime.parse(comment.createdAt);
  } catch (e) {
    commentDate = DateTime.now();
  }

  final String formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(commentDate);

  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(comment.avatar.isNotEmpty ? comment.avatar : 'https://example.com/default_avatar.png'),
          backgroundColor: Colors.blue,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    comment.userName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (currentUserId == comment.userId) // Kiểm tra xem người dùng hiện tại có phải là tác giả của bình luận không
                    IconButton(
                      icon: Icon(Icons.more_vert, size: 20),
                      onPressed: () => _showCommentMenu(comment),
                    ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                formattedDate,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  comment.content,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

void _showCommentMenu(Comment comment) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit'),
            onTap: () {
              Navigator.pop(context);
              _editComment(comment);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Delete'),
            onTap: () {
              Navigator.pop(context);
              _deleteComment(comment.id);
            },
          ),
        ],
      );
    },
  );
}

@override
void dispose() {
  _commentController.dispose();
  super.dispose();
}

Widget _buildCommentInput() {
  return Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          offset: Offset(0, -1),
          blurRadius: 4,
        ),
      ],
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.person, size: 16, color: Colors.grey[700]),
        ),
        SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: 'Add a comment...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            maxLines: null,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _addComment(),
          ),
        ),
        SizedBox(width: 8),
        _isSending
            ? SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : IconButton(
          icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
          onPressed: _addComment,
        ),
      ],
    ),
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Comments (${_comments.length})'),
      elevation: 1,
    ),
    body: Column(
      children: [
        _buildPostSummary(),
        Divider(height: 1),
        Expanded(
          child: _comments.isEmpty
              ? Center(child: Text('No comments yet. Be the first to comment!'))
              : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _comments.length,
            itemBuilder: (context, index) {
              return _buildCommentItem(_comments[index]);
            },
          ),
        ),
        _buildCommentInput(),
      ],
    ),
  );
}
}