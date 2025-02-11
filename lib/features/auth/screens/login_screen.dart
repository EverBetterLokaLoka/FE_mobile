import 'package:flutter/material.dart';
import '../../../core/utils/apis.dart';

class Login extends StatelessElement{
  final ApiService _apiService = ApiService();

  Login(super.widget);

  Future<void> login(String email, String password) async {
    final response = await _apiService.request(
      path: '/login',
      method: 'POST',
      data: {'email': email, 'password': password},
    );
    print('Login successful: $response');
  }
}