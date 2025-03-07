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

class ProfileService {
  String baseUrl = ApiService().baseUrl;
  final ApiService _apiService = ApiService();

  // Lấy thông tin người dùng từ API
  Future<UserNormal?> getUserProfile() async {
    try {
      String? token = await AuthService().getToken();
      if (token == null) {
        print("No token available, please log in again.");
        return null;
      }

      // Giải mã token để lấy userId
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      if (!decodedToken.containsKey('id')) {
        throw Exception("Token không chứa ID người dùng!");
      }
      String userId = decodedToken['id'].toString();

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
    } on TimeoutException {
      throw Exception('Request timeout, please try again.');
    } on SocketException {
      throw Exception('Network error: Please check your internet connection.');
    } on FormatException {
      throw Exception('Invalid response format.');
    } catch (e) {
      print('Error while fetching profile: $e');
      return null;
    }
  }

  // Cập nhật thông tin người dùng
  Future<bool> updateUserProfile(UserNormal user) async {
    try {
      String? token = await AuthService().getToken();
      if (token == null) {
        throw Exception("No token found");
      }

      // Giải mã token để lấy userId
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      if (!decodedToken.containsKey('id')) {
        throw Exception("Token không chứa ID người dùng!");
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
          'emergency_numbers':user.emergency_numbers,
          'dob':user.dob,
          'gender':user.gender,
          'password':user.password
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Invalid request data');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timeout, please try again.');
    } on SocketException {
      throw Exception('Network error: Please check your internet connection.');
    } on FormatException {
      throw Exception('Invalid response format.');
    } catch (e) {
      print('Error while updating profile: $e');
      return false;
    }
  }

  // Lấy danh sách bài đăng
  Future<List<Post>> fetchPosts() async {
    try {
      // Get the authentication token
      String? token = await AuthService().getToken();

      if (token == null) {
        throw Exception('Authentication token is missing. Please log in again.');
      }

      // Sử dụng ApiService nếu bạn muốn dùng phương thức request có sẵn
      // Cách 1: Sử dụng ApiService.request
      try {
        final response = await _apiService.request(
          path: '/posts',
          method: 'GET',
          typeUrl: UrlConstant().baseUrl,
          currentPath: '/posts',
          data: null,
        );

        if (response.statusCode == 200) {
          List<dynamic> jsonData = json.decode(response.body);
          return jsonData.map((post) => Post.fromJson(post)).toList();
        } else {
          throw Exception('Failed to load posts: ${response.statusCode}');
        }
      } catch (e) {
        // Nếu có lỗi với ApiService, thử cách 2
        print('Error using ApiService.request: $e');

        // Cách 2: Sử dụng http trực tiếp (giống như các phương thức khác trong class này)
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
        } else if (response.statusCode == 401) {
          throw Exception('Unauthorized: Please log in again');
        } else {
          throw Exception('Failed to load posts: ${response.statusCode}');
        }
      }
    } on TimeoutException {
      throw Exception('Request timeout, please try again.');
    } on SocketException {
      throw Exception('Network error: Please check your internet connection.');
    } on FormatException {
      throw Exception('Invalid response format.');
    } catch (e) {
      print('Error while fetching posts: $e');
      throw Exception('Error fetching posts: $e');
    }
  }
}

