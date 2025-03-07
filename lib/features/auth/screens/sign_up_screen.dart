import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/styles/colors.dart';
import '../../../core/utils/apis.dart';
import '../../../widgets/notice_widget.dart';
import '../../home/screens/term_of_service.dart';
import '../services/auth_services.dart';
import '../../../core/constants/url_constant.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up", key: Key('signup_title')),
      ),
      body: const SignUpScreen(),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String currentPath = "/sign-up";
  bool _autoValidate = false;  // Add this flag to control validation

  @override
  void initState() {
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  late final Map<String, dynamic> responseData;

  Future<void> _signUp(BuildContext context) async {
    // Enable validation when sign up button is pressed
    setState(() {
      _autoValidate = true;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final apiService = ApiService();
    final data = {
      'full_name': _fullNameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text.trim(),
      'confirm_password': _passwordConfirmController.text.trim(),
    };

    try {
      final response = await apiService.request(
        path: '/auth/register',
        method: 'POST',
        currentPath: currentPath,
        typeUrl: UrlConstant().baseUrl,
        data: data,
      );

      if (response.statusCode == 201) {
        responseData = jsonDecode(response.body);
        String? token = responseData["token"];
        if (token == null) {
          throw Exception("Token is null");
        }
        AuthService().saveToken(token);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign-up successful!')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TermOfService(),
          ),
        );
      } else {
        if (!mounted) return;
        final message = responseData["message"];
        if (message == 409) {
          showCustomNotice(context, "Email already exists.", "confirm");
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/SC_000_Background.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
            child: Form(
              key: _formKey,
              autovalidateMode: _autoValidate
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,  // Only validate after submit
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  _buildSignUpForm(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Sign Up",
            key: const Key('signup_header'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF8C00),
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            "Full Name",
            _fullNameController,
            "Enter your fullname",
            'fullname_field',
          ),
          _buildEmailField(),
          _buildPasswordField(),
          _buildConfirmPasswordField(),
          const SizedBox(height: 20),
          ElevatedButton(
            key: const Key('signup_button'),
            onPressed: _isLoading ? null : () => _signUp(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C00),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 75),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
              "Sign up",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          _buildSocialLogin(),
          ElevatedButton.icon(
            key: const Key('google_signup_button'),
            onPressed: () async {
              final user = await AuthService().signInWithGoogle();
              if (user != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Welcome, ${user.displayName}!")),
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TermOfService(),
                  ),
                );
              }
            },
            icon: Image.asset("assets/images/gg.png", height: 24),
            label: const Text(
              "Sign up with Google",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: const BorderSide(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildSignInOption(),
        ],
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        Row(
          children: const [
            Expanded(child: Divider(thickness: 1, color: Colors.grey)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text("OR"),
            ),
            Expanded(child: Divider(thickness: 1, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      String hintText,
      String keyValue,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label *",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        TextFormField(
          key: Key(keyValue),
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator: (value) {
            if (!_autoValidate) return null;  // Don't validate until form is submitted
            if (value == null || value.isEmpty) {
              return "$label is required";
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Email *",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        TextFormField(
          key: const Key('email_field'),
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: "Enter your email",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator: (value) {
            if (!_autoValidate) return null;  // Don't validate until form is submitted
            if (value == null || value.isEmpty) {
              return "Email is required";
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return "Please enter a valid email";
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Password *",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        TextFormField(
          key: const Key('password_field'),
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: "Enter your password",
            prefixIcon: const Icon(Icons.lock, color: AppColors.orangeColor),
            suffixIcon: IconButton(
              key: const Key('toggle_password_visibility'),
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator: (value) {
            if (!_autoValidate) return null;  // Don't validate until form is submitted
            if (value == null || value.isEmpty) {
              return "Password is required";
            }
            if (value.length < 8 || value.length > 16) {
              return "Password must be between 8 and 16 characters";
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Confirm Password *",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        TextFormField(
          key: const Key('confirm_password_field'),
          controller: _passwordConfirmController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            hintText: "Confirm your password",
            prefixIcon: const Icon(Icons.lock, color: AppColors.orangeColor),
            suffixIcon: IconButton(
              key: const Key('toggle_confirm_password_visibility'),
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator: (value) {
            if (!_autoValidate) return null;  // Don't validate until form is submitted
            if (value == null || value.isEmpty) {
              return "Confirm Password is required";
            }
            if (value != _passwordController.text) {
              return "Passwords do not match";
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSignInOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account? "),
        GestureDetector(
          key: const Key('signin_link'),
          onTap: () {
            Navigator.pushNamed(context, '/login');
          },
          child: const Text(
            "Sign in.",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}