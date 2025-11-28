import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'select_friends_page.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final TextEditingController _roomNameController = TextEditingController();
  List<Map<String, dynamic>> _selectedFriends = [];

  void _navigateToSelectFriends() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectFriendsPage(initialSelectedFriends: _selectedFriends),
      ),
    );

    if (result != null && result is List<Map<String, dynamic>>) {
      setState(() {
        _selectedFriends = result;
      });
    }
  }

  void _createRoom() {
    if (_roomNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter room name')));
      return;
    }
    if (_selectedFriends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one friend')));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Room "${_roomNameController.text}" created successfully!'),
        backgroundColor: const Color(0xFF00D09E),
      ),
    );
    Navigator.pop(context);
  }

  void _removeFriend(String friendId) {
    setState(() {
      _selectedFriends.removeWhere((friend) => friend['id'] == friendId);
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
                    SizedBox(height: 25 * scale),

                    // Header + Add Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Members (${_selectedFriends.length})",
                          style: GoogleFonts.poppins(fontSize: 16 * scale, fontWeight: FontWeight.w600),
                        ),
                        // Responsive Add Button
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
                            avatar: CircleAvatar(backgroundImage: AssetImage(friend['image'])),
                            label: Text(friend['name']),
                            deleteIcon: Icon(Icons.close, size: 16 * scale),
                            onDeleted: () => _removeFriend(friend['id']),
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
                onPressed: _createRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D09E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25 * scale)),
                ),
                child: Text(
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