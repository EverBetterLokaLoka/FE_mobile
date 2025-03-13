import 'package:flutter/material.dart';
import 'package:lokaloka/features/friend/models/friend.dart';
import 'package:lokaloka/features/friend/services/friend_service.dart';
import 'package:lokaloka/features/friend/widgets/friend_list_item.dart';
import 'dart:developer' as developer;

class SearchFriendsScreen extends StatefulWidget {
  const SearchFriendsScreen({Key? key}) : super(key: key);

  @override
  State<SearchFriendsScreen> createState() => _SearchFriendsScreenState();
}

class _SearchFriendsScreenState extends State<SearchFriendsScreen> {
  final FriendService _friendService = FriendService();
  final TextEditingController _searchController = TextEditingController();
  List<Friend> _searchResults = [];
  Map<String, String> _friendStatuses = {}; // Store friend statuses by email
  Map<String, int> _followerIds = {}; // Store follower IDs by email
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchFriends(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      // Get search results
      final results = await _friendService.searchFriends(query);

      // Clear previous statuses and follower IDs
      _friendStatuses.clear();
      _followerIds.clear();

      // Get all friends, pending requests, and friend requests in parallel
      final friendsFuture = _friendService.getFriends();
      final pendingRequestsFuture = _friendService.getPendingRequests();
      final friendRequestsFuture = _friendService.getFriendSuggestions();

      final friends = await friendsFuture;
      final pendingRequests = await pendingRequestsFuture;
      final friendRequests = await friendRequestsFuture;

      // Log the pending requests for debugging
      developer.log('Pending requests: ${pendingRequests.map((f) => '${f.username} (id: ${f.id}, userId: ${f.userId}, email: ${f.email})').join(', ')}');

      // Create maps for faster lookup
      final friendEmails = Map.fromEntries(
          friends.map((f) => MapEntry(f.email.toLowerCase(), f.id))
      );

      final pendingRequestEmails = Map.fromEntries(
          pendingRequests.map((f) => MapEntry(f.email.toLowerCase(), f.id))
      );

      final friendRequestEmails = Map.fromEntries(
          friendRequests.map((f) => MapEntry(f.email.toLowerCase(), f.id))
      );

      // Create temporary maps to store statuses and follower IDs
      Map<String, String> tempStatuses = {};
      Map<String, int> tempFollowerIds = {};

      // Determine status for each search result
      for (var friend in results) {
        final lowerEmail = friend.email.toLowerCase();

        if (friendEmails.containsKey(lowerEmail)) {
          tempStatuses[lowerEmail] = "FRIEND";
          tempFollowerIds[lowerEmail] = friendEmails[lowerEmail]!;
          developer.log('User ${friend.username} (email: ${friend.email}) is a FRIEND with follower ID: ${friendEmails[lowerEmail]}');
        } else if (pendingRequestEmails.containsKey(lowerEmail)) {
          tempStatuses[lowerEmail] = "PENDING";
          tempFollowerIds[lowerEmail] = pendingRequestEmails[lowerEmail]!;
          developer.log('User ${friend.username} (email: ${friend.email}) is PENDING with follower ID: ${pendingRequestEmails[lowerEmail]}');
        } else if (friendRequestEmails.containsKey(lowerEmail)) {
          tempStatuses[lowerEmail] = "REQUESTED";
          tempFollowerIds[lowerEmail] = friendRequestEmails[lowerEmail]!;
          developer.log('User ${friend.username} (email: ${friend.email}) is REQUESTED with follower ID: ${friendRequestEmails[lowerEmail]}');
        } else {
          tempStatuses[lowerEmail] = "NONE";
          developer.log('User ${friend.username} (email: ${friend.email}) is NONE');
        }
      }

      // Only update state once all statuses are determined
      if (mounted) {
        setState(() {
          _searchResults = results;
          _friendStatuses = tempStatuses;
          _followerIds = tempFollowerIds;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        _showErrorSnackBar('Failed to search friends: ${e.toString()}');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true), // Return true to trigger refresh
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Find new friends',
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              border: InputBorder.none,
            ),
            onChanged: (value) {
              _searchFriends(value);
            },
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              _searchFriends(value);
            },
          ),
        ),
      ),
      body: Column(
        children: [
          if (_searchResults.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Friends',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // View all friends action
                    },
                    child: const Text(
                      'View all',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : !_hasSearched
                ? const Center(child: Text('Search for friends'))
                : _searchResults.isEmpty
                ? const Center(child: Text('No results found'))
                : ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final friend = _searchResults[index];
                final lowerEmail = friend.email.toLowerCase();
                final status = _friendStatuses[lowerEmail] ?? "NONE";
                final followerId = _followerIds[lowerEmail];

                return FriendListItem(
                  friend: friend,
                  actionButton: _buildActionButton(friend, status, followerId),
                );
              },
            ),
          ),
          // Bottom action bar with keyboard
          Container(
            height: 50,
            color: Colors.grey.shade200,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.gif_box_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.emoji_emotions_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.image_outlined),
                  onPressed: () {},
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.mic_none),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(Friend friend, String status, int? followerId) {
    developer.log('Building button for ${friend.username} (email: ${friend.email}) with status: $status and follower ID: $followerId');

    switch (status) {
      case "FRIEND":
        return Expanded(
          child: FractionallySizedBox(
            widthFactor: 0.8,
            child: ElevatedButton(
              onPressed: () {
                _showFriendOptions(friend, followerId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Friends'),
            ),
          ),
        );

      case "PENDING":
        return Expanded(
          child: FractionallySizedBox(
            widthFactor: 0.8,
            child: ElevatedButton(
              onPressed: () async {
                if (friend.id != null) {
                  developer.log("friend id" + friend.id.toString());
                  final success = await _friendService.cancelFriendRequestSend(friend.id);
                  if (success) {
                    final lowerEmail = friend.email.toLowerCase();
                    setState(() {
                      _friendStatuses[lowerEmail] = "NONE"; // Update UI status
                      _followerIds.remove(lowerEmail); // Remove ID as it does not exist anymore
                    });
                    _showSuccessSnackBar('Canceled friend request to ${friend.username}');
                  } else {
                    _showErrorSnackBar('Failed to cancel friend request to ${friend.username}');
                  }
                } else {
                  _showErrorSnackBar('Cannot cancel request: Missing follower ID');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
        );

      case "REQUESTED":
        return Expanded(
          child: FractionallySizedBox(
            widthFactor: 0.8,
            child: ElevatedButton(
              onPressed: () async {
                if (followerId != null) {
                  await _acceptFriendRequest(friend, followerId);
                } else {
                  _showErrorSnackBar('Cannot approve request: Missing follower ID');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Confirm'),
            ),
          ),
        );

      case "NONE":
      default:
        return Expanded(
          child: FractionallySizedBox(
            widthFactor: 0.8,
            child: ElevatedButton(
              onPressed: () async {
                await _sendFriendRequest(friend);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Add Friend'),
            ),
          ),
        );
    }
  }

  Future<void> _sendFriendRequest(Friend friend) async {
    try {
      final success = await _friendService.addRequestFriend(friend.userId);
      if (success) {
        final lowerEmail = friend.email.toLowerCase();
        setState(() {
          _friendStatuses[lowerEmail] = "PENDING";
        });
        _showSuccessSnackBar('Friend request sent to ${friend.username}');
      } else {
        _showErrorSnackBar('Failed to send friend request');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  Future<void> _acceptFriendRequest(Friend friend, int followerId) async {
    try {
      // Use the follower ID for approval, not the user ID
      final success = await _friendService.addFriendWithFollowerId(followerId);
      if (success) {
        final lowerEmail = friend.email.toLowerCase();
        setState(() {
          _friendStatuses[lowerEmail] = "FRIEND";
        });
        _showSuccessSnackBar('Added ${friend.username} as friend');
      } else {
        _showErrorSnackBar('Failed to accept friend request');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  void _showFriendOptions(Friend friend, int? followerId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.message),
                title: const Text('Send Message'),
                onTap: () {
                  Navigator.pop(context);
                  // Send message logic
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_remove),
                title: const Text('Unfriend'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    // Use follower ID if available, otherwise use user ID
                    final idToUse = followerId != null ? followerId.toString() : friend.userId.toString();
                    final success = await _friendService.removeFriend(idToUse);
                    if (success) {
                      final lowerEmail = friend.email.toLowerCase();
                      setState(() {
                        _friendStatuses[lowerEmail] = "NONE";
                        _followerIds.remove(lowerEmail);
                      });
                      _showSuccessSnackBar('Unfriended ${friend.username}');
                    } else {
                      _showErrorSnackBar('Failed to unfriend ${friend.username}');
                    }
                  } catch (e) {
                    _showErrorSnackBar('Error: $e');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('Block User'),
                onTap: () {
                  Navigator.pop(context);
                  // Block user logic
                },
              ),
            ],
          ),
        );
      },
    );
  }
}