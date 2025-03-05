import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lokaloka/features/auth/services/auth_services.dart';
import 'package:lokaloka/features/auth/models/user.dart';
import 'package:lokaloka/features/profile/services/profile_services.dart';
import 'profile_header.dart';
import 'account_tab.dart';
import 'home_tab.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserNormal? user;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchUserProfile();
  }

  // Hàm lấy thông tin người dùng
  Future<void> _fetchUserProfile() async {
    String? token = await AuthService().getToken();
    if (token != null) {
      // Fetch user profile using the token
      final response = await ProfileService().getUserProfile();
      if (response != null) {
        setState(() {
          user = response; // Update UI with fetched user data
        });
      } else {
        print("Failed to fetch user profile");
      }
    } else {
      print("No token available, please log in again.");
      // Redirect to login page or show login dialog if token is not found
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushNamed(context, '/home'),
        ),
        title: Text('Profile', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: user == null
          ? Center(child: CircularProgressIndicator()) // Hiển thị loading nếu chưa có thông tin người dùng
          : Column(
        children: [
          ProfileHeader(user: user!), // Truyền thông tin người dùng vào ProfileHeader
          TabBar(
            controller: _tabController,
            labelColor: Colors.orange,
            unselectedLabelColor: Colors.black,
            indicatorColor: Colors.orange,
            tabs: [
              Tab(text: "My Home"),
              Tab(text: "Account"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                HomeTab(), // Giao diện "My Home"
                AccountTab(user: user!), // Truyền thông tin người dùng vào AccountTab
              ],
            ),
          ),
        ],
      ),
    );
  }
}
