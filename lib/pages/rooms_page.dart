import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'room_members_page.dart';

class RoomsPage extends StatelessWidget {
  const RoomsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00D09E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        title: Text("Rooms", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFE6F8F0),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(60),
            topRight: Radius.circular(60),
          ),
        ),
        padding: const EdgeInsets.all(25),
        child: ListView(
          children: [
            _buildRoomCard(context, "Murree Trip Room", 10, "Ali Maqsood"),
            _buildRoomCard(context, "University Mess", 8, "Abdullah"),
            _buildRoomCard(context, "Office Pool", 5, "Anas"),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, String name, int members, String creator) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RoomMembersPage()),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFD9F5E9),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                Text("$members Members • by $creator",
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54)),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
