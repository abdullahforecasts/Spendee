// lib/pages/select_friends_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../utils/user_model.dart'; // Updated import path

class SelectFriendsPage extends StatefulWidget {
  final List<Map<String, dynamic>> initialSelectedFriends;

  const SelectFriendsPage({
    Key? key,
    required this.initialSelectedFriends,
  }) : super(key: key);

  @override
  State<SelectFriendsPage> createState() => _SelectFriendsPageState();
}

class _SelectFriendsPageState extends State<SelectFriendsPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  
  List<UserModel> _allFriends = [];
  List<UserModel> _filteredFriends = [];
  List<String> _selectedFriendIds = [];
  
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _selectedFriendIds = widget.initialSelectedFriends
        .map((f) => f['id'] as String)
        .toList();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final friendsData = await _apiService.getMyFriends();
      final friends = friendsData.map((f) => UserModel.fromJson(f)).toList();
      
      setState(() {
        _allFriends = friends;
        _filteredFriends = friends;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _filterFriends(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFriends = _allFriends;
      } else {
        _filteredFriends = _allFriends
            .where((friend) =>
                friend.name.toLowerCase().contains(query.toLowerCase()) ||
                friend.email.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleFriend(UserModel friend) {
    setState(() {
      if (_selectedFriendIds.contains(friend.id)) {
        _selectedFriendIds.remove(friend.id);
      } else {
        _selectedFriendIds.add(friend.id);
      }
    });
  }

  void _confirmSelection() {
    final selectedFriends = _allFriends
        .where((f) => _selectedFriendIds.contains(f.id))
        .map((f) => {
              'id': f.id,
              'name': f.name,
              'image': f.profilePic ?? 'assets/profile.jpg',
            })
        .toList();

    Navigator.pop(context, selectedFriends);
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
          "Select Friends",
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
        padding: EdgeInsets.all(25 * scale),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: _filterFriends,
              decoration: InputDecoration(
                hintText: "Search friends...",
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00D09E)),
                filled: true,
                fillColor: const Color(0xFFF5F6FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15 * scale),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 15 * scale,
                  vertical: 15 * scale,
                ),
              ),
            ),
            SizedBox(height: 20 * scale),

            // Selected Count
            if (_selectedFriendIds.isNotEmpty)
              Container(
                padding: EdgeInsets.all(10 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${_selectedFriendIds.length} friend(s) selected",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF00D09E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            SizedBox(height: 15 * scale),

            // Loading State
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator(color: Color(0xFF00D09E))),
              ),

            // Error State
            if (_errorMessage.isNotEmpty && !_isLoading)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.red),
                      const SizedBox(height: 10),
                      Text(
                        _errorMessage,
                        style: GoogleFonts.poppins(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadFriends,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D09E),
                        ),
                        child: Text("Retry", style: GoogleFonts.poppins(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),

            // Friends List
            if (!_isLoading && _errorMessage.isEmpty)
              Expanded(
                child: _filteredFriends.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 60 * scale, color: Colors.grey),
                            SizedBox(height: 10 * scale),
                            Text(
                              _searchController.text.isEmpty
                                  ? "No friends yet"
                                  : "No friends found",
                              style: GoogleFonts.poppins(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredFriends.length,
                        itemBuilder: (context, index) {
                          final friend = _filteredFriends[index];
                          final isSelected = _selectedFriendIds.contains(friend.id);

                          return Container(
                            margin: EdgeInsets.only(bottom: 10 * scale),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE6F8F0)
                                  : const Color(0xFFF5F6FA),
                              borderRadius: BorderRadius.circular(12 * scale),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF00D09E)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: friend.profilePic != null &&
                                        friend.profilePic!.startsWith('http')
                                    ? NetworkImage(friend.profilePic!)
                                    : const AssetImage('assets/profile.jpg')
                                        as ImageProvider,
                                radius: 22 * scale,
                              ),
                              title: Text(
                                friend.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 15 * scale,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                friend.email,
                                style: GoogleFonts.poppins(
                                  fontSize: 12 * scale,
                                  color: Colors.grey,
                                ),
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check_circle,
                                      color: const Color(0xFF00D09E),
                                      size: 24 * scale,
                                    )
                                  : Icon(
                                      Icons.circle_outlined,
                                      color: Colors.grey.shade300,
                                      size: 24 * scale,
                                    ),
                              onTap: () => _toggleFriend(friend),
                            ),
                          );
                        },
                      ),
              ),

            // Confirm Button
            SizedBox(height: 20 * scale),
            SizedBox(
              width: double.infinity,
              height: 50 * scale,
              child: ElevatedButton(
                onPressed: _selectedFriendIds.isEmpty ? null : _confirmSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D09E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25 * scale),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: Text(
                  "Confirm Selection",
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
}