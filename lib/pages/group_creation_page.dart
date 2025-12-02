// lib/pages/group_creation_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../utils/user_model.dart';
import 'select_friends_page.dart';
import 'select_rooms_page.dart';

enum DistributionType { equally, custom }

class GroupCreationPage extends StatefulWidget {
  const GroupCreationPage({Key? key}) : super(key: key);

  @override
  State<GroupCreationPage> createState() => _GroupCreationPageState();
}

class _GroupCreationPageState extends State<GroupCreationPage> {
  final ApiService _apiService = ApiService();
  String? _currentUserId;
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  double _totalAmount = 0.0;
  DistributionType _distributionType = DistributionType.equally;
  bool _isLoading = false;

  List<MemberWrapper> _selectedFriends = [];
  List<RoomWrapper> _selectedRooms = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final profile = await _apiService.getProfile();
      final currentUser = profile is Map ? (profile['user'] ?? profile) : null;
      final id = currentUser != null
          ? (currentUser['_id'] ?? currentUser['id'] ?? null)
          : null;
      setState(() {
        _currentUserId = id?.toString();
      });
    } catch (_) {
      // ignore errors here; fallback is null
    }
  }

  void _recalculateEqualShares() {
    // Build ordered unique list of members: friends first, then room members
    List<MemberWrapper> ordered = [];
    final seen = <String>{};

    for (var f in _selectedFriends) {
      if (!seen.contains(f.id)) {
        seen.add(f.id);
        ordered.add(f);
      }
    }

    for (var room in _selectedRooms) {
      for (var m in room.members) {
        // skip duplicates and skip the current user (leader)
        if (_currentUserId != null && m.id == _currentUserId) continue;
        if (!seen.contains(m.id)) {
          seen.add(m.id);
          ordered.add(m);
        }
      }
    }

    final totalPeople = ordered.length;
    if (totalPeople == 0) {
      setState(() {
        _totalAmount = 0.0;
      });
      return;
    }

    if (_totalAmount < 0) _totalAmount = 0;

    // Work in integer amounts (rupees). Round total to nearest int.
    final int totalInt = _totalAmount.round();
    final int base = totalInt ~/ totalPeople; // integer division
    int remainder = totalInt - (base * totalPeople); // leftover to distribute

    // Assign base to everyone, and distribute +1 to first `remainder` members
    final assigned = <String, int>{};
    for (int i = 0; i < ordered.length; i++) {
      final id = ordered[i].id;
      assigned[id] = base + (i < remainder ? 1 : 0);
    }

    // Apply to controllers
    for (var f in _selectedFriends) {
      // Skip leader
      if (_currentUserId != null && f.id == _currentUserId) {
        f.setAmount(0);
        continue;
      }
      final v = assigned[f.id] ?? 0;
      f.setAmount(v);
    }
    for (var r in _selectedRooms) {
      for (var m in r.members) {
        // Skip leader
        if (_currentUserId != null && m.id == _currentUserId) {
          m.setAmount(0);
          continue;
        }
        final v = assigned[m.id] ?? 0;
        m.setAmount(v);
      }
    }
    setState(() {});
  }

  void _recalculateTotalFromMembers() {
    double sum = 0.0;

    for (var f in _selectedFriends) {
      double val = double.tryParse(f.amountController.text) ?? 0.0;
      if (val < 0) val = 0;
      sum += val;
      // keep lastKnownAmount in sync for custom adjustments
      f.lastKnownAmount = (val).toInt();
    }
    for (var r in _selectedRooms) {
      for (var m in r.members) {
        double val = double.tryParse(m.amountController.text) ?? 0.0;
        if (val < 0) val = 0;
        sum += val;
        m.lastKnownAmount = (val).toInt();
      }
    }

    setState(() {
      _totalAmount = sum;
    });
  }

  List<MemberWrapper> _getAllMembers() {
    final List<MemberWrapper> all = [];
    for (var f in _selectedFriends) {
      // skip leader
      if (_currentUserId != null && f.id == _currentUserId) continue;
      all.add(f);
    }
    for (var r in _selectedRooms) {
      for (var m in r.members) {
        if (_currentUserId != null && m.id == _currentUserId) continue;
        all.add(m);
      }
    }
    return all;
  }

  void _onCustomAmountChanged(MemberWrapper changed, String newVal) {
    if (_distributionType != DistributionType.custom) return;

    final int newInt = int.tryParse(newVal) ?? 0;
    final int oldInt = changed.lastKnownAmount;
    final int delta =
        newInt - oldInt; // positive => need to subtract from others

    // if no change, nothing to do
    if (delta == 0) return;

    final others = _getAllMembers().where((m) => m.id != changed.id).toList();
    if (others.isEmpty) {
      // No one to take from or give to — revert change and inform user
      changed.setAmount(oldInt);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No other members to adjust')),
      );
      return;
    }

    // Sum of others
    int othersSum = others.fold(0, (s, m) => s + m.lastKnownAmount);

    if (delta > 0) {
      // Need to reduce others by total = delta
      if (delta > othersSum) {
        // Not enough to cover the increase
        changed.setAmount(oldInt);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Not enough amount in others to increase this member',
            ),
          ),
        );
        return;
      }

      int remaining = delta;
      int remainingCount = others.length;
      for (int i = 0; i < others.length; i++) {
        final m = others[i];
        // ceil division to fairly take larger chunks first
        int take = (remaining + remainingCount - 1) ~/ remainingCount;
        int actual = take <= m.lastKnownAmount ? take : m.lastKnownAmount;
        m.setAmount(m.lastKnownAmount - actual);
        remaining -= actual;
        remainingCount -= 1;
        if (remaining <= 0) break;
      }
      if (remaining != 0) {
        // fallback shouldn't happen because delta <= othersSum
        changed.setAmount(oldInt);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Adjustment failed — try smaller value'),
          ),
        );
        return;
      }
      // commit changed
      changed.setAmount(newInt);
    } else {
      // delta < 0 : user reduced this member; distribute (-delta) to others
      int toDistribute = -delta;
      int remaining = toDistribute;
      int remainingCount = others.length;
      for (int i = 0; i < others.length; i++) {
        final m = others[i];
        int give = (remaining + remainingCount - 1) ~/ remainingCount; // ceil
        m.setAmount(m.lastKnownAmount + give);
        remaining -= give;
        remainingCount -= 1;
        if (remaining <= 0) break;
      }
      if (remaining != 0) {
        // shouldn't happen
        changed.setAmount(oldInt);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Adjustment failed — try smaller change'),
          ),
        );
        return;
      }
      changed.setAmount(newInt);
    }

    // Keep totalAmount consistent (should remain the same)
    // recompute lastKnownAmount sum to set _totalAmount precisely
    final int sumInt = _getAllMembers().fold(
      0,
      (s, m) => s + m.lastKnownAmount,
    );
    setState(() {
      _totalAmount = sumInt.toDouble();
    });
  }

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

  void _removeIndividualFriend(String id) {
    setState(() {
      _selectedFriends.removeWhere((m) => m.id == id);
      _triggerRecalculation();
    });
  }

  void _removeMemberFromRoom(RoomWrapper room, String memberId) {
    setState(() {
      room.members.removeWhere((m) => m.id == memberId);
      if (room.members.isEmpty) {
        _selectedRooms.removeWhere((r) => r.id == room.id);
      }
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

  void _showAmountDialog() {
    if (_distributionType == DistributionType.custom) {
      return;
    }

    final TextEditingController inputController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          "Total Amount",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
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
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D09E),
            ),
            child: Text("Set", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _navigateToSelectFriends() async {
    List<Map<String, dynamic>> currentSelection = _selectedFriends
        .map((w) => {'id': w.id, 'name': w.name, 'image': w.profilePic})
        .toList();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SelectFriendsPage(initialSelectedFriends: currentSelection),
      ),
    );

    if (result != null && result is List<Map<String, dynamic>>) {
      setState(() {
        // Map to MemberWrapper and exclude current user (leader) if returned
        final mapped = result
            .map(
              (data) => MemberWrapper(
                id: data['id'],
                name: data['name'],
                profilePic: data['image'],
              ),
            )
            .where((m) => m.id != _currentUserId)
            .toList();

        _selectedFriends = mapped;

        // Remove any duplicates from selected rooms (if a friend was already part of a room)
        final friendIds = _selectedFriends.map((f) => f.id).toSet();
        for (var room in _selectedRooms) {
          room.members.removeWhere(
            (m) => friendIds.contains(m.id) || m.id == _currentUserId,
          );
        }
        // Remove rooms that now have no members after filtering
        _selectedRooms.removeWhere((r) => r.members.isEmpty);

        _triggerRecalculation();
      });
    }
  }

  void _navigateToSelectRooms() async {
    List<Map<String, dynamic>> currentSelection = _selectedRooms
        .map((r) => {'id': r.id, 'name': r.name})
        .toList();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SelectRoomsPage(initialSelectedRooms: currentSelection),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      final rooms = result['rooms'] as List<RoomModel>;
      setState(() {
        // Build selected rooms but avoid duplicating members that are
        // already in _selectedFriends or already added from previous rooms.
        final existingIds = <String>{};
        for (var f in _selectedFriends) {
          existingIds.add(f.id);
        }

        final List<RoomWrapper> mapped = [];
        for (var room in rooms) {
          final List<MemberWrapper> roomMembers = [];
          for (var user in room.members) {
            if (user.id == null) continue;
            // skip current user (leader)
            if (_currentUserId != null && user.id == _currentUserId) continue;
            if (existingIds.contains(user.id)) continue; // skip duplicates
            existingIds.add(user.id);
            roomMembers.add(
              MemberWrapper(
                id: user.id,
                name: user.name,
                profilePic: user.profilePic ?? 'assets/profile.jpg',
              ),
            );
          }
          if (roomMembers.isNotEmpty) {
            mapped.add(
              RoomWrapper(id: room.id, name: room.name, members: roomMembers),
            );
          }
        }
        _selectedRooms = mapped;
        _triggerRecalculation();
      });
    }
  }

  void _createGroup() async {
    if (_groupNameController.text.trim().isEmpty) {
      _showError('Please enter a group name');
      return;
    }

    if (_selectedFriends.isEmpty && _selectedRooms.isEmpty) {
      _showError('Please add at least one friend or room');
      return;
    }

    if (_totalAmount <= 0) {
      _showError('Total amount must be greater than 0');
      return;
    }

    if (_distributionType == DistributionType.custom) {
      bool allMembersHaveAmount = true;

      for (var friend in _selectedFriends) {
        double val = double.tryParse(friend.amountController.text) ?? 0.0;
        if (val <= 0) {
          allMembersHaveAmount = false;
          break;
        }
      }

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
        _showError('Please set a valid amount for all members');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      // Collect all member IDs
      List<String> memberIds = _selectedFriends.map((f) => f.id).toList();
      for (var room in _selectedRooms) {
        memberIds.addAll(room.members.map((m) => m.id));
      }

      // Remove duplicates
      memberIds = memberIds.toSet().toList();

      // Ensure leader (current user) is not part of memberIds
      if (_currentUserId != null) {
        memberIds.removeWhere((id) => id == _currentUserId);
      }

      // Collect custom shares if custom distribution
      List<double>? customShares;
      if (_distributionType == DistributionType.custom) {
        customShares = [];
        for (var f in _selectedFriends) {
          if (_currentUserId != null && f.id == _currentUserId) continue;
          customShares.add(double.parse(f.amountController.text));
        }
        for (var r in _selectedRooms) {
          for (var m in r.members) {
            if (_currentUserId != null && m.id == _currentUserId) continue;
            customShares.add(double.parse(m.amountController.text));
          }
        }
      }

      final response = await _apiService.createGroup(
        name: _groupNameController.text.trim(),
        description: _descriptionController.text.trim(),
        goalAmount: _totalAmount,
        memberIds: memberIds,
        splitMethod: _distributionType == DistributionType.equally
            ? 'equal'
            : 'custom',
        customShares: customShares,
      );

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Group Created! Total: Rs. ${_totalAmount.toStringAsFixed(0)}',
            ),
            backgroundColor: const Color(0xFF00D09E),
          ),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.pop(context, true);
        });
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
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
        title: Text(
          "Create Group",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20 * scale,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20 * scale,
            color: Colors.white,
          ),
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
                    Text(
                      "Group Name",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16 * scale,
                      ),
                    ),
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
                    SizedBox(height: 20 * scale),

                    Text(
                      "Description (Optional)",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16 * scale,
                      ),
                    ),
                    SizedBox(height: 10 * scale),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: "Add group details...",
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

                    Text(
                      "Distribution Method",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16 * scale,
                      ),
                    ),
                    SizedBox(height: 10 * scale),
                    _buildDistributionSwitch(scale),
                    SizedBox(height: 25 * scale),

                    _buildClickableCard(
                      title: "Total Amount",
                      value: "Rs. ${_totalAmount.toStringAsFixed(0)}",
                      icon: Icons.attach_money,
                      scale: scale,
                      isEditable: _distributionType == DistributionType.equally,
                      onTap: _showAmountDialog,
                    ),
                    SizedBox(height: 25 * scale),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Members",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16 * scale,
                          ),
                        ),
                        Row(
                          children: [
                            _buildAddButton(
                              "Room",
                              Icons.meeting_room,
                              _navigateToSelectRooms,
                              scale,
                            ),
                            SizedBox(width: 8 * scale),
                            _buildAddButton(
                              "Friend",
                              Icons.person_add,
                              _navigateToSelectFriends,
                              scale,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 15 * scale),

                    if (_selectedFriends.isEmpty && _selectedRooms.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20 * scale),
                          child: Text(
                            "No members added yet.",
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                        ),
                      ),

                    ..._selectedFriends
                        .map((member) => _buildMemberTile(member, scale))
                        .toList(),
                    ..._selectedRooms
                        .map((room) => _buildRoomTile(room, scale))
                        .toList(),
                    SizedBox(height: 80 * scale),
                  ],
                ),
              ),
            ),

            Container(
              padding: EdgeInsets.only(bottom: 25 * scale),
              child: SizedBox(
                width: double.infinity,
                height: 55 * scale,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D09E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15 * scale),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
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

  // Helper Widgets (keeping same UI as original)
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
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black12, blurRadius: 4)]
                : [],
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
                Icon(
                  icon,
                  size: 16 * scale,
                  color: isEditable ? const Color(0xFF00D09E) : Colors.grey,
                ),
                SizedBox(width: 5 * scale),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12 * scale,
                    color: Colors.grey,
                  ),
                ),
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

  Widget _buildAddButton(
    String label,
    IconData icon,
    VoidCallback onTap,
    double scale,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12 * scale,
          vertical: 6 * scale,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFE6F8F0),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00D09E).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14 * scale, color: const Color(0xFF00D09E)),
            SizedBox(width: 4 * scale),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12 * scale,
                color: const Color(0xFF00D09E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          backgroundImage: member.profilePic.startsWith('http')
              ? NetworkImage(member.profilePic)
              : const AssetImage('assets/profile.jpg') as ImageProvider,
          radius: 18 * scale,
        ),
        title: Text(
          member.name,
          style: GoogleFonts.poppins(
            fontSize: 14 * scale,
            fontWeight: FontWeight.w500,
          ),
        ),
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
                    _onCustomAmountChanged(member, val);
                  }
                },
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14 * scale,
                  color: isReadOnly ? Colors.grey : const Color(0xFF00D09E),
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
            IconButton(
              icon: Icon(
                Icons.close,
                size: 18 * scale,
                color: Colors.redAccent,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _removeIndividualFriend(member.id),
            ),
          ],
        ),
      ),
    );
  }

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
            child: Icon(
              Icons.meeting_room,
              color: const Color(0xFF00D09E),
              size: 18 * scale,
            ),
          ),
          title: Text(
            room.name,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 15 * scale,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.close, size: 20, color: Colors.grey),
            onPressed: () {
              setState(() {
                _selectedRooms.removeWhere((r) => r.id == room.id);
                _triggerRecalculation();
              });
            },
          ),
          children: room.members
              .map(
                (member) => Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(left: 10 * scale),
                  child: ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      backgroundImage: member.profilePic.startsWith('http')
                          ? NetworkImage(member.profilePic)
                          : const AssetImage('assets/profile.jpg')
                                as ImageProvider,
                      radius: 14 * scale,
                    ),
                    title: Text(
                      member.name,
                      style: GoogleFonts.poppins(fontSize: 13 * scale),
                    ),
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
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (val) {
                              if (_distributionType ==
                                  DistributionType.custom) {
                                _onCustomAmountChanged(member, val);
                              }
                            },
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 13 * scale,
                              color: isReadOnly
                                  ? Colors.grey
                                  : const Color(0xFF00D09E),
                            ),
                            decoration: InputDecoration(
                              hintText: "0",
                              border: InputBorder.none,
                              isDense: true,
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 5 * scale),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 16 * scale,
                            color: Colors.redAccent,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () =>
                              _removeMemberFromRoom(room, member.id),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class MemberWrapper {
  final String id;
  final String name;
  final String profilePic;
  final TextEditingController amountController;
  int lastKnownAmount = 0; // track integer amount for redistribution

  MemberWrapper({
    required this.id,
    required this.name,
    required this.profilePic,
  }) : amountController = TextEditingController();

  void setAmount(int value) {
    lastKnownAmount = value;
    amountController.text = value.toString();
  }
}

class RoomWrapper {
  final String id;
  final String name;
  final List<MemberWrapper> members;

  RoomWrapper({required this.id, required this.name, required this.members});
}
