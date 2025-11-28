import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectRoomsPage extends StatefulWidget {
  final List<Map<String, dynamic>>? initialSelectedRooms;
  const SelectRoomsPage({super.key, this.initialSelectedRooms});

  @override
  State<SelectRoomsPage> createState() => _SelectRoomsPageState();
}

class _SelectRoomsPageState extends State<SelectRoomsPage> {
  final List<Map<String, dynamic>> _allRooms = [
    {'id': '1', 'name': 'Murree Trip Room', 'members': 10, 'creator': 'Ali Maqsood', 'selected': false},
    {'id': '2', 'name': 'University Friends', 'members': 8, 'creator': 'Abdullah', 'selected': false},
    {'id': '3', 'name': 'Office Pool', 'members': 5, 'creator': 'Anas', 'selected': false},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialSelectedRooms != null) {
      for (var initial in widget.initialSelectedRooms!) {
        for (var room in _allRooms) {
          if (room['id'] == initial['id']) {
            room['selected'] = true;
          }
        }
      }
    }
  }

  void _toggleRoomSelection(int index) {
    setState(() {
      _allRooms[index]['selected'] = !_allRooms[index]['selected'];
    });
  }

  void _saveSelection() {
    List<Map<String, dynamic>> selected = _allRooms
        .where((room) => room['selected'] == true)
        .map((room) => Map<String, dynamic>.from(room))
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
          "Select Rooms",
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
        // Removed top-right check button
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
                itemCount: _allRooms.length,
                itemBuilder: (context, index) {
                  return _buildRoomItem(_allRooms[index], index, scale);
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

  Widget _buildRoomItem(Map<String, dynamic> room, int index, double scale) {
    return Container(
      margin: EdgeInsets.only(bottom: 10 * scale),
      decoration: BoxDecoration(
        color: room['selected'] ? const Color(0xFFE6F8F0) : Colors.white,
        borderRadius: BorderRadius.circular(15 * scale),
        border: Border.all(
          color: room['selected'] ? const Color(0xFF00D09E) : Colors.grey.shade300,
          width: room['selected'] ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: () => _toggleRoomSelection(index),
        leading: Container(
          width: 40 * scale,
          height: 40 * scale,
          decoration: const BoxDecoration(
            color: Color(0xFF00D09E),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.meeting_room, color: Colors.white, size: 20 * scale),
        ),
        title: Text(
          room['name'],
          style: GoogleFonts.poppins(
            fontSize: 16 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          "${room['members']} members • by ${room['creator']}",
          style: GoogleFonts.poppins(
            fontSize: 12 * scale,
            color: Colors.grey,
          ),
        ),
        trailing: Checkbox(
          value: room['selected'],
          activeColor: const Color(0xFF00D09E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (value) => _toggleRoomSelection(index),
        ),
      ),
    );
  }
}