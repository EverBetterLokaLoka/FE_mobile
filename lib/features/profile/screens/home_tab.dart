import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lokaloka/core/constants/url_constant.dart';
import 'package:lokaloka/features/auth/services/auth_services.dart';
import 'package:lokaloka/features/profile/models/post_modal.dart';
import 'package:lokaloka/features/profile/services/profile_services.dart';
import 'package:lokaloka/features/profile/screens/comment_screen.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final ProfileService _profileService = ProfileService();
  late Future<List<Post>> _postsFuture;
  List<Post> _posts = []; // Store posts locally
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isRefreshing = true;
      _postsFuture = _profileService.fetchPosts();
    });

    try {
      final posts = await _postsFuture;

      // Debug: Print post details
      for (var post in posts) {
        print('Post ID: ${post.id}, Comments: ${post.comments.length}');
        for (var comment in post.comments) {
          print('  Comment: ${comment.content}');
        }
      }

      setState(() {
        _posts = posts;
        _isRefreshing = false;
      });
    } catch (e) {
      print('Error loading posts: $e');
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> _refreshPosts() async {
    await _loadPosts();
    return Future.value();
  }

  // Handle new comment added
  void _handleCommentAdded(Post post, Comment newComment) {
    print('Comment added callback: Post ID: ${post.id}, Comment: ${newComment.content}');

    setState(() {
      // Find the post in our list and update it
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        // Create a new post object with updated comment count and comments list
        final updatedPost = Post(
          id: post.id,
          title: post.title,
          content: post.content,
          userId: post.userId,
          userEmail: post.userEmail,
          userName: post.userName,
          createdAt: post.createdAt,
          updatedAt: post.updatedAt,
          avatar: post.avatar,
          comments: [...post.comments, newComment], // Add the new comment
          likes: post.likes,
          images: post.images,
          likeCount: post.likeCount,
          commentCount: post.commentCount + 1, // Increment comment count
          destroyed: post.destroyed,
        );

        // Update the post in our list
        _posts[index] = updatedPost;

        // Debug: Verify the update
        print('Updated post: ID: ${_posts[index].id}, Comments: ${_posts[index].comments.length}');
        for (var comment in _posts[index].comments) {
          print('  Comment: ${comment.content}');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refreshPosts,
          child: _posts.isEmpty && !_isRefreshing
              ? FutureBuilder<List<Post>>(
            future: _postsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${snapshot.error}'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshPosts,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No posts available'));
              }

              // If we have data from the future but not in _posts, update _posts
              if (_posts.isEmpty && snapshot.data != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _posts = snapshot.data!;
                  });
                });
              }

              return _buildPostsList(snapshot.data!);
            },
          )
              : _buildPostsList(_posts),
        ),
        if (_isRefreshing && _posts.isNotEmpty)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildPostsList(List<Post> posts) {
    if (posts.isEmpty) {
      return Center(child: Text('No posts available'));
    }

    return ListView.builder(
      padding: EdgeInsets.all(10),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return _buildPostCard(posts[index]);
      },
    );
  }

  Widget _buildPostCard(Post post) {
    DateTime postDate;
    try {
      postDate = DateTime.parse(post.createdAt);
    } catch (e) {
      postDate = DateTime.now(); // Fallback if date parsing fails
    }

    final String formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(postDate);

    // Get the first letter of email or use a default
    final String avatarText = post.userEmail.isNotEmpty
        ? post.userEmail[0].toUpperCase()
        : '?';


    return Card(
      margin: EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(post.avatar),
                  backgroundColor: Colors.blue,
                ),

                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName ?? 'Loading...',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            if (post.title.isNotEmpty)
              Text(
                post.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

            if (post.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(post.content),
              ),

            if (post.images.isNotEmpty) _buildImageGrid(post.images),

            Divider(height: 20),

            _buildPostActions(post),

            // Show the most recent comment if available
            if (post.comments.isNotEmpty) _buildLatestComment(post.comments.last),
          ],
        ),
      ),
    );
  }

  // Add this method to show the latest comment
  Widget _buildLatestComment(Comment comment) {
    final String username = comment.userName;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Latest comment:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$username: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Expanded(
                  child: Text(
                    comment.content,
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(List<PostImage> images) {
    // Same as before
    if (images.isEmpty) return SizedBox();

    if (images.length == 1) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            images[0].content,
            fit: BoxFit.cover,
            height: 200,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: Colors.grey[300],
                child: Center(child: Icon(Icons.image_not_supported)),
              );
            },
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: images.length == 2 ? 2 : 3,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          childAspectRatio: 1.0,
        ),
        itemCount: images.length > 6 ? 6 : images.length,
        itemBuilder: (context, index) {
          bool showOverlay = images.length > 6 && index == 5;

          return Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  images[index].content,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Center(child: Icon(Icons.image_not_supported)),
                    );
                  },
                ),
              ),
              if (showOverlay)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '+${images.length - 5}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPostActions(Post post) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.favorite_border),
              onPressed: () {
                // Implement like functionality
              },
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
            SizedBox(width: 5),
            Text('${post.likeCount}'),
          ],
        ),
        InkWell(
          onTap: () async {
            // Navigate to comment screen and wait for result
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommentScreen(
                  post: post,
                  onCommentAdded: (newComment) => _handleCommentAdded(post, newComment),
                ),
              ),
            );

            // Force refresh posts when returning from comment screen
            _refreshPosts();
          },
          child: Row(
            children: [
              Icon(Icons.comment),
              SizedBox(width: 5),
              Text('${post.commentCount}'),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                // Implement share functionality
              },
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
            SizedBox(width: 5),
            Text('0'),
          ],
        ),
      ],
    );
  }
}