// lib/pages/create_room_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../utils/user_model.dart';
import 'select_friends_page.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  List<UserModel> _selectedFriends = [];
  bool _isLoading = false;
  String _selectedColor = '#3B82F6';
  String _selectedIcon = '👥';

  final List<String> _colors = [
    '#3B82F6', '#00D09E', '#F59E0B', '#EF4444', '#8B5CF6', '#EC4899'
  ];
  
  final List<String> _icons = [
    '👥', '🏠', '✈️', '🍕', '🎮', '💼', '🎉', '🏖️', '🚗', '⚽'
  ];

  void _navigateToSelectFriends() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectFriendsPage(
          initialSelectedFriends: _selectedFriends.map((f) => {
            'id': f.id,
            'name': f.name,
            'image': f.profilePic ?? 'assets/profile.jpg',
          }).toList(),
        ),
      ),
    );

    if (result != null && result is List<Map<String, dynamic>>) {
      setState(() {
        _selectedFriends = result.map((data) => UserModel(
          id: data['id'],
          name: data['name'],
          email: '',
          profilePic: data['image'],
          uuid: '',
          verified: false,
        )).toList();
      });
    }
  }

  void _createRoom() async {
    if (_roomNameController.text.trim().isEmpty) {
      _showError('Please enter room name');
      return;
    }
    
    if (_selectedFriends.isEmpty) {
      _showError('Please add at least one friend');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final memberIds = _selectedFriends.map((f) => f.id).toList();
      
      final response = await _apiService.createRoom(
        name: _roomNameController.text.trim(),
        description: _descriptionController.text.trim(),
        memberIds: memberIds,
        color: _selectedColor,
        icon: _selectedIcon,
      );

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Room "${_roomNameController.text}" created successfully!'),
            backgroundColor: const Color(0xFF00D09E),
          ),
        );
        Navigator.pop(context, true); // Return true to refresh previous page
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _removeFriend(String friendId) {
    setState(() {
      _selectedFriends.removeWhere((friend) => friend.id == friendId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / 390;

    return Scaffold(
      backgroundColor: const Color(0xFF00D09E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Create Room",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20 * scale,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20 * scale, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 10 * scale),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        padding: EdgeInsets.all(25 * scale),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Room Name
                    Text("Room Name", style: GoogleFonts.poppins(fontSize: 16 * scale, fontWeight: FontWeight.w600)),
                    SizedBox(height: 10 * scale),
                    TextField(
                      controller: _roomNameController,
                      decoration: InputDecoration(
                        hintText: "e.g. Murree Trip, Flatmates",
                        filled: true,
                        fillColor: const Color(0xFFF5F6FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15 * scale),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 15 * scale, vertical: 15 * scale),
                      ),
                    ),
                    SizedBox(height: 20 * scale),

                    // Description (Optional)
                    Text("Description (Optional)", style: GoogleFonts.poppins(fontSize: 16 * scale, fontWeight: FontWeight.w600)),
                    SizedBox(height: 10 * scale),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: "Add room details...",
                        filled: true,
                        fillColor: const Color(0xFFF5F6FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15 * scale),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 15 * scale, vertical: 15 * scale),
                      ),
                    ),
                    SizedBox(height: 20 * scale),

                    // Color Picker
                    Text("Room Color", style: GoogleFonts.poppins(fontSize: 16 * scale, fontWeight: FontWeight.w600)),
                    SizedBox(height: 10 * scale),
                    Wrap(
                      spacing: 10,
                      children: _colors.map((color) {
                        final isSelected = _selectedColor == color;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = color),
                          child: Container(
                            width: 40 * scale,
                            height: 40 * scale,
                            decoration: BoxDecoration(
                              color: Color(int.parse(color.substring(1), radix: 16) + 0xFF000000),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.black : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20 * scale),

                    // Icon Picker
                    Text("Room Icon", style: GoogleFonts.poppins(fontSize: 16 * scale, fontWeight: FontWeight.w600)),
                    SizedBox(height: 10 * scale),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _icons.map((icon) {
                        final isSelected = _selectedIcon == icon;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedIcon = icon),
                          child: Container(
                            width: 50 * scale,
                            height: 50 * scale,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFE6F8F0) : const Color(0xFFF5F6FA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF00D09E) : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(child: Text(icon, style: TextStyle(fontSize: 24 * scale))),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 25 * scale),

                    // Members Header + Add Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Members (${_selectedFriends.length})",
                          style: GoogleFonts.poppins(fontSize: 16 * scale, fontWeight: FontWeight.w600),
                        ),
                        GestureDetector(
                          onTap: _navigateToSelectFriends,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F8F0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.add_circle, color: const Color(0xFF00D09E), size: 16 * scale),
                                SizedBox(width: 5 * scale),
                                Text(
                                  "Add Friend",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12 * scale,
                                    color: const Color(0xFF00D09E),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15 * scale),

                    if (_selectedFriends.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20 * scale),
                          child: Text("No friends added yet", style: GoogleFonts.poppins(color: Colors.grey)),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: _selectedFriends.map((friend) {
                          return Chip(
                            avatar: CircleAvatar(
                              backgroundImage: friend.profilePic != null && friend.profilePic!.startsWith('http')
                                  ? NetworkImage(friend.profilePic!)
                                  : const AssetImage('assets/profile.jpg') as ImageProvider,
                            ),
                            label: Text(friend.name),
                            deleteIcon: Icon(Icons.close, size: 16 * scale),
                            onDeleted: () => _removeFriend(friend.id),
                            backgroundColor: const Color(0xFFE6F8F0),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),

            // Create Button
            SizedBox(height: 20 * scale),
            SizedBox(
              width: double.infinity,
              height: 50 * scale,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D09E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25 * scale)),
                  disabledBackgroundColor: Colors.grey,
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 20 * scale,
                        height: 20 * scale,
                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        "Create Room",
                        style: GoogleFonts.poppins(fontSize: 16 * scale, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}