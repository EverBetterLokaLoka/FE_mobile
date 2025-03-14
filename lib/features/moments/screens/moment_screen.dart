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
    final int updatedLikeCount = isLiked ? post.likeCount - 1 : post.likeCount + 1;

    // Update the local state to reflect immediate feedback
    setState(() {
      if (isLiked) {
        // User is unliking the post
        updatedLikes.removeWhere((like) => like.userId == _currentUser!.id);
      } else {
        // User is liking the post
        updatedLikes.add(Like(
          id: 0, // Use a temporary ID
          postId: post.id,
          userId: _currentUser!.id,
          userEmail: _currentUser!.email,
          createdAt: DateTime.now(),
        ));
      }

      // Update the post with the new like state without changing the content
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        _posts[index] = post.copyWith(
          likes: updatedLikes,
          likeCount: updatedLikeCount,
        );
      }
    });

    try {
      // Call the API to toggle the like
      await _profileService.toggleLike(post.id);
      // No need to update state again - we've already handled it above in setState
    } catch (e) {
      print('Error toggling like: $e');

      // In case of failure, revert the change
      setState(() {
        final index = _posts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          // Revert to the previous like state as needed
          if (isLiked) {
            updatedLikes.add(Like(
              id: 0, // Use the temporary ID previously assigned
              postId: post.id,
              userId: _currentUser!.id,
              userEmail: _currentUser!.email,
              createdAt: DateTime.now(),
            ));
          } else {
            updatedLikes.removeWhere((like) => like.userId == _currentUser!.id);
          }

          // Update like count back to original
          _posts[index] = post.copyWith(
            likes: updatedLikes,
            likeCount: isLiked ? updatedLikeCount + 1 : updatedLikeCount - 1,
          );
        }
      });

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
    if (images.length == 3) {
      return Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              images[0].content,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    images[1].content,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    images[2].content,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Mặc định hiển thị dạng lưới 2x2 nếu có từ 4 ảnh trở lên
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: images.length == 1 ? 1 : 2,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemCount: images.length > 4 ? 4 : images.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            images[index].content,
            fit: BoxFit.cover,
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