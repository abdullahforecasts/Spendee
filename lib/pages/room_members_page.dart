// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// class RoomMembersPage extends StatelessWidget {
//   const RoomMembersPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF00D09E),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF00D09E),
//         elevation: 0,
//         title: Text("Spendee", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
//       ),
//       body: Container(
//         width: double.infinity,
//         decoration: const BoxDecoration(
//           color: Color(0xFFE6F8F0),
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(60),
//             topRight: Radius.circular(60),
//           ),
//         ),
//         padding: const EdgeInsets.all(25),
//         child: Column(
//           children: [
//             const SizedBox(height: 10),
//             Text("Room Name",
//                 style: GoogleFonts.poppins(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   shadows: [
//                     Shadow(
//                       color: Colors.black.withOpacity(0.4),
//                       offset: const Offset(2, 2),
//                       blurRadius: 2,
//                     ),
//                   ],
//                 )),
//             const SizedBox(height: 5),
//             Text("Total Members: 5",
//                 style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54)),
//             const SizedBox(height: 25),
//             _buildMember("Anas Faisal"),
//             _buildMember("Abdullah"),
//             _buildMember("Israr Hussain"),
//             _buildMember("Alia Bhatt"),
//             _buildMember("Sharukh"),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMember(String name) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       decoration: BoxDecoration(
//         color: const Color(0xFF00D09E),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               const CircleAvatar(
//                 backgroundImage: AssetImage('assets/profile.jpg'),
//                 radius: 20,
//               ),
//               const SizedBox(width: 10),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(name,
//                       style: GoogleFonts.poppins(
//                           color: Colors.white,
//                           fontSize: 15,
//                           fontWeight: FontWeight.w600)),
//                   Text(
//                     "Member since 10/2/2025",
//                     style: GoogleFonts.poppins(
//                       color: Colors.white70,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           const Icon(Icons.more_vert, color: Colors.white),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'others_profile.dart';
import 'select_friends_page.dart';

class RoomMembersPage extends StatefulWidget {
  final String roomName;
  const RoomMembersPage({super.key, this.roomName = "Murree Trip Room"});

  @override
  State<RoomMembersPage> createState() => _RoomMembersPageState();
}

class _RoomMembersPageState extends State<RoomMembersPage> {
  // --- STATE: Toggle for testing Leader view ---
  final bool _isCurrentUserLeader = true;

  final List<Map<String, dynamic>> _members = [
    {'name': 'Ali Maqsood', 'role': 'leader', 'image': 'assets/profile.jpg'},
    {'name': 'Abdullah', 'role': 'member', 'image': 'assets/profile.jpg'},
    {'name': 'Anas Faisal', 'role': 'member', 'image': 'assets/profile.jpg'},
    {'name': 'Israr Hussain', 'role': 'member', 'image': 'assets/profile.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    _sortMembers();
  }

  void _sortMembers() {
    _members.sort((a, b) {
      if (a['role'] == 'leader') return -1;
      if (b['role'] == 'leader') return 1;
      return 0;
    });
  }

  void _removeMember(int index) {
    setState(() {
      _members.removeAt(index);
    });
  }

  void _navigateToAddFriends() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SelectFriendsPage()),
    );

    if (result != null && result is List<Map<String, dynamic>>) {
      setState(() {
        for (var newFriend in result) {
          bool exists = _members.any((m) => m['name'] == newFriend['name']);
          if (!exists) {
            _members.add({
              'name': newFriend['name'],
              'role': 'member',
              'image': newFriend['image'] ?? 'assets/profile.jpg',
            });
          }
        }
        _sortMembers();
      });
    }
  }

  void _confirmDeleteRoom() {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Delete Room?", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Text("Are you sure you want to delete '${widget.roomName}'? This cannot be undone.", style: GoogleFonts.poppins()),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey))
            ),
            ElevatedButton(
                onPressed: () {
                  // Backend logic here (TOIMPLEMENT)
                  Navigator.pop(ctx); // Close Dialog
                  Navigator.pop(context); // Close Page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Room deleted successfully")),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: Text("Delete", style: GoogleFonts.poppins(color: Colors.white))
            ),
          ],
        )
    );
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
          "Spendee",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 25 * scale,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // DELETE ROOM OPTION (Leader Only)
          if (_isCurrentUserLeader)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'delete') {
                  _confirmDeleteRoom();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 10),
                      Text("Delete Room", style: GoogleFonts.poppins(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          SizedBox(width: 10 * scale),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20 * scale, horizontal: 25 * scale),
            child: Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(15 * scale),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.meeting_room, color: Colors.white, size: 40 * scale),
                  ),
                  SizedBox(height: 10 * scale),
                  Text(
                    widget.roomName,
                    style: GoogleFonts.poppins(
                      fontSize: 24 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "${_members.length} Members",
                    style: GoogleFonts.poppins(
                      fontSize: 14 * scale,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFE6F8F0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              padding: EdgeInsets.all(25 * scale),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Room Members",
                        style: GoogleFonts.poppins(
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_isCurrentUserLeader)
                        GestureDetector(
                          onTap: _navigateToAddFriends,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00D09E),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.person_add, color: Colors.white, size: 16 * scale),
                                SizedBox(width: 5 * scale),
                                Text(
                                  "Add",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12 * scale,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 15 * scale),

                  Expanded(
                    child: ListView.builder(
                      itemCount: _members.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return _buildMemberTile(_members[index], index, scale);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTile(Map<String, dynamic> member, int index, double scale) {
    bool isLeader = member['role'] == 'leader';

    return Container(
      margin: EdgeInsets.only(bottom: 12 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OthersProfileViewPage()),
            );
          },
          child: CircleAvatar(
            backgroundImage: AssetImage(member['image']),
            radius: 24 * scale,
          ),
        ),
        title: Text(
          member['name'],
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16 * scale,
          ),
        ),
        subtitle: isLeader
            ? Text(
          "Leader",
          style: GoogleFonts.poppins(
            fontSize: 12 * scale,
            color: const Color(0xFF00D09E),
            fontWeight: FontWeight.w600,
          ),
        )
            : null,

        trailing: (_isCurrentUserLeader && !isLeader)
            ? PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey, size: 20 * scale),
          onSelected: (value) {
            if (value == 'remove') {
              _removeMember(index);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'remove',
              child: Text("Remove from list?", style: GoogleFonts.poppins()),
            ),
          ],
        )
            : null,
      ),
    );
  }
}