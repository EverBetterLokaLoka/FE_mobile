import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/apis.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ApiService _apiService = ApiService();

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      print(userCredential);
      return userCredential.user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  Future<UserNormal?> signIn(
      String email, String password, String currentPath) async {
    try {
      final response = await _apiService.request(
        path: '/auth/login',
        method: 'POST',
        typeUrl: 'baseUrl',
        currentPath: currentPath,
        data: {
          'email': email,
          'password': password,
        },
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      String token = responseData["token"];
      saveToken(token);

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

  Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentTime = DateTime.now().millisecondsSinceEpoch;

    await prefs.setString("auth_token", token);
    await prefs.setInt("token_saved_time", currentTime);
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("auth_token");
    int? savedTime = prefs.getInt("token_saved_time");

    if (token == null || savedTime == null) {
      print("No token found!");
      return null;
    }

    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int elapsedTime = (currentTime - savedTime) ~/ 1000;

    if (elapsedTime > 1500) {
      print("Token expired! User needs to log in again.");
      await prefs.remove("auth_token");
      await prefs.remove("token_saved_time");
      return null;
    }

    print("Token is valid!");
    return token;
  }

  Future<bool> isTokenValid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("auth_token");
    int? savedTime = prefs.getInt("token_saved_time");

    if (token == null || savedTime == null) {
      print("No token found!");
      return false;
    }

    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int elapsedTime = (currentTime - savedTime) ~/ 1000;

    if (elapsedTime > 1500) {
      print("Token expired! User needs to log in again.");
      await prefs.remove("auth_token");
      await prefs.remove("token_saved_time");
      return false;
    }

    return true;
  }

  Future<void> checkTokenAndProceed(BuildContext context) async {
    String? currentRoute = ModalRoute.of(context)?.settings.name;

    if (currentRoute == "/login") {
      return;
    }

    bool valid = await isTokenValid();
    if (!valid) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      print("Token is still valid!");
    }
  }
}
