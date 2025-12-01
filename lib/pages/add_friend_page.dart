import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/session.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final TextEditingController _uidController = TextEditingController();
  final FocusNode _uidFocusNode = FocusNode();

  final String baseUrl = 'http://192.168.100.12:3000/api';

  Map<String, dynamic>? _foundUser;
  bool _requestSent = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _uidController.addListener(_searchUser);
  }

  void _searchUser() {
    final String uid = _uidController.text.trim();
    setState(() => _isSearching = uid.isNotEmpty);
    if (uid.isEmpty) {
      setState(() {
        _foundUser = null;
        _requestSent = false;
      });
      return;
    }

    // call backend search
    _searchUserBackend(uid);
  }

  Future<void> _searchUserBackend(String q) async {
    if (Session.authHeader == null) return;
    try {
      final uri = Uri.parse(
        '$baseUrl/users/search?query=${Uri.encodeComponent(q)}',
      );
      final resp = await http.get(
        uri,
        headers: {
          'client': 'not-browser',
          'authorization': Session.authHeader!,
        },
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true &&
            data['users'] != null &&
            (data['users'] as List).isNotEmpty) {
          final u = data['users'][0];
          setState(() {
            _foundUser = {
              '_id': u['_id'],
              'name': u['name'],
              'uuid': u['uuid'],
              'profilePic': u['profilePic'],
            };
            _requestSent = false;
          });
          return;
        }
      }
      setState(() {
        _foundUser = null;
        _requestSent = false;
      });
    } catch (e) {
      setState(() {
        _foundUser = null;
        _requestSent = false;
      });
    }
  }

  void _sendFriendRequest() {
    if (_foundUser == null) return;
    _sendFriendRequestBackend();
  }

  Future<void> _sendFriendRequestBackend() async {
    if (Session.authHeader == null || _foundUser == null) return;
    final friendId = _foundUser!['_id'] ?? _foundUser!['uuid'];
    if (friendId == null) return;
    try {
      final uri = Uri.parse('$baseUrl/users/friend-request/$friendId');
      final resp = await http.post(
        uri,
        headers: {
          'client': 'not-browser',
          'authorization': Session.authHeader!,
          'Content-Type': 'application/json',
        },
      );
      final data = jsonDecode(resp.body);
      if (resp.statusCode == 200 && data['success'] == true) {
        setState(() {
          _requestSent = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Request sent')),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to send request')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    }
  }

  @override
  void dispose() {
    _uidController.dispose();
    _uidFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F8F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        title: Text(
          'Add Friend',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Friend by UID',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 15),

            // UID Input Field
            TextField(
              controller: _uidController,
              focusNode: _uidFocusNode,
              decoration: InputDecoration(
                hintText: 'Enter 8-digit UID',
                hintStyle: GoogleFonts.poppins(color: Colors.black54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                suffixIcon: _isSearching
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _uidController.clear();
                          _uidFocusNode.requestFocus();
                        },
                      )
                    : null,
              ),
              style: GoogleFonts.poppins(fontSize: 16),
              keyboardType: TextInputType.number,
              maxLength: 8,
              onSubmitted: (value) {
                if (value.length == 8) {
                  _searchUser();
                }
              },
            ),
            const SizedBox(height: 10),
            Text(
              'UID must be exactly 8 digits (0-9)',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
            ),

            const SizedBox(height: 30),

            // Scrollable display area
            Expanded(child: _buildResultWidget()),
          ],
        ),
      ),
    );
  }

  Widget _buildResultWidget() {
    if (_uidController.text.isEmpty) {
      return _buildPlaceholder();
    } else if (_isSearching && _foundUser == null) {
      return _buildUserNotFound();
    } else if (_foundUser != null) {
      return _buildUserCard();
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Type UID to search for a friend',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserNotFound() {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No user found with this UID',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile Image with proper styling
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00D09E),
                    image: DecorationImage(
                      image: _foundUser!['profilePic'] != null
                          ? NetworkImage(_foundUser!['profilePic'])
                                as ImageProvider
                          : AssetImage('assets/default_profile.png'),
                    ),
                    border: Border.all(
                      color: const Color(0xFF00D09E),
                      width: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Name
                Text(
                  _foundUser!['name'],
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                // UID
                Text(
                  'UID: ${_foundUser!['uuid']}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),

                // Send Request Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _requestSent ? null : _sendFriendRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _requestSent
                          ? Colors.grey
                          : const Color(0xFF00D09E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _requestSent ? 'Request Sent' : 'Send Request',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Additional space to ensure scrollability
          Container(
            height: 100, // Extra space to make scrolling obvious
            color: Colors.transparent,
          ),
        ],
      ),
    );
  }
}
