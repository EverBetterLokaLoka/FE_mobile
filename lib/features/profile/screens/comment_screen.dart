import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  bool _isLoading = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.post.comments); // Create a copy of the comments list

    // Debug: Print all comments to check content
    for (var comment in _comments) {
      print('Comment ID: ${comment.id}, Content: ${comment.content}, User: ${comment.userEmail}');
    }
  }

  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      final newComment = await _profileService.addComment(
        widget.post.id,
        content,
      );

      // Debug: Print the new comment
      print('New Comment: ID: ${newComment.id}, Content: ${newComment.content}, User: ${newComment.userEmail}');

      setState(() {
        _comments.add(newComment);
        _commentController.clear();
      });

      // Notify parent widget about the new comment
      widget.onCommentAdded(newComment);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comment added successfully')),
      );

    } catch (e) {
      print('Error adding comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment. Please try again.')),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
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

  Widget _buildPostSummary() {
    // Get the first letter of email or use a default
    final String avatarText = widget.post.userEmail.isNotEmpty
        ? widget.post.userEmail[0].toUpperCase()
        : '?';

    final String username = widget.post.userName;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(widget.post.avatar),
            backgroundColor: Colors.blue,
          ),

          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
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
      commentDate = DateTime.now(); // Fallback if date parsing fails
    }

    final String formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(commentDate);

    // Get the first letter of email or use a default
    final String avatarText = comment.userEmail.isNotEmpty
        ? comment.userEmail[0].toUpperCase()
        : '?';



    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(comment.avatar),
            backgroundColor: Colors.blue,
          ),

          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                // Make sure the comment content is clearly visible
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
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}