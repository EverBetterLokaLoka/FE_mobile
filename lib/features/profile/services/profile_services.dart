import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:lokaloka/core/utils/apis.dart';
import 'package:lokaloka/features/auth/models/user.dart';
import 'package:lokaloka/features/auth/services/auth_services.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:lokaloka/features/profile/models/post_modal.dart';
import 'package:lokaloka/core/constants/url_constant.dart';
import 'package:lokaloka/globals.dart';

class ProfileService {
  String baseUrl = ApiService().baseUrl;
  final ApiService _apiService = ApiService();

  Future<UserNormal?> getUserProfile() async {
    try {
      String? token = await AuthService().getToken();
      if (token == null) {
        throw Exception("No token available, please log in again.");
      }

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      if (!decodedToken.containsKey('id')) {
        throw Exception("Token doesn't contain user ID!");
      }
      String userId = decodedToken['id'].toString();
      print(userId);
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return UserNormal.fromJson(responseData['data']);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error while fetching profile: $e');
      rethrow;
    }
  }

  Future<bool> updateUserProfile(UserNormal user) async {
    try {
      String? token = await AuthService().getToken();
      if (token == null) {
        throw Exception("No token found");
      }

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      if (!decodedToken.containsKey('id')) {
        throw Exception("Token doesn't contain user ID!");
      }
      String userId = decodedToken['id'].toString();

      final response = await http.put(
        Uri.parse('$baseUrl/user/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'full_name': user.full_name,
          'email': user.email,
          'phone': user.phone,
          'address': user.address,
          'emergency_numbers': user.emergency_numbers,
          'dob': user.dob,
          'gender': user.gender,
          'password': user.password
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        trustPhone = user.emergency_numbers!;
        return true;
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error while updating profile: $e');
      rethrow;
    }
  }

  Future<List<Post>> fetchPosts() async {
    try {
      String? token = await AuthService().getToken();
      if (token == null) {
        throw Exception('Authentication token is missing. Please log in again.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/posts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((post) => Post.fromJson(post)).toList();
      } else {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error while fetching posts: $e');
      rethrow;
    }
  }

  Future<Comment> addComment(int postId, String content) async {
    try {
      String? token = await AuthService().getToken();
      if (token == null) {
        throw Exception('Authentication token is missing. Please log in again.');
      }

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      if (!decodedToken.containsKey('id')) {
        throw Exception("Token doesn't contain user ID!");
      }

      // Get user email for the comment (if available)
      String userEmail = '';
      try {
        final userProfile = await getUserProfile();
        if (userProfile != null) {
          userEmail = userProfile.email;
        }
      } catch (e) {
        print('Could not get user profile: $e');
        // Continue without email, we'll handle empty email in the UI
      }

      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/comments'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'content': content,
          'userId': decodedToken['id'],
        }),
      ).timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Ensure required fields have default values if they're missing
        if (responseData['userEmail'] == null || responseData['userEmail'] == '') {
          responseData['userEmail'] = userEmail.isNotEmpty ? userEmail : 'user@example.com';
        }

        if (responseData['id'] == null) responseData['id'] = 0;
        if (responseData['postId'] == null) responseData['postId'] = postId;
        if (responseData['userId'] == null) {
          responseData['userId'] = int.tryParse(decodedToken['id'].toString()) ?? 0;
        }

        // Make sure content is included
        if (responseData['content'] == null || responseData['content'] == '') {
          responseData['content'] = content;
        }

        // Make sure createdAt is included
        if (responseData['createdAt'] == null || responseData['createdAt'] == '') {
          responseData['createdAt'] = DateTime.now().toIso8601String();
        }

        // Debug: Print the processed response data
        print('Processed response data: $responseData');

        return Comment.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      } else {
        throw Exception('Failed to add comment: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timeout. Please try again.');
    } on SocketException {
      throw Exception('Network error. Please check your internet connection.');
    } catch (e) {
      print('Error while adding comment: $e');
      rethrow;
    }
  }
  // Add this method to profile_services.dart
  Future<UserNormal?> getUserById(int userId) async {
    try {
      String? token = await AuthService().getToken();
      if (token == null) {
        throw Exception("No token available, please log in again.");
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return UserNormal.fromJson(responseData['data']);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      print('Error while fetching user: $e');
      rethrow;
    }
  }
  Future<String> getUserName() async {
    try {
      UserNormal? user = await getUserProfile();
      return user?.full_name ?? 'Unknown User';
    } catch (e) {
      print('Error fetching user name: $e');
      return 'Unknown User';
    }
  }
}