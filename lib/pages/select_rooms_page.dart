// lib/pages/select_rooms_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../utils/user_model.dart'; // Updated import path

class SelectRoomsPage extends StatefulWidget {
  final List<Map<String, dynamic>> initialSelectedRooms;

  const SelectRoomsPage({
    Key? key,
    required this.initialSelectedRooms,
  }) : super(key: key);

  @override
  State<SelectRoomsPage> createState() => _SelectRoomsPageState();
}

class _SelectRoomsPageState extends State<SelectRoomsPage> {
  final ApiService _apiService = ApiService();
  
  List<RoomModel> _allRooms = [];
  List<String> _selectedRoomIds = [];
  
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _selectedRoomIds = widget.initialSelectedRooms
        .map((r) => r['id'] as String)
        .toList();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final roomsData = await _apiService.getMyRooms();
      final rooms = roomsData.map((r) => RoomModel.fromJson(r)).toList();
      
      setState(() {
        _allRooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _toggleRoom(RoomModel room) {
    setState(() {
      if (_selectedRoomIds.contains(room.id)) {
        _selectedRoomIds.remove(room.id);
      } else {
        _selectedRoomIds.add(room.id);
      }
    });
  }

  void _confirmSelection() {
    final selectedRooms = _allRooms
        .where((r) => _selectedRoomIds.contains(r.id))
        .toList();

    Navigator.pop(context, {
      'rooms': selectedRooms,
    });
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
          "Select Rooms",
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
            // Selected Count
            if (_selectedRoomIds.isNotEmpty)
              Container(
                padding: EdgeInsets.all(10 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${_selectedRoomIds.length} room(s) selected",
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
                        onPressed: _loadRooms,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D09E),
                        ),
                        child: Text("Retry", style: GoogleFonts.poppins(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),

            // Rooms List
            if (!_isLoading && _errorMessage.isEmpty)
              Expanded(
                child: _allRooms.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.meeting_room_outlined, size: 60 * scale, color: Colors.grey),
                            SizedBox(height: 10 * scale),
                            Text(
                              "No rooms yet",
                              style: GoogleFonts.poppins(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _allRooms.length,
                        itemBuilder: (context, index) {
                          final room = _allRooms[index];
                          final isSelected = _selectedRoomIds.contains(room.id);
                          
                          // Parse color from hex string
                          Color roomColor;
                          try {
                            roomColor = Color(int.parse(room.color.substring(1), radix: 16) + 0xFF000000);
                          } catch (e) {
                            roomColor = const Color(0xFF3B82F6);
                          }

                          return Container(
                            margin: EdgeInsets.only(bottom: 12 * scale),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE6F8F0)
                                  : const Color(0xFFF5F6FA),
                              borderRadius: BorderRadius.circular(15 * scale),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF00D09E)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(12 * scale),
                              leading: Container(
                                width: 50 * scale,
                                height: 50 * scale,
                                decoration: BoxDecoration(
                                  color: roomColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12 * scale),
                                ),
                                child: Center(
                                  child: Text(
                                    room.icon,
                                    style: TextStyle(fontSize: 24 * scale),
                                  ),
                                ),
                              ),
                              title: Text(
                                room.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 16 * scale,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5 * scale),
                                  Text(
                                    "${room.members.length} members",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12 * scale,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  if (room.description.isNotEmpty) ...[
                                    SizedBox(height: 3 * scale),
                                    Text(
                                      room.description,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11 * scale,
                                        color: Colors.grey.shade600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check_circle,
                                      color: const Color(0xFF00D09E),
                                      size: 28 * scale,
                                    )
                                  : Icon(
                                      Icons.circle_outlined,
                                      color: Colors.grey.shade300,
                                      size: 28 * scale,
                                    ),
                              onTap: () => _toggleRoom(room),
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
                onPressed: _selectedRoomIds.isEmpty ? null : _confirmSelection,
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