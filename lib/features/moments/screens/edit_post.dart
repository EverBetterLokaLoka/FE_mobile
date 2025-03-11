import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lokaloka/features/profile/models/post_modal.dart';
import 'package:http/http.dart' as http;
import 'package:lokaloka/features/auth/services/auth_services.dart';
import 'package:lokaloka/core/utils/apis.dart';

class EditPostScreen extends StatefulWidget {
  final Post post;
  final ValueChanged<Post> onUpdate;

  const EditPostScreen({Key? key, required this.post, required this.onUpdate}) : super(key: key);

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  List<PostImage> _existingImages = []; // Store existing images
  Set<int> _imagesToDelete = {}; // Track IDs of images to delete
  List<String> _uploadedImageUrls = []; // Store URLs of newly uploaded images

  bool _isUploading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.post.title;
    _contentController.text = widget.post.content;
    _existingImages = List.from(widget.post.images);
  }

  void _pickImages() async {
    if (_isUploading) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        // Get token for upload
        String? token = await _authService.getToken();
        if (token == null) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Authentication token not found'))
          );
          return;
        }

        // Upload each image and collect URLs
        for (var pickedFile in pickedFiles) {
          File imageFile = File(pickedFile.path);
          String? imageUrl = await _uploadImage(token, imageFile);

          if (imageUrl != null) {
            setState(() {
              _uploadedImageUrls.add(imageUrl);
            });
          }
        }
      }
    } catch (e) {
      print('Error picking or uploading images: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload images: $e'))
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<String?> _uploadImage(String token, File image) async {
    try {
      String uploadUrl = "${ApiService().baseUrl}/upload";

      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('file', image.path));

      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);
        print('Upload successful: ${jsonResponse['data']}');
        return jsonResponse['data']; // Return the URL
      } else {
        final responseData = await response.stream.bytesToString();
        print('Upload failed with status: ${response.statusCode}');
        print('Response body: $responseData');
        return null;
      }
    } catch (e) {
      print('Error during upload: $e');
      return null;
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _imagesToDelete.add(_existingImages[index].id);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _uploadedImageUrls.removeAt(index);
    });
  }

  Future<void> _handleUpdate() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Get authentication token
      String? token = await _authService.getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Authentication token not found'))
        );
        return;
      }

      // Prepare image list for new images (simple format like in _publishPost)
      List<Map<String, dynamic>> imageList = _uploadedImageUrls.map((url) => {
        'content': url,
        // You can add other fields if needed
      }).toList();

      // Prepare the request body
      Map<String, dynamic> requestBody = {
        'title': _titleController.text,
        'content': _contentController.text,
        'images': imageList,  // Only include new images
      };

      // If there are images to delete, include their IDs
      if (_imagesToDelete.isNotEmpty) {
        requestBody['deleteImageIds'] = _imagesToDelete.toList();
      }

      // Send the PUT request to update the post
      final response = await http.put(
        Uri.parse('${ApiService().baseUrl}/posts/${widget.post.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Filter out deleted images
        List<PostImage> remainingImages = _existingImages
            .where((image) => !_imagesToDelete.contains(image.id))
            .toList();

        // Create PostImage objects for new images
        List<PostImage> newImages = _uploadedImageUrls.map((url) => PostImage(
          id: 0, // The backend will assign proper IDs
          content: url,
          shares: null,
          locationId: null,
          userId: widget.post.userId,
          postId: widget.post.id,
          mapId: null,
          activityId: null,
          userEmail: widget.post.userEmail,
          type: 'image',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: null,
        )).toList();

        // Create updated post object
        Post updatedPost = Post(
          id: widget.post.id,
          title: _titleController.text,
          content: _contentController.text,
          userId: widget.post.userId,
          userEmail: widget.post.userEmail,
          userName: widget.post.userName,
          createdAt: widget.post.createdAt,
          updatedAt: DateTime.now().toString(),
          avatar: widget.post.avatar,
          comments: widget.post.comments,
          likes: widget.post.likes,
          images: [...remainingImages, ...newImages],
          likeCount: widget.post.likeCount,
          commentCount: widget.post.commentCount,
          destroyed: widget.post.destroyed,
        );

        // Call the callback to update the post in the parent widget
        widget.onUpdate(updatedPost);

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Post updated successfully!'))
        );

        Navigator.of(context).pop(); // Close the edit screen
      } else {
        print('Failed to update post: ${response.statusCode}');
        print('Response body: ${response.body}');

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update post: ${response.statusCode}'))
        );
      }
    } catch (e) {
      print('Error updating post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating post: $e'))
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Post'),
        actions: [
          if (_isSaving)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            Text(
              'Current Images',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 10),
            // Display existing images with option to delete
            if (_existingImages.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _existingImages.length,
                  itemBuilder: (context, index) {
                    final isMarkedForDeletion = _imagesToDelete.contains(_existingImages[index].id);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isMarkedForDeletion ? Colors.red : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Opacity(
                                opacity: isMarkedForDeletion ? 0.5 : 1.0,
                                child: Image.network(
                                  _existingImages[index].content,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      width: 100,
                                      height: 100,
                                      child: Center(child: Icon(Icons.image_not_supported)),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isMarkedForDeletion) {
                                    _imagesToDelete.remove(_existingImages[index].id);
                                  } else {
                                    _removeExistingImage(index);
                                  }
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: isMarkedForDeletion ? Colors.blue : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isMarkedForDeletion ? Icons.undo : Icons.close,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            if (_existingImages.isEmpty || _existingImages.every((img) => _imagesToDelete.contains(img.id)))
              Center(
                child: Text(
                  'No existing images',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            SizedBox(height: 20),
            Text(
              'New Images',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 10),
            // Display newly uploaded images
            if (_uploadedImageUrls.isNotEmpty)
              SizedBox(
                height: 120,
                child: Stack(
                  children: [
                    ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _uploadedImageUrls.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _uploadedImageUrls[index],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      width: 100,
                                      height: 100,
                                      child: Center(child: Icon(Icons.image_not_supported)),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: GestureDetector(
                                  onTap: () => _removeNewImage(index),
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickImages,
              icon: _isUploading
                  ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Icon(Icons.add_photo_alternate),
              label: Text(_isUploading ? 'Uploading...' : 'Add New Images'),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isSaving || _isUploading ? null : _handleUpdate,
                  child: _isSaving
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Updating...'),
                    ],
                  )
                      : Text('Update Post'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}