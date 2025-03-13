import 'package:flutter/material.dart';
import '../models/friend.dart';

class FriendListItem extends StatelessWidget {
  final Friend friend;
  final Widget actionButton;

  const FriendListItem({
    Key? key,
    required this.friend,
    required this.actionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: friend.avatar != null && friend.avatar!.isNotEmpty
                ? NetworkImage(friend.avatar!)
                : null,
            child: friend.avatar == null || friend.avatar!.isEmpty
                ? Text(
              friend.username.isNotEmpty ? friend.username[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 20),
            )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  friend.email,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          actionButton,
        ],
      ),
    );
  }
}

