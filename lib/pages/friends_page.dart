// lib/pages/friends_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_friend_page.dart';
import 'others_profile.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/session.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final TextEditingController _searchController = TextEditingController();
  final String baseUrl = 'http://192.168.100.12:3000/api';
  
  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> _requests = [];
  bool _isSearching = false; // Track if we're in search mode

  @override
  void initState() {
    super.initState();
    _fetchFriends();
    _fetchFriendRequests();
    
    // Only search when user stops typing
    _searchController.addListener(() {
      final q = _searchController.text.trim();
      setState(() {
        _isSearching = q.isNotEmpty;
      });
      
      if (q.isEmpty) {
        _fetchFriends(); // Show friends list when search is cleared
      } else {
        _searchFriends(q); // Search within friends only
      }
    });
  }

  Future<void> _fetchFriendRequests() async {
    if (Session.authHeader == null) return;
    try {
      final uri = Uri.parse('$baseUrl/users/friend-requests');
      final resp = await http.get(
        uri,
        headers: {
          'client': 'not-browser',
          'authorization': Session.authHeader!,
        },
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true && data['requests'] != null) {
          final List list = data['requests'];
          setState(() {
            // Only show PENDING requests
            _requests = list
                .where((r) => r['status'] == 'pending')
                .map<Map<String, dynamic>>((r) {
              final from = r['from'];
              return {
                '_id': r['_id'] ?? r['id'] ?? r['requestId'],
                'fromId': from != null ? (from['_id'] ?? from['id']) : r['from'],
                'name': from != null ? (from['name'] ?? '') : '',
                'profilePic': from != null ? (from['profilePic'] ?? null) : null,
                'status': r['status'] ?? 'pending',
              };
            }).toList();
          });
        }
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _fetchFriends() async {
    if (Session.authHeader == null) return;
    try {
      final uri = Uri.parse('$baseUrl/users/friends');
      final resp = await http.get(
        uri,
        headers: {
          'client': 'not-browser',
          'authorization': Session.authHeader!,
        },
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true && data['friends'] != null) {
          final List list = data['friends'];
          setState(() {
            friends = list.map<Map<String, dynamic>>((u) {
              return {
                '_id': u['_id'],
                'name': u['name'],
                'profilePic': u['profilePic'],
                'uuid': u['uuid'],
              };
            }).toList();
          });
        }
      }
    } catch (e) {
      // ignore network errors for now
    }
  }

  // Search ONLY within current friends list (client-side filtering)
  Future<void> _searchFriends(String q) async {
    if (Session.authHeader == null) return;
    
    try {
      // First, get the full friends list
      final uri = Uri.parse('$baseUrl/users/friends');
      final resp = await http.get(
        uri,
        headers: {
          'client': 'not-browser',
          'authorization': Session.authHeader!,
        },
      );
      
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true && data['friends'] != null) {
          final List list = data['friends'];
          final allFriends = list.map<Map<String, dynamic>>((u) {
            return {
              '_id': u['_id'],
              'name': u['name'],
              'profilePic': u['profilePic'],
              'uuid': u['uuid'],
            };
          }).toList();
          
          // Filter friends by search query (name or UUID)
          setState(() {
            friends = allFriends.where((friend) {
              final name = friend['name']?.toString().toLowerCase() ?? '';
              final uuid = friend['uuid']?.toString().toLowerCase() ?? '';
              final query = q.toLowerCase();
              return name.contains(query) || uuid.contains(query);
            }).toList();
          });
        }
      }
    } catch (e) {
      // ignore
    }
  }

  void _removeFriendAt(int index) {
    final removed = friends[index];
    final id = removed['_id'] ?? removed['uuid'];
    if (id != null) {
      _deleteFriend(id);
    } else {
      setState(() {
        friends.removeAt(index);
      });
    }
  }

  void _confirmRemoveFriend(String name, int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          "Remove $name?",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          "Are you sure you want to remove this friend?",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              _removeFriendAt(index);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: Text("Remove", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / 390;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFE6F8F0),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(60),
              topRight: Radius.circular(60),
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                bottom: 100 * scale,
                child: Padding(
                  padding: EdgeInsets.all(20 * scale),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 15 * scale),
                        Text(
                          "Your Friends",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 20 * scale,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 20 * scale),
                        TextField(
                          controller: _searchController,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 15 * scale,
                          ),
                          decoration: InputDecoration(
                            hintText: "Search friend...",
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
                              fontSize: 14 * scale,
                            ),
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 16 * scale,
                              horizontal: 16 * scale,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30 * scale),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 25 * scale),
                        
                        // Pending incoming friend requests (hide when searching)
                        if (!_isSearching && _requests.isNotEmpty) ...[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Requests",
                              style: GoogleFonts.poppins(
                                fontSize: 16 * scale,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(height: 10 * scale),
                          Column(
                            children: _requests.map((r) {
                              return Container(
                                margin: EdgeInsets.only(bottom: 10 * scale),
                                padding: EdgeInsets.all(10 * scale),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12 * scale),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20 * scale,
                                      backgroundImage: r['profilePic'] != null
                                          ? NetworkImage(r['profilePic']) as ImageProvider
                                          : const AssetImage('assets/profile.jpg'),
                                    ),
                                    SizedBox(width: 12 * scale),
                                    Expanded(
                                      child: Text(
                                        r['name'] ?? 'Unknown',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton(
                                      onPressed: () => _respondToFriendRequest(
                                        r['_id']?.toString(),
                                        'accept',
                                      ),
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: EdgeInsets.symmetric(horizontal: 14 * scale),
                                      ),
                                      child: Text(
                                        'Accept',
                                        style: GoogleFonts.poppins(color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 8 * scale),
                                    TextButton(
                                      onPressed: () => _respondToFriendRequest(
                                        r['_id']?.toString(),
                                        'reject',
                                      ),
                                      child: Text(
                                        'Reject',
                                        style: GoogleFonts.poppins(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 12 * scale),
                        ],
                        
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Friends List",
                            style: GoogleFonts.poppins(
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 10 * scale),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: friends.length,
                          itemBuilder: (context, index) {
                            return _buildFriendTile(friends[index], index, scale);
                          },
                        ),

                        if (friends.isEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 40 * scale),
                            child: Text(
                              _isSearching ? "No friends found" : "No friends yet",
                              style: GoogleFonts.poppins(color: Colors.grey),
                            ),
                          ),
                        SizedBox(height: 100 * scale),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Add Friend Button
              Positioned(
                left: 0,
                right: 0,
                bottom: 35 * scale,
                child: Center(
                  child: SizedBox(
                    width: 160 * scale,
                    height: 52 * scale,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddFriendPage()),
                        );
                        if (result == true) {
                          await _fetchFriendRequests();
                          await _fetchFriends();
                        }
                      },
                      icon: Icon(Icons.person_add, size: 20 * scale),
                      label: Text(
                        "Add",
                        style: GoogleFonts.poppins(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D09E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14 * scale),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFriendTile(Map<String, dynamic> friend, int index, double scale) {
    return Container(
      margin: EdgeInsets.only(bottom: 12 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF00D09E),
        borderRadius: BorderRadius.circular(15 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 3 * scale),
          ),
        ],
      ),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OthersProfileViewPage(
              userId: friend['uuid'] ?? friend['_id']?.toString(),
            ),
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 20 * scale,
          backgroundImage: friend['profilePic'] != null
              ? NetworkImage(friend['profilePic']) as ImageProvider
              : const AssetImage('assets/profile.jpg'),
        ),
        title: Text(
          friend['name'],
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 14 * scale,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.white, size: 22 * scale),
          onPressed: () => _confirmRemoveFriend(friend['name'], index),
          tooltip: 'Remove friend',
        ),
      ),
    );
  }

  Future<void> _deleteFriend(String friendId) async {
    if (Session.authHeader == null) return;
    try {
      final uri = Uri.parse('$baseUrl/users/friends/$friendId');
      final resp = await http.delete(
        uri,
        headers: {
          'client': 'not-browser',
          'authorization': Session.authHeader!,
        },
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) {
          await _fetchFriends();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Friend removed'),
              backgroundColor: Color(0xFF00D09E),
            ),
          );
        }
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _respondToFriendRequest(String? requestId, String action) async {
    if (requestId == null || Session.authHeader == null) return;
    try {
      final uri = Uri.parse('$baseUrl/users/friend-request/$requestId');
      final resp = await http.patch(
        uri,
        headers: {
          'client': 'not-browser',
          'authorization': Session.authHeader!,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'action': action}),
      );
      final data = jsonDecode(resp.body);
      if (resp.statusCode == 200 && data['success'] == true) {
        // Refresh both lists
        await _fetchFriendRequests();
        await _fetchFriends();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              action == 'accept' 
                  ? 'Friend request accepted!' 
                  : 'Friend request rejected',
            ),
            backgroundColor: const Color(0xFF00D09E),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }
}