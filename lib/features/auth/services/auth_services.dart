import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/url_constant.dart';
import '../../../core/utils/apis.dart';
import '../../../widgets/notice_widget.dart';
import '../../home/screens/term_of_service.dart';
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

  Future<void> signUp({
    required BuildContext context,
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
    required VoidCallback onStart,
    required VoidCallback onFinish,
  }) async {
    onStart();

    final data = {
      'full_name': fullName.trim(),
      'email': email.trim(),
      'password': password.trim(),
      'confirm_password': confirmPassword.trim(),
    };

    try {
      final response = await _apiService.request(
        path: '/auth/register',
        method: 'POST',
        typeUrl: UrlConstant().baseUrl,
        currentPath: '/sign-up',
        data: data,
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        String? token = responseData["token"];
        if (token == null) throw Exception("Token is null");

        saveToken(token);
        showCustomNotice(
            context, 'Your account has been created successfully.', 'confirm');

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TermOfService()),
        );
      } else {
        final responseData = jsonDecode(response.body);
        print(
            'An error occurred while processing your registration. Please try again later. ${responseData["message"]}');
        showCustomNotice(
            context,
            "An error occurred while processing your registration. Please try again later.",
            "notice");

        if (response.statusCode == 409) {
          showCustomNotice(
              context,
              "This email is already in use. Please use a different email or log in.",
              "confirm");
        }
      }
    } catch (e) {
      showCustomNotice(context, e.toString(), 'notice');
    } finally {
      onFinish();
    }
  }

  Future<UserNormal?> signIn(
      String email, String password, String currentPath) async {
    try {
      final response = await _apiService.request(
        path: '/auth/login',
        method: 'POST',
        typeUrl: UrlConstant().baseUrl,
        currentPath: currentPath,
        data: {
          'email': email,
          'password': password,
        },
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      String? token = responseData["token"];

      if (token == null) {
        print("Token is null");
        return null;
      }

      await saveToken(token);

      if (responseData.containsKey('data')) {
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

    print("Retrieved token: $token");

    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int elapsedTime = (currentTime - savedTime) ~/ 1000;

    if (elapsedTime > 1500) {
      print("Token expired! Removing...");
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
