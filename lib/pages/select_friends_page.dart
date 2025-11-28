import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectFriendsPage extends StatefulWidget {
  final List<Map<String, dynamic>>? initialSelectedFriends;
  const SelectFriendsPage({super.key, this.initialSelectedFriends});

  @override
  State<SelectFriendsPage> createState() => _SelectFriendsPageState();
}

class _SelectFriendsPageState extends State<SelectFriendsPage> {
  // Hardcoded database
  final List<Map<String, dynamic>> _allFriends = [
    {'id': '1', 'name': 'Ali Maqsood', 'selected': false, 'image': 'assets/profile.jpg'},
    {'id': '2', 'name': 'Abdullah', 'selected': false, 'image': 'assets/profile.jpg'},
    {'id': '3', 'name': 'Anas Faisal', 'selected': false, 'image': 'assets/profile.jpg'},
    {'id': '4', 'name': 'Israr Hussain', 'selected': false, 'image': 'assets/profile.jpg'},
    {'id': '5', 'name': 'Sharukh Khan', 'selected': false, 'image': 'assets/profile.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialSelectedFriends != null) {
      for (var initial in widget.initialSelectedFriends!) {
        for (var friend in _allFriends) {
          if (friend['id'] == initial['id']) {
            friend['selected'] = true;
          }
        }
      }
    }
  }

  void _toggleFriendSelection(int index) {
    setState(() {
      _allFriends[index]['selected'] = !_allFriends[index]['selected'];
    });
  }

  void _saveSelection() {
    List<Map<String, dynamic>> selected = _allFriends
        .where((friend) => friend['selected'] == true)
        .map((friend) => Map<String, dynamic>.from(friend))
        .toList();
    Navigator.pop(context, selected);
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
          "Select Friends",
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
        // Removed top-right check button as requested
      ),
      body: Container(
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
              child: ListView.builder(
                itemCount: _allFriends.length,
                itemBuilder: (context, index) {
                  return _buildFriendItem(_allFriends[index], index, scale);
                },
              ),
            ),

            SizedBox(height: 10 * scale),
            SizedBox(
              width: double.infinity,
              height: 50 * scale,
              child: ElevatedButton(
                onPressed: _saveSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D09E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25 * scale),
                  ),
                ),
                child: Text(
                  "Done",
                  style: GoogleFonts.poppins(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendItem(Map<String, dynamic> friend, int index, double scale) {
    return Container(
      margin: EdgeInsets.only(bottom: 10 * scale),
      decoration: BoxDecoration(
        color: friend['selected'] ? const Color(0xFFE6F8F0) : Colors.white,
        borderRadius: BorderRadius.circular(15 * scale),
        border: Border.all(
          color: friend['selected'] ? const Color(0xFF00D09E) : Colors.grey.shade300,
          width: friend['selected'] ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: () => _toggleFriendSelection(index),
        leading: CircleAvatar(
          radius: 20 * scale,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: AssetImage(friend['image']),
        ),
        title: Text(
          friend['name'],
          style: GoogleFonts.poppins(
            fontSize: 16 * scale,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Checkbox(
          value: friend['selected'],
          activeColor: const Color(0xFF00D09E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (value) => _toggleFriendSelection(index),
        ),
      ),
    );
  }
}