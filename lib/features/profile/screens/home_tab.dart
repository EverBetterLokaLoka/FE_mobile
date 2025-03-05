import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> posts = [
      {
        'username': 'Đức Phát',
        'status': 'is feeling good 😊',
        'location': 'Đà Lạt',
        'caption': 'I have a good day',
        'images': ['assets/image1.png', 'assets/image2.png', 'assets/image3.png'],
        'likes': 12645,
        'comments': 1000,
        'shares': 2000
      },
      {
        'username': 'Đức Phát',
        'status': 'on a trip 😊',
        'location': 'Đà Lạt',
        'caption': 'I’m interested in Đà Lạt',
        'images': ['assets/image1.png', 'assets/image2.png', 'assets/image3.png'],
        'likes': 12645,
        'comments': 1000,
        'shares': 2000
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(10),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        var post = posts[index];
        return Card(
          margin: EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${post['username']} ${post['status']}", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(post['location'], style: TextStyle(color: Colors.grey)),
                SizedBox(height: 5),
                Text(post['caption']),
                SizedBox(height: 5),
                _buildImageGrid(post['images']),
                _buildPostActions(post),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageGrid(List<String> images) {
    if (images.isEmpty) return SizedBox(); // Nếu không có ảnh, tránh lỗi

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          childAspectRatio: 1.0, // Đảm bảo ảnh vuông
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              images[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300], // Màu nền khi lỗi
                  child: Center(
                    child: Image.asset('assets/default.png', fit: BoxFit.cover), // Ảnh mặc định
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostActions(Map<String, dynamic> post) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.favorite_border),
            SizedBox(width: 5),
            Text('${post['likes']}'),
          ],
        ),
        Row(
          children: [
            Icon(Icons.comment),
            SizedBox(width: 5),
            Text('${post['comments']}'),
          ],
        ),
        Row(
          children: [
            Icon(Icons.share),
            SizedBox(width: 5),
            Text('${post['shares']}'),
          ],
        ),
      ],
    );
  }
}
