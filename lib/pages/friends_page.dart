// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class FriendsPage extends StatelessWidget {
//   const FriendsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF00D09E),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF00D09E),
//         elevation: 0,
//         title: Text("Friends", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
//             _buildFriend("Ali Maqsood"),
//             _buildFriend("Anas Faisal"),
//             _buildFriend("Abdullah"),
//             _buildFriend("Israr Hussain"),
//             _buildFriend("Hassan Ali"),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFriend(String name) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: const Color(0xFF00D09E),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           const CircleAvatar(
//             backgroundImage: AssetImage('assets/profile.jpg'),
//             radius: 22,
//           ),
//           const SizedBox(width: 15),
//           Text(
//             name,
//             style: GoogleFonts.poppins(
//               color: Colors.white,
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



//ye wala page israr ka hai
//check if u like it 

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spendee/pages/my_profile.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final TextEditingController _searchController = TextEditingController();

  // master list (keeps all friends) and displayed list (filtered)
  final List<Map<String, dynamic>> allFriends = [
    {'name': 'Sharukh the Great Saver', 'image': 'assets/profile.jpg'},
    {'name': 'Israr Smexy', 'image': 'assets/profile.jpg'},
    {'name': 'Anas Goat', 'image': 'assets/profile.jpg'},
    {'name': 'Abdullah the Meat Rider', 'image': 'assets/profile.jpg'},
    {'name': 'Ali (GDG head)', 'image': 'assets/profile.jpg'},
  ];
  late List<Map<String, dynamic>> friends;

  @override
  void initState() {
    super.initState();
    friends = List<Map<String, dynamic>>.from(allFriends);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFriends(String query) {
    if (query.trim().isEmpty) {
      setState(() => friends = List<Map<String, dynamic>>.from(allFriends));
      return;
    }

    final q = query.toLowerCase();
    setState(() {
      friends = allFriends
          .where((f) => (f['name'] as String).toLowerCase().contains(q))
          .toList();
    });
  }

  void _removeFriendAt(int index) {
    final removed = friends[index]['name'] as String;

    // remove from master list and displayed list
    setState(() {
      allFriends.removeWhere((f) => f['name'] == removed);
      friends.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / 390; // reference width

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
            fontSize: 25 * scale.clamp(0.8, 1.2),
          ),
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 14 * scale,
              child: Icon(Icons.person, color: Colors.black, size: 18 * scale),
            ),
            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                '/my-profile',
                              );

                            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black, size: 22 * scale),
            onPressed: () {
              // TODO: Handle top-right menu options
            },
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFE6F8F0),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(60),
              topRight: Radius.circular(60),
            ),
          ),
          child: Stack(
            children: [
              // Scrollable content (leave space for fixed Add button)
              Positioned.fill(
                bottom: 100 * scale, // leave a bit more space so button isn't too low
                child: Padding(
                  padding: EdgeInsets.all(20 * scale),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 15 * scale),

                        // Title text (replaces the 3-button row)
                        Text(
                          "Your Friends",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 20 * scale,
                            color: Colors.black,
                          ),
                        ),

                        SizedBox(height: 20 * scale),

                        // Search Field
                        TextField(
                          controller: _searchController,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 15 * scale,
                          ),
                          decoration: InputDecoration(
                            hintText: "Search friend...",
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w400,
                              fontSize: 14 * scale,
                            ),
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                              icon: Icon(Icons.clear, size: 20 * scale),
                              onPressed: () {
                                _searchController.clear();
                                _filterFriends('');
                              },
                            )
                                : null,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 16 * scale,
                              horizontal: 16 * scale,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30 * scale),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: _filterFriends,
                        ),

                        SizedBox(height: 25 * scale),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Friends List",
                            style: GoogleFonts.poppins(
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        SizedBox(height: 10 * scale),

                        // Friends List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: friends.length,
                          itemBuilder: (context, index) {
                            final friend = friends[index];
                            return _buildFriendTile(friend, index, scale);
                          },
                        ),

                        if (friends.isEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 40 * scale),
                            child: Text(
                              "No friends in the list..",
                              style: GoogleFonts.poppins(
                                fontSize: 15 * scale,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),

                        SizedBox(height: 100 * scale),
                      ],
                    ),
                  ),
                ),
              ),

              // Fixed Add Button (moved up a bit)
              Positioned(
                left: 0,
                right: 0,
                bottom: 35 * scale, // moved up from previous position
                child: Center(
                  child: SizedBox(
                    // use a wider button with icon + text
                    width: 160 * scale,
                    height: 52 * scale,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Open Add Friend page or show add friend modal
                      },
                      icon: Icon(Icons.person_add, size: 20 * scale),
                      label: Text(
                        "Add",
                        style: GoogleFonts.poppins(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D09E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14 * scale),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ---------- Friend Tile ----------
  Widget _buildFriendTile(Map<String, dynamic> friend, int index, double scale) {
    String name = friend['name'] as String;
    if (name.length > 18) name = "${name.substring(0, 15)}...";

    return Container(
      margin: EdgeInsets.only(bottom: 12 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF00D09E),
        borderRadius: BorderRadius.circular(15 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 3 * scale),
          )
        ],
      ),
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            // TODO: Navigate to friend's profile page
          },
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 20 * scale,
            backgroundImage: AssetImage(friend['image']),
          ),
        ),
        title: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 14 * scale,
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.white, size: 20 * scale),
          onSelected: (value) {
            if (value == 'remove') {
              _confirmRemoveFriend(name, index);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'remove',
              child: Text('Remove from list?'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Remove Confirmation ----------
  void _confirmRemoveFriend(String name, int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Remove $name?",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("No", style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              _removeFriendAt(index);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D09E),
            ),
            child: Text("Yes", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}