import 'package:flutter/material.dart';
import '../../../core/utils/apis.dart';
import 'login_screen.dart';
import '../../../core/constants/url_constant.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignUpScreen(),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final apiService = ApiService();
    final data = {
      'fullName': _fullNameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
    };

    try {
      final response = await apiService.request(
        path: '/auth/registerWithGoogle',
        method: 'POST',
        typeUrl: UrlConstant().baseUrl,
        data: data,
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign-up successful!')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Login( response.body),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-up failed: ${response.body}')),
        );
      }
    } catch (e) {
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
      body: Container(
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
          const Text(
            "Sign Up",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF8C00),
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
              "Full Name", _fullNameController, "Enter your fullname"),
          _buildEmailField(),
          _buildPasswordField("Password", _passwordController),
          _buildConfirmPasswordField(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _signUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C00),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 75),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              "Sign up",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          _buildSocialLogin(),
          ElevatedButton.icon(
            onPressed: () {},
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
      String label, TextEditingController controller, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label *", style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator: (value) {
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
    return _buildTextField("Email", _emailController, "Enter your email");
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label *", style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Enter your password",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            suffixIcon: const Icon(Icons.visibility_off),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "$label is required";
            } else if (value.length < 6) {
              return "Password must be at least 6 characters long";
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
        const Text("Confirm Password *",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Confirm your password",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            suffixIcon: const Icon(Icons.visibility_off),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Confirm Password is required";
            } else if (value != _passwordController.text) {
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Login(''),
              ),
            );
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
