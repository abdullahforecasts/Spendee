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
import '../services/api_service.dart';
import 'others_profile.dart';
import 'select_friends_page.dart';

class RoomMembersPage extends StatefulWidget {
  final String roomName;
  final String? roomId;
  const RoomMembersPage({
    super.key,
    this.roomName = "Murree Trip Room",
    this.roomId,
  });

  @override
  State<RoomMembersPage> createState() => _RoomMembersPageState();
}

class _RoomMembersPageState extends State<RoomMembersPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String _error = '';
  bool _isCurrentUserLeader = false;
  String _roomDisplayName = '';
  String? _roomId;
  String _roomIcon = '👥';
  Color _roomColor = const Color(0xFFE6F8F0);
  String? _currentUserId;

  List<Map<String, dynamic>> _members = [];

  @override
  void initState() {
    super.initState();
    _roomId = widget.roomId;
    _roomDisplayName = widget.roomName;
    if (_roomId != null) {
      _loadRoomDetails();
    } else {
      // fallback to static members for UI while no id provided
      _members = [
        {
          'name': 'Ali Maqsood',
          'role': 'leader',
          'image': 'assets/profile.jpg',
        },
        {'name': 'Abdullah', 'role': 'member', 'image': 'assets/profile.jpg'},
        {
          'name': 'Anas Faisal',
          'role': 'member',
          'image': 'assets/profile.jpg',
        },
        {
          'name': 'Israr Hussain',
          'role': 'member',
          'image': 'assets/profile.jpg',
        },
      ];
      _sortMembers();
    }
  }

  Future<void> _loadRoomDetails() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // fetch current user to determine leader status
      final profile = await _apiService.getProfile();
      final currentUser = profile['user'];
      final currentUserId = currentUser != null
          ? (currentUser['_id'] ?? currentUser['id']?.toString())
          : null;

      final roomData = await _apiService.getRoomDetails(_roomId!);
      // roomData expected to be a Map representing room
      final r = roomData; // defensive alias

      final name = (r['name'] ?? r['title'] ?? widget.roomName).toString();
      final colorStr = r['color']?.toString() ?? '#3B82F6';
      final iconStr = r['icon']?.toString() ?? '👥';
      // backend populates the creator as `createdBy`
      final leader =
          r['createdBy'] ?? r['leader'] ?? r['creator'] ?? r['owner'];
      final leaderId = (leader is Map)
          ? (leader['_id'] ?? leader['id'])
          : leader;

      // store current user id for leave operation
      _currentUserId = currentUserId?.toString();

      List<Map<String, dynamic>> members = [];
      if (r['members'] is List) {
        for (var m in (r['members'] as List)) {
          // member may be a user object or wrapper
          if (m is Map) {
            final user = m['user'] ?? m; // handle {user: {...}} or direct user
            final id = user != null
                ? (user['_id'] ?? user['id']?.toString())
                : null;
            members.add({
              'id': id,
              'name': user != null ? (user['name'] ?? '') : (m['name'] ?? ''),
              'role': (leaderId != null && id != null && id == leaderId)
                  ? 'leader'
                  : 'member',
              'image': user != null
                  ? (user['profilePic'] ?? 'assets/profile.jpg')
                  : 'assets/profile.jpg',
            });
          }
        }
      }

      setState(() {
        _roomDisplayName = name;
        _roomIcon = iconStr;
        _roomColor = _parseColor(colorStr);
        _members = members;
        _isCurrentUserLeader =
            (currentUserId != null &&
            leaderId != null &&
            currentUserId == leaderId);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Color _parseColor(String? color) {
    if (color == null) return const Color(0xFFE6F8F0);
    try {
      String hexColor = color.toString().toUpperCase().replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      } else if (hexColor.length == 8) {
        // already ARGB
      } else {
        throw Exception('Invalid hex length');
      }
      final colorValue = int.parse(hexColor, radix: 16);
      return Color(colorValue);
    } catch (e) {
      print('Error parsing room color $color: $e');
      return const Color(0xFFE6F8F0);
    }
  }

  void _sortMembers() {
    _members.sort((a, b) {
      if (a['role'] == 'leader') return -1;
      if (b['role'] == 'leader') return 1;
      return 0;
    });
  }

  void _removeMember(int index) {
    final member = _members[index];
    final memberId = member['id']?.toString();

    if (_roomId != null && memberId != null) {
      // Confirm removal
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            'Remove member?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Are you sure you want to remove ${member['name']} from this room?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await _api_service_removeMember(memberId);
                  await _loadRoomDetails();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${member['name']} removed')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to remove member: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: Text(
                'Remove',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        _members.removeAt(index);
      });
    }
  }

  Future<void> _api_service_removeMember(String memberId) async {
    // wrapper to call ApiService
    await _api_service_removeMember_impl(memberId);
  }

  Future<void> _api_service_removeMember_impl(String memberId) async {
    await _apiService.removeMemberFromRoom(_roomId!, memberId);
  }

  void _navigateToAddFriends() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SelectFriendsPage(
          initialSelectedFriends: <Map<String, dynamic>>[],
        ),
      ),
    );
    if (result != null && result is List<Map<String, dynamic>>) {
      // If we have a roomId, call backend to add members, else mutate local list
      final selected = result;
      if (_roomId != null) {
        try {
          final memberIds = selected
              .map<String?>((s) => s['id']?.toString())
              .whereType<String>()
              .toList();
          if (memberIds.isNotEmpty) {
            await _apiService.addMembersToRoom(_roomId!, memberIds);
            await _loadRoomDetails();
          }
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to add members: $e')));
        }
      } else {
        setState(() {
          for (var newFriend in selected) {
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
  }

  void _confirmDeleteRoom() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          "Delete Room?",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to delete '${widget.roomName}'? This cannot be undone.",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // Close Dialog
              if (_roomId != null) {
                try {
                  await _apiService.deleteRoom(_roomId!);
                  if (!mounted) return;
                  Navigator.pop(context, true); // Close Page and signal success
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Room deleted successfully")),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete room: $e')),
                  );
                }
              } else {
                // fallback local behavior - close and signal change
                Navigator.pop(context, true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Room deleted successfully")),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(
              "Delete",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLeaveRoom() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          "Leave Room?",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to leave '${_roomDisplayName}'? You will no longer see this room.",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // If we have roomId and currentUserId, call API to remove member
              if (_roomId != null && _currentUserId != null) {
                try {
                  await _apiService.removeMemberFromRoom(
                    _roomId!,
                    _currentUserId!,
                  );
                  if (!mounted) return;
                  // Close the page and signal parent to refresh (user left the room)
                  Navigator.pop(context, true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You left the room')),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to leave room: $e')),
                  );
                }
              } else {
                // local fallback
                Navigator.pop(context, true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('You left the room')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(
              "Leave",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
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
                      const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Delete Room",
                        style: GoogleFonts.poppins(color: Colors.red),
                      ),
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
            padding: EdgeInsets.symmetric(
              vertical: 20 * scale,
              horizontal: 25 * scale,
            ),
            child: Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Container(
                    width: 80 * scale,
                    height: 80 * scale,
                    decoration: BoxDecoration(
                      color: _roomColor.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _roomIcon,
                        style: TextStyle(
                          fontSize: 40 * scale,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(height: 10 * scale),
                  Text(
                    _roomDisplayName,
                    style: GoogleFonts.poppins(
                      fontSize: 24 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  else
                    Text(
                      "${_members.length} Members",
                      style: GoogleFonts.poppins(
                        fontSize: 14 * scale,
                        color: Colors.white70,
                      ),
                    ),
                  SizedBox(height: 8 * scale),
                  if (_isCurrentUserLeader)
                    SizedBox(
                      width: 160 * scale,
                      child: ElevatedButton(
                        onPressed: _confirmDeleteRoom,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12 * scale),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 16 * scale,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8 * scale),
                            Text(
                              'Delete Room',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 13 * scale,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SizedBox(
  width: 160 * scale,
  child: ElevatedButton(
    onPressed: _confirmLeaveRoom,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.redAccent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12 * scale),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.exit_to_app,
          size: 16 * scale,
          color: Colors.white,
        ),
        SizedBox(width: 8 * scale),
        Text(
          'Leave Room',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 13 * scale,
          ),
        ),
      ],
    ),
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
                            padding: EdgeInsets.symmetric(
                              horizontal: 12 * scale,
                              vertical: 6 * scale,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00D09E),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_add,
                                  color: Colors.white,
                                  size: 16 * scale,
                                ),
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
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: _members.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return _buildMemberTile(
                                _members[index],
                                index,
                                scale,
                              );
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

  Widget _buildMemberTile(
    Map<String, dynamic> member,
    int index,
    double scale,
  ) {
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
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * scale,
          vertical: 8 * scale,
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    OthersProfileViewPage(userId: member['id']?.toString()),
              ),
            );
          },
          child: CircleAvatar(
            backgroundImage:
                member['image'] != null &&
                    member['image'].toString().startsWith('http')
                ? NetworkImage(member['image']) as ImageProvider
                : AssetImage(member['image'] ?? 'assets/profile.jpg')
                      as ImageProvider,
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
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _removeMember(index),
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 20 * scale,
                    ),
                    tooltip: 'Remove member',
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
