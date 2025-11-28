import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input formatters
import 'package:google_fonts/google_fonts.dart';
import 'select_friends_page.dart';
import 'select_rooms_page.dart';

enum DistributionType { equally, custom }

class GroupCreationPage extends StatefulWidget {
  const GroupCreationPage({Key? key}) : super(key: key);

  @override
  State<GroupCreationPage> createState() => _GroupCreationPageState();
}

class _GroupCreationPageState extends State<GroupCreationPage> {
  // Main Controllers
  final TextEditingController _groupNameController = TextEditingController();

  // State Variables
  double _totalAmount = 0.0;
  DistributionType _distributionType = DistributionType.equally;

  // Data Lists
  List<MemberWrapper> _selectedFriends = [];
  List<RoomWrapper> _selectedRooms = [];

  // --- LOGIC: HARDCODED ROOM MEMBERS ---
  List<MemberWrapper> _getHardcodedRoomMembers(String roomId) {
    if (roomId == '1') { // Murree Trip Room
      return [
        MemberWrapper(id: '101', name: 'Ali Maqsood', image: 'assets/profile.jpg'),
        MemberWrapper(id: '102', name: 'Hassan', image: 'assets/profile.jpg'),
        MemberWrapper(id: '103', name: 'Bilal', image: 'assets/profile.jpg'),
      ];
    } else if (roomId == '2') {
      return [
        MemberWrapper(id: '201', name: 'Abdullah', image: 'assets/profile.jpg'),
        MemberWrapper(id: '202', name: 'Sara', image: 'assets/profile.jpg'),
      ];
    }
    return [
      MemberWrapper(id: '901', name: 'User A', image: 'assets/profile.jpg'),
      MemberWrapper(id: '902', name: 'User B', image: 'assets/profile.jpg'),
    ];
  }

  // --- LOGIC: CALCULATIONS ---

  // 1. EQUALLY: User sets Total -> We divide by N
  void _recalculateEqualShares() {
    int totalPeople = _selectedFriends.length;
    for (var room in _selectedRooms) {
      totalPeople += room.members.length;
    }

    if (totalPeople == 0) {
      _totalAmount = 0.0; // Reset total if no one is left
      return;
    }

    if (_totalAmount < 0) _totalAmount = 0;

    double share = _totalAmount / totalPeople;
    String shareText = share.toStringAsFixed(0);

    // Update all UI controllers
    for (var f in _selectedFriends) {
      f.amountController.text = shareText;
    }
    for (var r in _selectedRooms) {
      for (var m in r.members) {
        m.amountController.text = shareText;
      }
    }
    setState(() {});
  }

  // 2. CUSTOM: User sets individuals -> We sum to Total
  void _recalculateTotalFromMembers() {
    double sum = 0.0;

    for (var f in _selectedFriends) {
      double val = double.tryParse(f.amountController.text) ?? 0.0;
      if (val < 0) val = 0;
      sum += val;
    }
    for (var r in _selectedRooms) {
      for (var m in r.members) {
        double val = double.tryParse(m.amountController.text) ?? 0.0;
        if (val < 0) val = 0;
        sum += val;
      }
    }

    setState(() {
      _totalAmount = sum;
    });
  }

  // Toggle Logic
  void _toggleDistributionType() {
    setState(() {
      if (_distributionType == DistributionType.equally) {
        _distributionType = DistributionType.custom;
      } else {
        _distributionType = DistributionType.equally;
        _recalculateEqualShares();
      }
    });
  }

  // --- REMOVAL LOGIC ---
  void _removeIndividualFriend(String id) {
    setState(() {
      _selectedFriends.removeWhere((m) => m.id == id);
      _triggerRecalculation();
    });
  }

  void _removeMemberFromRoom(RoomWrapper room, String memberId) {
    setState(() {
      // 1. Remove member from the room
      room.members.removeWhere((m) => m.id == memberId);

      // 2. If room is now empty, remove the room itself from selected list
      if (room.members.isEmpty) {
        _selectedRooms.removeWhere((r) => r.id == room.id);
      }

      // 3. Recalculate totals
      _triggerRecalculation();
    });
  }

  void _triggerRecalculation() {
    if (_distributionType == DistributionType.equally) {
      _recalculateEqualShares();
    } else {
      _recalculateTotalFromMembers();
    }
  }

  // --- DIALOGS ---

  void _showAmountDialog() {
    if (_distributionType == DistributionType.custom) {
      return; // Do nothing in custom mode
    }

    final TextEditingController inputController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Total Amount", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: TextField(
          controller: inputController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: "Enter amount",
            prefixText: "Rs. ",
            filled: true,
            fillColor: const Color(0xFFF5F6FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(inputController.text);
              if (val != null && val >= 0) {
                setState(() {
                  _totalAmount = val;
                  _recalculateEqualShares();
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D09E)),
            child: Text("Set", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- NAVIGATION ---

  void _navigateToSelectFriends() async {
    List<Map<String, dynamic>> currentSelection = _selectedFriends.map((w) => {
      'id': w.id, 'name': w.name, 'image': w.image
    }).toList();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectFriendsPage(initialSelectedFriends: currentSelection),
      ),
    );

    if (result != null && result is List<Map<String, dynamic>>) {
      setState(() {
        _selectedFriends = result.map((data) => MemberWrapper(
            id: data['id'],
            name: data['name'],
            image: data['image']
        )).toList();

        _triggerRecalculation();
      });
    }
  }

  void _navigateToSelectRooms() async {
    List<Map<String, dynamic>> currentSelection = _selectedRooms.map((r) => {
      'id': r.id, 'name': r.name,
    }).toList();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectRoomsPage(initialSelectedRooms: currentSelection),
      ),
    );

    if (result != null && result is List<Map<String, dynamic>>) {
      setState(() {
        _selectedRooms = result.map((data) {
          List<MemberWrapper> roomMembers = _getHardcodedRoomMembers(data['id']);
          return RoomWrapper(
            id: data['id'],
            name: data['name'],
            members: roomMembers,
          );
        }).toList();

        _triggerRecalculation();
      });
    }
  }

  // --- VALIDATION & CREATE ---
  void _createGroup() {
    // 1. Validate Group Name
    if (_groupNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group name')),
      );
      return;
    }

    // 2. Validate at least one member exists
    if (_selectedFriends.isEmpty && _selectedRooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one friend or room')),
      );
      return;
    }

    // 3. Validate Total Amount
    if (_totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Total amount must be greater than 0')),
      );
      return;
    }

    // 4. Validate Individual Amounts (Specific to Custom Mode)
    if (_distributionType == DistributionType.custom) {
      bool allMembersHaveAmount = true;

      // Check individual friends
      for (var friend in _selectedFriends) {
        double val = double.tryParse(friend.amountController.text) ?? 0.0;
        if (val <= 0) {
          allMembersHaveAmount = false;
          break;
        }
      }

      // Check room members if flag is still true
      if (allMembersHaveAmount) {
        for (var room in _selectedRooms) {
          for (var member in room.members) {
            double val = double.tryParse(member.amountController.text) ?? 0.0;
            if (val <= 0) {
              allMembersHaveAmount = false;
              break;
            }
          }
          if (!allMembersHaveAmount) break;
        }
      }

      if (!allMembersHaveAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please set a valid amount for all members')),
        );
        return;
      }
    }

    // Success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Group Created! Total: Rs. ${_totalAmount.toStringAsFixed(0)}'),
        backgroundColor: const Color(0xFF00D09E),
      ),
    );
    Navigator.pop(context);
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
        title: Text("Create Group",
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 20 * scale,
                color: Colors.white)),
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
        padding: EdgeInsets.fromLTRB(25 * scale, 25 * scale, 25 * scale, 0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Group Name
                    Text("Group Name", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16 * scale)),
                    SizedBox(height: 10 * scale),
                    TextField(
                      controller: _groupNameController,
                      decoration: InputDecoration(
                        hintText: "e.g. Dinner Party",
                        filled: true,
                        fillColor: const Color(0xFFF5F6FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(16 * scale),
                      ),
                    ),
                    SizedBox(height: 25 * scale),

                    // Distribution Switch
                    Text("Distribution Method", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16 * scale)),
                    SizedBox(height: 10 * scale),
                    _buildDistributionSwitch(scale),

                    SizedBox(height: 25 * scale),

                    // Total Amount Card (Flattened)
                    _buildClickableCard(
                      title: "Total Amount",
                      value: "Rs. ${_totalAmount.toStringAsFixed(0)}",
                      icon: Icons.attach_money,
                      scale: scale,
                      isEditable: _distributionType == DistributionType.equally,
                      onTap: _showAmountDialog,
                    ),

                    SizedBox(height: 25 * scale),

                    // Members Header + Add Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Members", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16 * scale)),
                        Row(
                          children: [
                            _buildAddButton("Room", Icons.meeting_room, _navigateToSelectRooms, scale),
                            SizedBox(width: 8 * scale),
                            _buildAddButton("Friend", Icons.person_add, _navigateToSelectFriends, scale),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 15 * scale),

                    if (_selectedFriends.isEmpty && _selectedRooms.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20 * scale),
                          child: Text("No members added yet.", style: GoogleFonts.poppins(color: Colors.grey)),
                        ),
                      ),

                    // 1. Friends List (With Remove Button)
                    ..._selectedFriends.map((member) => _buildMemberTile(member, scale)).toList(),

                    // 2. Rooms List (With Exploded Members & Remove Buttons)
                    ..._selectedRooms.map((room) => _buildRoomTile(room, scale)).toList(),

                    // Extra space for scrolling
                    SizedBox(height: 80 * scale),
                  ],
                ),
              ),
            ),

            // Create Button (Fixed at bottom)
            Container(
              padding: EdgeInsets.only(bottom: 25 * scale),
              child: SizedBox(
                width: double.infinity,
                height: 55 * scale,
                child: ElevatedButton(
                  onPressed: _createGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D09E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15 * scale),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Create Group",
                    style: GoogleFonts.poppins(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildDistributionSwitch(double scale) {
    return Container(
      width: double.infinity,
      height: 50 * scale,
      padding: EdgeInsets.all(4 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(25 * scale),
      ),
      child: Row(
        children: [
          _buildSwitchOption("Equally", DistributionType.equally, scale),
          _buildSwitchOption("Custom", DistributionType.custom, scale),
        ],
      ),
    );
  }

  Widget _buildSwitchOption(String text, DistributionType type, double scale) {
    bool isSelected = _distributionType == type;
    return Expanded(
      child: GestureDetector(
        onTap: _toggleDistributionType,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00D09E) : Colors.transparent,
            borderRadius: BorderRadius.circular(21 * scale),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey,
              fontSize: 14 * scale,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClickableCard({
    required String title,
    required String value,
    required IconData icon,
    required double scale,
    required bool isEditable,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(15 * scale),
        decoration: BoxDecoration(
          color: isEditable ? const Color(0xFFF5F6FA) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15 * scale),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16 * scale, color: isEditable ? const Color(0xFF00D09E) : Colors.grey),
                SizedBox(width: 5 * scale),
                Text(title, style: GoogleFonts.poppins(fontSize: 12 * scale, color: Colors.grey)),
              ],
            ),
            SizedBox(height: 5 * scale),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 18 * scale,
                color: isEditable ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(String label, IconData icon, VoidCallback onTap, double scale) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
        decoration: BoxDecoration(
          color: const Color(0xFFE6F8F0),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00D09E).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14 * scale, color: const Color(0xFF00D09E)),
            SizedBox(width: 4 * scale),
            Text(label, style: GoogleFonts.poppins(fontSize: 12 * scale, color: const Color(0xFF00D09E), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // Individual Friend Tile
  Widget _buildMemberTile(MemberWrapper member, double scale) {
    bool isReadOnly = _distributionType == DistributionType.equally;

    return Container(
      margin: EdgeInsets.only(bottom: 10 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12 * scale),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(member.image),
          radius: 18 * scale,
        ),
        title: Text(member.name, style: GoogleFonts.poppins(fontSize: 14 * scale, fontWeight: FontWeight.w500)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 70 * scale,
              child: TextField(
                controller: member.amountController,
                keyboardType: TextInputType.number,
                readOnly: isReadOnly,
                textAlign: TextAlign.end,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (val) {
                  if (_distributionType == DistributionType.custom) {
                    _recalculateTotalFromMembers();
                  }
                },
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14 * scale,
                    color: isReadOnly ? Colors.grey : const Color(0xFF00D09E)
                ),
                decoration: InputDecoration(
                  hintText: "0",
                  border: InputBorder.none,
                  isDense: true,
                  hintStyle: GoogleFonts.poppins(color: Colors.grey.shade300),
                ),
              ),
            ),
            SizedBox(width: 8 * scale),
            // Individual Remove Button
            IconButton(
              icon: Icon(Icons.close, size: 18 * scale, color: Colors.redAccent),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _removeIndividualFriend(member.id),
            ),
          ],
        ),
      ),
    );
  }

  // Room Tile with members inside
  Widget _buildRoomTile(RoomWrapper room, double scale) {
    bool isReadOnly = _distributionType == DistributionType.equally;

    return Container(
      margin: EdgeInsets.only(bottom: 10 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(15 * scale),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: EdgeInsets.symmetric(horizontal: 10 * scale),
          leading: Container(
            padding: EdgeInsets.all(8 * scale),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.meeting_room, color: const Color(0xFF00D09E), size: 18 * scale),
          ),
          title: Text(
            room.name,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15 * scale),
          ),
          // Remove Whole Room Button
          trailing: IconButton(
            icon: const Icon(Icons.close, size: 20, color: Colors.grey),
            onPressed: () {
              setState(() {
                _selectedRooms.removeWhere((r) => r.id == room.id);
                _triggerRecalculation();
              });
            },
          ),
          children: room.members.map((member) => Container(
            color: Colors.white,
            padding: EdgeInsets.only(left: 10 * scale),
            child: ListTile(
              dense: true,
              leading: CircleAvatar(
                backgroundImage: AssetImage(member.image),
                radius: 14 * scale,
              ),
              title: Text(member.name, style: GoogleFonts.poppins(fontSize: 13 * scale)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 60 * scale,
                    child: TextField(
                      controller: member.amountController,
                      keyboardType: TextInputType.number,
                      readOnly: isReadOnly,
                      textAlign: TextAlign.end,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (val) {
                        if (_distributionType == DistributionType.custom) {
                          _recalculateTotalFromMembers();
                        }
                      },
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13 * scale,
                          color: isReadOnly ? Colors.grey : const Color(0xFF00D09E)
                      ),
                      decoration: InputDecoration(
                        hintText: "0",
                        border: InputBorder.none,
                        isDense: true,
                        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  SizedBox(width: 5 * scale),
                  // Room Member Remove Button
                  IconButton(
                    icon: Icon(Icons.close, size: 16 * scale, color: Colors.redAccent),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _removeMemberFromRoom(room, member.id),
                  ),
                ],
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }
}

// --- HELPER WRAPPER CLASSES ---

class MemberWrapper {
  final String id;
  final String name;
  final String image;
  final TextEditingController amountController;

  MemberWrapper({required this.id, required this.name, required this.image})
      : amountController = TextEditingController();
}

class RoomWrapper {
  final String id;
  final String name;
  final List<MemberWrapper> members;

  RoomWrapper({required this.id, required this.name, required this.members});
}