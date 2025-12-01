// import 'package:flutter/material.dart';
// import 'home_page.dart';
// import 'rooms_page.dart';
// import 'friends_page.dart';
//
// class MainNavigationPage extends StatefulWidget {
//   const MainNavigationPage({super.key});
//
//   @override
//   State<MainNavigationPage> createState() => _MainNavigationPageState();
// }
//
// class _MainNavigationPageState extends State<MainNavigationPage> {
//   int _currentIndex = 0;
//   int _previousIndex = 0;
//   final List<Widget> _pages = const [HomePage(), RoomsPage(), FriendsPage()];
//
//   //   @override
//   //   Widget build(BuildContext context) {
//   //     return Scaffold(
//   //       body: IndexedStack(
//   //         index: _currentIndex, // keeps state persistent
//   //         children: _pages,
//   //       ),
//   //       bottomNavigationBar: BottomNavigationBar(
//   //         backgroundColor: const Color(0xFFE6F8F0),
//   //         currentIndex: _currentIndex,
//   //         selectedItemColor: const Color(0xFF00B686),
//   //         unselectedItemColor: Colors.black54,
//   //         type: BottomNavigationBarType.fixed,
//   //         onTap: (index) => setState(() => _currentIndex = index),
//   //         items: const [
//   //           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//   //           BottomNavigationBarItem(icon: Icon(Icons.meeting_room), label: "Rooms"),
//   //           BottomNavigationBarItem(icon: Icon(Icons.people), label: "Friends"),
//   //         ],
//   //       ),
//   //     );
//   //   }
//   // }
//
// //idhr bhi animation add ki (sliding)
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: AnimatedSwitcher(
//         duration: const Duration(milliseconds: 300),
//         transitionBuilder: (Widget child, Animation<double> animation) {
//           // Slide from right if new index > old index, else from left
//           final inAnimation = Tween<Offset>(
//             begin: Offset(_currentIndex > _previousIndex ? 1.0 : -1.0, 0),
//             end: Offset.zero,
//           ).animate(animation);
//
//           return SlideTransition(position: inAnimation, child: child);
//         },
//         child: _pages[_currentIndex],
//         layoutBuilder: (currentChild, previousChildren) {
//           return Stack(
//             children: <Widget>[
//               ...previousChildren,
//               if (currentChild != null) currentChild,
//             ],
//           );
//         },
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: const Color(0xFFE6F8F0),
//         currentIndex: _currentIndex,
//         selectedItemColor: const Color(0xFF00B686),
//         unselectedItemColor: Colors.black54,
//         type: BottomNavigationBarType.fixed,
//         onTap: (index) {
//           setState(() {
//             _previousIndex = _currentIndex; // store previous tab for direction
//             _currentIndex = index;
//           });
//         },
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(icon: Icon(Icons.meeting_room), label: "Rooms",),
//           BottomNavigationBarItem(icon: Icon(Icons.people), label: "Friends"),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';

// Pages
import 'home_page.dart';
import 'rooms_page.dart';
import 'friends_page.dart';

// Navigation Targets
import 'group_creation_page.dart';
import 'create_room_page.dart';
import 'notifications_page.dart';
import 'help_page.dart';
import 'add_friend_page.dart'; // Still needed for Friends Page FAB logic

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  // Key to access HomePage state for refreshing after group creation
  final GlobalKey _homeKey = GlobalKey();
  // Key to access RoomsPage state for refreshing after room create/delete
  final GlobalKey _roomsKey = GlobalKey();

  // Mock Notification Count
  int get _unreadNotificationsCount => 10;

  late final List<Widget> _pages = [
    HomePage(key: _homeKey),
    RoomsPage(key: _roomsKey),
    const FriendsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00D09E),

      // --- UNIFIED APP BAR ---
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Spendee",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 25,
            color: Colors.black, // Original Black
          ),
        ),
        // Drawer Icon Wrapped in Builder + Center for alignment
        leading: Builder(
          builder: (context) => Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black, size: 24),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
                if (_unreadNotificationsCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        _unreadNotificationsCount > 9
                            ? '9+'
                            : '$_unreadNotificationsCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () => Navigator.pushNamed(context, '/my-profile'),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/launch', (route) => false);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      "Log Out",
                      style: GoogleFonts.poppins(color: Colors.redAccent),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),

      // --- EXACT DRAWER (FIXED) ---
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Drawer(
          backgroundColor: const Color(0xFFE6F8F0),
          child: Column(
            children: [
              // Header
              Container(
                height: 150,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF008B6C),
                      Color(0xFF00D09E),
                      Color(0xFF7FFFD4),
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
                child: Center(
                  child: Text(
                    'Spendee',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              // Scrollable Content (Notifications Only)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.notifications,
                          color: Color(0xFF00D09E),
                        ),
                        title: Text(
                          'Notifications',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: _unreadNotificationsCount > 0
                            ? Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00D09E),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$_unreadNotificationsCount',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationsPage(),
                            ),
                          );
                        },
                      ),
                      // "Add Friend" REMOVED from here as requested
                    ],
                  ),
                ),
              ),

              // Divider
              const Divider(color: Colors.grey, height: 1),

              // Help (Fixed at Bottom)
              ListTile(
                leading: const Icon(Icons.help, color: Color(0xFF00D09E)),
                title: Text(
                  'Help',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HelpPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),

      // --- BODY ---
      body: IndexedStack(index: _currentIndex, children: _pages),

      // --- DYNAMIC FAB ---
      floatingActionButton: _getFabForIndex(_currentIndex),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // --- BOTTOM NAV ---
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFE6F8F0),
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF00B686),
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.meeting_room),
            label: "Rooms",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Friends"),
        ],
      ),
    );
  }

  Widget? _getFabForIndex(int index) {
    if (index == 0) {
      // Home -> Create Group
      return OpenContainer<bool>(
        transitionDuration: const Duration(milliseconds: 500),
        openElevation: 0,
        closedElevation: 6,
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        closedColor: const Color(0xFF00B686),
        openColor: const Color(0xFFE6F8F0),
        openBuilder: (context, _) => const GroupCreationPage(),
        onClosed: (result) {
          if (result == true) {
            // Ask HomePage to refresh its data
            try {
              (_homeKey.currentState as dynamic)?.refreshData();
            } catch (_) {}
          }
        },

        closedBuilder: (context, openContainer) => FloatingActionButton(
          onPressed: openContainer,
          heroTag: 'main_fab_home',
          backgroundColor: const Color(0xFF00B686),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      );
    } else if (index == 1) {
      // Rooms -> Create Room
      return OpenContainer<bool>(
        transitionDuration: const Duration(milliseconds: 500),
        openElevation: 0,
        closedElevation: 6,
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        closedColor: const Color(0xFF00B686),
        openColor: const Color(0xFFE6F8F0),
        openBuilder: (context, _) => const CreateRoomPage(),
        onClosed: (result) {
          if (result == true) {
            try {
              (_roomsKey.currentState as dynamic)?.refreshData();
            } catch (_) {}
          }
        },
        closedBuilder: (context, openContainer) => FloatingActionButton(
          onPressed: openContainer,
          heroTag: 'main_fab_rooms',
          backgroundColor: const Color(0xFF00B686),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      );
    }
    // Friends page has its own internal button, so no FAB here
    return null;
  }
}
