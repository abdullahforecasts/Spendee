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
import '../services/api_service.dart';
import 'room_members_page.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key});

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _rooms = [];
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final response = await _apiService.getMyRooms();
      print('Raw API response: $response'); // Add this debug print

      // The response should already be a List from getMyRooms()
      // But let's handle it safely
      List<dynamic> list = [];

      list = response is List ? response : [];

      print('Processed list length: ${list.length}'); // Debug print

      setState(() {
        _rooms = list.map<Map<String, dynamic>>((r) {
          print('Processing room: ${r['name']}'); // Debug print
          print('Room createdBy: ${r['createdBy']}'); // Debug print
          print('Room color: ${r['color']}'); // Debug print
          print('Room icon: ${r['icon']}'); // Debug print

          final name = r['name'] ?? 'Unnamed Room';

          // Get members count
          int membersCount = 0;
          if (r['members'] is List) {
            membersCount = (r['members'] as List).length;
          }

          // Get creator name
          String creator = 'Unknown';
          final createdBy = r['createdBy'];
          if (createdBy is Map) {
            creator = createdBy['name']?.toString() ?? 'Unknown';
          }

          // Get color and icon
          final color = r['color']?.toString() ?? '#3B82F6';
          final icon = r['icon']?.toString() ?? '👥';

          return {
            'id': r['_id']?.toString() ?? '',
            'name': name,
            'members': membersCount,
            'creator': creator,
            'color': color,
            'icon': icon,
          };
        }).toList();

        print('Final rooms list: $_rooms'); // Debug print
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading rooms: $e'); // Debug print
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> refreshData() async {
    await _loadRooms();
  }

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

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_error.isNotEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Text(
                          _error,
                          style: GoogleFonts.poppins(color: Colors.red),
                        ),
                      ),
                    )
                  else if (_rooms.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Text(
                          "No rooms created yet",
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ..._rooms
                        .map(
                          (room) => _buildRoomCard(
                            context,
                            room['name'],
                            room['members'],
                            room['creator'],
                            scale,
                            roomId: room['id'],
                            color: room['color'],
                            icon: room['icon'],
                          ),
                        )
                        .toList(),

                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomCard(
    BuildContext context,
    String name,
    int members,
    String creator,
    double scale, {
    String? roomId,
    String? color,
    String? icon,
  }) {
    print(
      'Building card: name=$name, creator=$creator, color=$color, icon=$icon',
    );

    Color? roomColor;
    if (color != null) {
      try {
        String hexColor = color.toString().toUpperCase().replaceAll('#', '');
        // If the stored value is a named color or invalid, fallback will apply
        if (hexColor.length == 6) {
          hexColor = 'FF$hexColor';
        } else if (hexColor.length == 8) {
          // already ARGB
        } else {
          throw Exception('Invalid hex length');
        }
        final colorValue = int.parse(hexColor, radix: 16);
        roomColor = Color(colorValue);
        print('Parsed color: $roomColor from hex $hexColor');
      } catch (e) {
        print('Error parsing color $color: $e');
        roomColor = const Color(0xFFE6F8F0);
      }
    }
    roomColor ??= const Color(0xFFE6F8F0);

    String roomIcon = (icon ?? '👥').toString();
    print('Using icon: $roomIcon');

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoomMembersPage(roomName: name, roomId: roomId),
          ),
        );
        if (result == true) {
          // Room was changed (deleted or updated) — refresh list
          await refreshData();
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 15 * scale), // Use scale here
        padding: EdgeInsets.all(15 * scale), // Use scale here
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15 * scale), // Use scale here
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10 * scale, // Use scale here
              offset: Offset(0, 5 * scale), // Use scale here
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon Container with proper scaling
            Container(
              width: 60 * scale, // Use scale
              height: 60 * scale, // Use scale
              decoration: BoxDecoration(
                color: roomColor!.withOpacity(
                  0.6,
                ), // Increased opacity for better visibility
                borderRadius: BorderRadius.circular(15 * scale), // Use scale
              ),
              child: Center(
                child: Text(
                  roomIcon,
                  style: TextStyle(fontSize: 30 * scale, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(width: 15 * scale), // Use scale
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 18 * scale, // Use scale
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "$members Members • by $creator",
                    style: GoogleFonts.poppins(
                      fontSize: 13 * scale, // Use scale
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16 * scale, // Use scale
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
