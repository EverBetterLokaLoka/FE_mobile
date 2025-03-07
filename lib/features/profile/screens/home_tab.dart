import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lokaloka/core/utils/apis.dart';
import 'package:lokaloka/features/profile/models/post_modal.dart';
import 'package:lokaloka/features/profile/services/profile_services.dart';


class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final ProfileService _profileService= ProfileService();
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = _profileService.fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
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
                  onPressed: () {
                    setState(() {
                      _postsFuture = _profileService.fetchPosts();
                    });
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No posts available'));
        }

        final posts = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _postsFuture = _profileService.fetchPosts();
            });
          },
          child: ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return _buildPostCard(post);
            },
          ),
        );
      },
    );
  }

  Widget _buildPostCard(Post post) {
    // Format the date
    final DateTime postDate = DateTime.parse(post.createdAt);
    final String formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(postDate);

    return Card(
      margin: EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info and date
            Row(
              children: [
                CircleAvatar(
                  child: Text(post.userEmail[0].toUpperCase()),
                  backgroundColor: Colors.blue,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userEmail.split('@')[0],
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

            // Post title
            if (post.title.isNotEmpty)
              Text(
                post.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

            // Post content
            if (post.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(post.content),
              ),

            // Images
            if (post.images.isNotEmpty) _buildImageGrid(post.images),

            Divider(height: 20),

            // Actions
            _buildPostActions(post),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(List<PostImage> images) {
    if (images.isEmpty) return SizedBox();

    // For a single image, show it full width
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

    // For multiple images, use a grid
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
          // If there are more than 6 images, show a +X overlay on the last one
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
            Icon(Icons.favorite_border),
            SizedBox(width: 5),
            Text('${post.likeCount}'),
          ],
        ),
        Row(
          children: [
            Icon(Icons.comment),
            SizedBox(width: 5),
            Text('${post.commentCount}'),
          ],
        ),
        Row(
          children: [
            Icon(Icons.share),
            SizedBox(width: 5),
            Text('0'), // API doesn't provide shares count, so defaulting to 0
          ],
        ),
      ],
    );
  }
}

