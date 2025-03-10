import 'package:flutter/material.dart';
import 'package:lokaloka/globals.dart';
import '../../../core/styles/colors.dart';
import '../../auth/models/user.dart';
import '../../profile/screens/account_tab.dart';
import '../../profile/services/profile_services.dart';

class TrustPhoneScreen extends StatefulWidget {
  const TrustPhoneScreen({super.key});

  @override
  _TrustPhoneScreenState createState() => _TrustPhoneScreenState();
}

class _TrustPhoneScreenState extends State<TrustPhoneScreen> {
  late final UserNormal user;
  late final Function() onProfileUpdated;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController phoneControllerLate = TextEditingController();
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  void dispose() {
    phoneControllerLate.dispose();
    super.dispose();
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return "Phone number cannot be empty.";
    }
    if (!RegExp(r'^\d{10,11}$').hasMatch(value)) {
      return "⚠ Invalid phone number.";
    }
    return null;
  }

  Future<void> _fetchUserProfile() async {
    final response = await _profileService.getUserProfile();

    if (response != null) {
      setState(() {
        user = response;
      });
    } else {
      showCustomNotification(
        context: context,
        notification: CustomNotification(
          message: 'Fail to load user data',
          isError: true,
        ),
      );
    }
  }

  Future<void> _handleUpdate() async {
    final updatedUser = UserNormal(
      id: user.id,
      full_name: user.full_name,
      dob: user.dob,
      gender: user.gender,
      email: user.email,
      phone: user.phone,
      address: user.address,
      emergency_numbers: phoneControllerLate.text,
      name: user.name,
      avatar: user.avatar,
    );

    final result = await _profileService.updateUserProfile(updatedUser);

    if (result is bool && result) {
      trustPhone = phoneControllerLate.text;
      showCustomNotification(
        context: context,
        notification: CustomNotification(
          message: 'Trust phone updated successfully.',
        ),
      );

      Navigator.pushNamed(context, '/home');
    } else {
      showCustomNotification(
        context: context,
        notification: CustomNotification(
          message:
              'An error occurred while updating your profile. Please try again later.',
          isError: true,
        ),
      );
    }
  }

  void showCustomNotification({
    required BuildContext context,
    required Widget notification,
    Duration duration = const Duration(seconds: 3),
  }) {
    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: notification,
        ),
      ),
    );

    Overlay.of(context).insert(entry);

    // Xóa thông báo sau khoảng thời gian
    Future.delayed(duration, () {
      entry?.remove();
    });
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
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 15),
                _buildLanguageDropdown(),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildIntroCard(),
                      const SizedBox(height: 15),
                      _buildPhoneForm(),
                      const SizedBox(height: 20),
                      _buildFinishButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return Align(
      alignment: Alignment.topRight,
      child: DropdownButton<String>(
        value: "English",
        icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
        items: ["English", "Vietnamese"]
            .map((String value) => DropdownMenuItem<String>(
                  value: value,
                  child:
                      Text(value, style: const TextStyle(color: Colors.black)),
                ))
            .toList(),
        onChanged: (String? newValue) {},
      ),
    );
  }

  Widget _buildIntroCard() {
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
          )
        ],
      ),
      child: Column(
        children: const [
          Text(
            "Welcome",
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.orangeColor),
          ),
          SizedBox(height: 10),
          Text(
            "This feature is designed to assist users in emergency situations or inconveniences, such as falling off a bike, accidents, or running out of gas. When you send out an emergency signal, other users in the nearby area who are also using the app will receive notifications and can quickly come to your aid. This not only helps you get timely assistance but also fosters a safe and reliable community.",
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
          SizedBox(height: 10),
          Text(
            "You are not alone in difficult times!",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15,
                color: Color(0xFFFF8C00),
                fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Emergency Numbers",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextFormField(
            controller: phoneControllerLate,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: "Enter trust phone number",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: const Icon(Icons.phone),
            ),
            validator: validatePhone,
          ),
        ],
      ),
    );
  }

  Widget _buildFinishButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _handleUpdate();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF8C00),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 75),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: const Text("Finish",
          style: TextStyle(fontSize: 16, color: Colors.white)),
    );
  }
}
