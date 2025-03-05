import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/apis.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ApiService _apiService = ApiService();

  // Future<User?> signInWithGoogle() async {
  //   try {
  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //     if (googleUser == null) return null;
  //
  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;
  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //
  //     final UserCredential userCredential =
  //         await _auth.signInWithCredential(credential);
  //     print(userCredential);
  //     return userCredential.user;
  //   } catch (e) {
  //     print("Google Sign-In Error: $e");
  //     return null;
  //   }
  // }

  // Future<UserNormal?> signIn(String email, String password) async {
  //   try {
  //     final response = await _apiService.request(
  //         path: '/auth/login',
  //         method: 'POST',
  //         typeUrl: 'baseUrl',
  //         data: {
  //           'email': email,
  //           'password': password,
  //         },
  //         token: '');
  //     print("Response Body: ${response.body}");
  //
  //     final Map<String, dynamic> responseData = jsonDecode(response.body);
  //
  //     if (responseData.containsKey('data')) {
  //       return UserNormal.fromJson(responseData['data']);
  //     }
  //   } catch (e) {
  //     print("Sign-In Error: $e");
  //   }
  //   return null;
  // }

  //
  // Future<String?> getToken() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? token = prefs.getString("auth_token");
  //
  //   if (token == null) {
  //     print("No token found");
  //   }
  //   return token;
  // }

  Future<UserNormal?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Send googleAuth.idToken or googleAuth.accessToken to backend
      final response = await _apiService.request(
        path: '/auth/google-login',  // Your API path for handling Google login
        method: 'POST',
        typeUrl: 'baseUrl',
        data: {
          'idToken': googleAuth.idToken,  // Or send accessToken if needed
        },
        token: '',
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData.containsKey('data')) {
        String token = responseData['data']['token'] ?? '';  // Ensure token is non-null
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("auth_token", token);
        print("Token saved: $token");

        return UserNormal.fromJson(responseData['data']);  // Using UserNormal here
      }
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }



  Future<UserNormal?> signIn(String email, String password) async {
    try {
      final response = await _apiService.request(
        path: '/auth/login',
        method: 'POST',
        typeUrl: 'baseUrl',
        data: {
          'email': email,
          'password': password,
        },
        token: '',
      );
      print("Response Body: ${response.body}");

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData.containsKey('data')) {
        // Lưu token vào SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String token = responseData['data']['token']; // Giả sử bạn nhận được token từ API
        await prefs.setString("auth_token", token);
        print("Token saved: $token"); // Debugging line

        return UserNormal.fromJson(responseData['data']);
      }
    } catch (e) {
      print("Sign-In Error: $e");
    }
    return null;
  }



  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("auth_token");

    if (token == null) {
      print("No token found"); // Debugging line
    } else {
      print("Token retrieved: $token"); // Debugging line
    }

    return token;
  }


  Future<void> fetchUserProfile() async {
    String? token = await getToken();

    if (token != null) {
      // Tiến hành gọi API để lấy thông tin người dùng, sử dụng token cho việc xác thực
      final response = await _apiService.request(
        path: '/user/profile',
        method: 'GET',
        typeUrl: 'baseUrl',
        token: token, // Sử dụng token để xác thực
      );

      if (response.statusCode == 200) {
        // Xử lý phản hồi từ API để lấy thông tin người dùng
        print("User profile fetched successfully.");
      } else {
        print("Failed to fetch user profile.");
      }
    } else {
      print("No token available, please log in again.");
      // Redirect user to login page or show login dialog
    }
  }
}
