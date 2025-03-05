import 'package:flutter/material.dart';
import 'package:lokaloka/features/auth/models/user.dart';

class ProfileHeader extends StatelessWidget {
  final UserNormal user;

  ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        Stack(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.avatar ?? 'assets/images/default_avatar.png'),
              radius: 40,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.orange,
                child: Icon(Icons.camera_alt, size: 15, color: Colors.white),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Text(user.full_name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(user.address ?? 'Address not available', style: TextStyle(color: Colors.grey)),
        Text('Joined: ${user.dob ?? 'Not available'}', style: TextStyle(color: Colors.grey)),
        SizedBox(height: 10),
      ],
    );
  }
}
