// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'room_members_page.dart';
//
// class RoomsPage extends StatelessWidget {
//   const RoomsPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF00D09E),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF00D09E),
//         elevation: 0,
//         title: Text("Rooms", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           color: Color(0xFFE6F8F0),
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(60),
//             topRight: Radius.circular(60),
//           ),
//         ),
//         padding: const EdgeInsets.all(25),
//         child: ListView(
//           children: [
//             _buildRoomCard(context, "Murree Trip Room", 10, "Ali Maqsood"),
//             _buildRoomCard(context, "University Mess", 8, "Abdullah"),
//             _buildRoomCard(context, "Office Pool", 5, "Anas"),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildRoomCard(BuildContext context, String name, int members, String creator) {
//     return GestureDetector(
//       onTap: () => Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => const RoomMembersPage()),
//       ),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 15),
//         padding: const EdgeInsets.all(15),
//         decoration: BoxDecoration(
//           color: const Color(0xFFD9F5E9),
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(name,
//                     style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
//                 Text("$members Members • by $creator",
//                     style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54)),
//               ],
//             ),
//             const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
//           ],
//         ),
//       ),
//     );
//   }
// }


// rooms_page.dart (Updated)


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'room_members_page.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key});

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  final List<Map<String, dynamic>> _rooms = [
    {'name': 'Murree Trip Room', 'members': 10, 'creator': 'Ali Maqsood'},
    {'name': 'University Mess', 'members': 8, 'creator': 'Abdullah'},
    {'name': 'Office Pool', 'members': 5, 'creator': 'Anas'},
    {'name': 'Weekend Gang', 'members': 6, 'creator': 'Israr'},
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / 390;

    // NO SCAFFOLD - Uses Parent Scaffold
    return Stack(
      children: [
        // Green Background
        Container(color: const Color(0xFF00D09E)),

        // White Sheet Content
        Positioned.fill(
          top: 0,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFE6F8F0),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(60),
                topRight: Radius.circular(60),
              ),
            ),
            margin: const EdgeInsets.only(top: 0),
            padding: const EdgeInsets.all(25),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Rooms",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (_rooms.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Text("No rooms created yet", style: GoogleFonts.poppins(color: Colors.grey)),
                      ),
                    )
                  else
                    ..._rooms.map((room) => _buildRoomCard(
                      context,
                      room['name'],
                      room['members'],
                      room['creator'],
                      scale,
                    )).toList(),

                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomCard(BuildContext context, String name, int members, String creator, double scale) {
    return GestureDetector(
      // Navigate to Specific Room Page
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RoomMembersPage(roomName: name)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F8F0),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.meeting_room, color: Color(0xFF00D09E), size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "$members Members • by $creator",
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}