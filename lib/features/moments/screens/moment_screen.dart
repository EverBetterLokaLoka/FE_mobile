import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lokaloka/core/constants/url_constant.dart';
import 'package:lokaloka/features/auth/models/user.dart';
import 'package:lokaloka/features/auth/services/auth_services.dart';
import 'package:lokaloka/features/moments/screens/create_moment_screen.dart';
import 'package:lokaloka/features/profile/models/post_modal.dart';
import 'package:lokaloka/features/profile/services/profile_services.dart';
import 'package:lokaloka/features/profile/screens/comment_screen.dart';

class MomentsScreen extends StatefulWidget {
  @override
  _MomentsScreenState createState() => _MomentsScreenState();
}

class _MomentsScreenState extends State<MomentsScreen> {
  final ProfileService _profileService = ProfileService();
  List<Post> _posts = [];
  bool _isRefreshing = false;
  UserNormal? _currentUser;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserAndPosts();
  }

  Future<void> _loadUserAndPosts() async {
    setState(() {
      _isRefreshing = true;
      _isLoadingUser = true;
    });

    try {
      _currentUser = await _profileService.getUserProfile();
      setState(() => _isLoadingUser = false);
      _posts = await _profileService.fetchAllPosts();
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() => _isRefreshing = false);
    }
  }

  Future<void> _refreshPosts() async {
    setState(() => _isRefreshing = true);
    try {
      _posts = await _profileService.fetchAllPosts();
    } catch (e) {
      print('Error refreshing posts: $e');
    } finally {
      setState(() => _isRefreshing = false);
    }
  }

  void _handleCommentAdded(Post post, Comment newComment) {
    setState(() {
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        _posts[index] = post.copyWith(
          comments: [...post.comments, newComment],
          commentCount: post.commentCount + 1,
        );
      }
    });
  }

  void _handleLikeToggled(Post post) async {
    if (_currentUser == null) return;

    final bool isLiked = post.likes.any((like) => like.userId == _currentUser!.id);
    final List<Like> updatedLikes = List.from(post.likes);

    if (isLiked) {
      updatedLikes.removeWhere((like) => like.userId == _currentUser!.id);
    } else {
      updatedLikes.add(Like(
        id: 0, // Giá trị tạm thời, server sẽ tạo ID thực
        postId: post.id,
        userId: _currentUser!.id,
        userEmail: _currentUser!.email, // Đảm bảo UserNormal có email
        createdAt: DateTime.now(),
      ));
    }

    setState(() {
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        _posts[index] = post.copyWith(
          likes: updatedLikes,
          likeCount: isLiked ? post.likeCount - 1 : post.likeCount + 1,
        );
      }
    });

    try {
      final updatedPost = await _profileService.toggleLike(post.id);
      setState(() {
        final index = _posts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          _posts[index] = updatedPost; // Cập nhật lại từ server
        }
      });
    } catch (e) {
      print('Error toggling like: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update like status')),
      );
    }
  }

  void _createNewPost() {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load user profile. Please try again.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateMomentScreen(
          userName: _currentUser!.full_name,
          userLocation: _currentUser!.address ?? 'Hoi An, Quang Nam, Vietnam',
          userAvatar: _currentUser!.avatar ?? 'https://example.com/default-avatar.jpg',
        ),
      ),
    ).then((_) => _refreshPosts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Moments'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _isLoadingUser ? null : _createNewPost,
            tooltip: 'Create Post',
          ),
        ],
      ),
      body: _isLoadingUser
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _refreshPosts,
        child: _isRefreshing
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: _posts.length,
          itemBuilder: (context, index) {
            return PostCard(
              post: _posts[index],
              currentUserId: _currentUser?.id ?? 0,
              onCommentAdded: _handleCommentAdded,
              onLikeToggled: _handleLikeToggled,
              onDelete: (postId) async {
                // Xử lý logic xóa bài viết
                // Bạn có thể gọi một hàm xóa bài viết từ API ở đây
              },
            );
          },
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;
  final int currentUserId;
  final Function(Post, Comment) onCommentAdded;
  final Function(Post) onLikeToggled;
  final Function(int) onDelete; // Hàm xóa bài viết

  const PostCard({
    required this.post,
    required this.currentUserId,
    required this.onCommentAdded,
    required this.onLikeToggled,
    required this.onDelete,
  });

  bool _isLikedByCurrentUser() {
    return post.likes.any((like) => like.userId == currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('MMM d, yyyy • h:mm a')
        .format(DateTime.parse(post.createdAt));

    return Card(
      margin: EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(backgroundImage: NetworkImage(post.avatar)),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.userName, style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(formattedDate, style: TextStyle(color: Colors.grey, fontSize: 12))
                      ],
                    )

                  ],
                ),
                if (post.userId == currentUserId) // Kiểm tra nếu bài viết thuộc về người dùng hiện tại
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        // Logic cho việc chỉnh sửa bài viết
                      } else if (value == 'delete') {
                        onDelete(post.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Post deleted')),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ];
                    },
                  ),
              ],
            ),
            SizedBox(height: 4),
            if (post.content.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(post.content),
              ),
            if (post.images.isNotEmpty) _buildImageGrid(post.images),
            Divider(height: 20),
            _buildPostActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(List<PostImage> images) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,  // Chỉ 2 hình ảnh trong mỗi hàng
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemCount: images.length > 4 ? 4 : images.length,  // Hạn chế số lượng hình ảnh hiển thị nếu có hơn 4 hình
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            images[index].content,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: Icon(Icons.error),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPostActions(BuildContext context) {
    final bool isLiked = _isLikedByCurrentUser();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : null,
              ),
              onPressed: () => onLikeToggled(post),
            ),
            Text('${post.likeCount}'),
          ],
        ),
        InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommentScreen(
                  post: post,
                  onCommentAdded: (newComment) => onCommentAdded(post, newComment),
                ),
              ),
            );
          },
          child: Row(
            children: [
              Icon(Icons.comment),
              SizedBox(width: 5),
              Text('${post.commentCount}'),
            ],
          ),
        ),
      ],
    );
  }
}