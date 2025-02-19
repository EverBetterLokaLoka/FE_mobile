import 'package:flutter/material.dart';
import '../../../core/utils/apis.dart';

class Login extends StatelessWidget {
  final String responseBody;

  const Login(this.responseBody, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Response")),
      body: Center(
        child: Text(responseBody),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final ApiService _apiService = ApiService();
  final data = ['email@gmail.com', 'password'];
  LoginPage({super.key});

  Future<void> login(context, data) async {
    print("${data.email} - ${data.password}");
    // final response = await _apiService.request(
    //   path: '/login',
    //   method: 'POST',
    //   typeUrl: 'baseUrl',
    //   data: {'email': data.email, 'password': data.password},
    // );

    // if (context.mounted) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => Login(response.body),
    //     ),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => login(context, data),
          child: const Text("Login"),
        ),
      ),
    );
  }
}
