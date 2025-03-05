import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lokaloka/features/auth/models/user.dart'; // Model UserNormal
import 'package:lokaloka/features/auth/services/auth_services.dart'; // Import AuthService
import 'package:jwt_decoder/jwt_decoder.dart'; // Import jwt_decoder

class ProfileService {
  final String baseUrl = 'https://api.yourapp.com'; // URL của API

  // Hàm lấy thông tin người dùng
  Future<UserNormal?> getUserProfile() async {
    try {
      String? token = await AuthService().getToken();

      if (token == null) {
        print("No token available, please log in again.");
        return null;
      }

      // Continue with API call if token exists
      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Authorization': 'Bearer $token', // Use the token for authentication
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('data')) {
          return UserNormal.fromJson(responseData['data']);
        }
      } else {
        print('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error while fetching profile: $e');
    }
    return null;
  }


  // Cập nhật thông tin người dùng
  Future<bool> updateUserProfile(UserNormal user) async {
    try {
      String? token = await AuthService().getToken(); // Lấy token từ AuthService

      if (token == null) {
        print("No token found");
        return false;
      }

      // Giải mã token để lấy thông tin user_id
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String userId = decodedToken['id'];

      final response = await http.put(
        Uri.parse('$baseUrl/user/$userId'), // Gửi yêu cầu tới API với userId trong URL
        headers: {
          'Authorization': 'Bearer $token', // Dùng token để xác thực
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'full_name': user.full_name,
          'email': user.email,
          'phone': user.phone,
          'address': user.address,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to update profile: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error while updating profile: $e');
      return false;
    }
  }
}
