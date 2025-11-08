import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupCreationPage extends StatefulWidget {
  const GroupCreationPage({Key? key}) : super(key: key);

  @override
  State<GroupCreationPage> createState() => _GroupCreationPageState();
}

class _GroupCreationPageState extends State<GroupCreationPage> {
  double? amount;
  int? days;
  final TextEditingController _groupNameController = TextEditingController();

  List<Map<String, dynamic>> members = [
    {'name': 'Sharukh the Great Saver', 'image': 'assets/profile_placeholder.png'},
    {'name': 'Sharukh', 'image': 'assets/profile_placeholder.png'},
  ];

  @override
  Widget build(BuildContext context) {
    // Screen size helpers
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final scale = screenWidth / 390; // reference width = iPhone 12 width ~390

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
              // TODO: Navigate to profile page
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
      body: LayoutBuilder(
        builder: (context, constraints) {
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
                // Scrollable content
                Positioned.fill(
                  bottom: 80 * scale,
                  child: Padding(
                    padding: EdgeInsets.all(20 * scale),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 10 * scale),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildActionButton(
                                icon: Icons.attach_money,
                                label: amount != null ? "✓" : "Set Amount",
                                onPressed: () => _showInputDialog(
                                  title: "Enter Amount",
                                  hint: "Amount > 0",
                                  isAmount: true,
                                ),
                                scale: scale,
                              ),
                              _buildActionButton(
                                icon: Icons.calendar_today,
                                label: days != null ? "✓" : "Set Timeframe",
                                onPressed: () => _showInputDialog(
                                  title: "Enter Number of Days",
                                  hint: "Days > 0",
                                  isAmount: false,
                                ),
                                scale: scale,
                              ),
                              _buildActionButton(
                                icon: Icons.person_add_alt_1,
                                label: "Add Friend",
                                onPressed: () {
                                  // TODO: Navigate to Add Friend Page
                                },
                                scale: scale,
                              ),
                            ],
                          ),
                          SizedBox(height: 25 * scale),
                          TextField(
                            controller: _groupNameController,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 15 * scale),
                            decoration: InputDecoration(
                              hintText: "Group Name",
                              hintStyle: GoogleFonts.poppins(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14 * scale),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 18 * scale),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20 * scale),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          SizedBox(height: 25 * scale),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Members Added",
                                style: GoogleFonts.poppins(
                                    fontSize: 16 * scale,
                                    fontWeight: FontWeight.w600)),
                          ),
                          SizedBox(height: 10 * scale),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: members.length,
                            itemBuilder: (context, index) {
                              final member = members[index];
                              return _buildMemberTile(member, index, scale);
                            },
                          ),
                          SizedBox(height: 100 * scale),
                        ],
                      ),
                    ),
                  ),
                ),

                // Fixed Launch Button
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 25 * scale,
                  child: Center(
                    child: SizedBox(
                      width: 150 * scale,
                      height: 50 * scale,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Handle group creation logic
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D09E),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(15 * scale),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          "Launch",
                          style: GoogleFonts.poppins(
                            fontSize: 18 * scale,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------- Widgets ----------

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required double scale,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20 * scale),
          child: Container(
            width: 70 * scale,
            height: 70 * scale,
            decoration: BoxDecoration(
              color: const Color(0xFF00D09E),
              borderRadius: BorderRadius.circular(20 * scale),
            ),
            child: Icon(icon, color: Colors.white, size: 30 * scale),
          ),
        ),
        SizedBox(height: 8 * scale),
        Text(
          label,
          style: GoogleFonts.poppins(
              fontSize: 13 * scale, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildMemberTile(Map<String, dynamic> member, int index, double scale) {
    // Trim long names safely
    String name = member['name'];
    if (name.length > 15) name = "${name.substring(0, 12)}...";

    return Container(
      margin: EdgeInsets.only(bottom: 12 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF00D09E),
        borderRadius: BorderRadius.circular(15 * scale),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: Offset(0, 3 * scale))
        ],
      ),
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            // TODO: Navigate to member profile page
          },
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 20 * scale,
            child: Icon(Icons.person, color: Colors.black, size: 20 * scale),
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
              _confirmRemoveMember(member['name'], index);
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

  // ---------- Helpers ----------

  void _showInputDialog({
    required String title,
    required String hint,
    required bool isAmount,
  }) {
    final TextEditingController inputController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: TextField(
          controller: inputController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFE6F8F0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(inputController.text);
              if (value == null || value <= 0) return;
              setState(() {
                if (isAmount) {
                  amount = value;
                } else {
                  days = value.toInt();
                }
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D09E),
            ),
            child: Text("OK", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveMember(String name, int index) {
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
              setState(() => members.removeAt(index));
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