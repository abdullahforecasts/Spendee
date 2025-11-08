import 'package:flutter/material.dart';
import 'home_page.dart';
import 'rooms_page.dart';
import 'friends_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  int _previousIndex = 0; 
  final List<Widget> _pages = const [HomePage(), RoomsPage(), FriendsPage()];

  //   @override
  //   Widget build(BuildContext context) {
  //     return Scaffold(
  //       body: IndexedStack(
  //         index: _currentIndex, // keeps state persistent
  //         children: _pages,
  //       ),
  //       bottomNavigationBar: BottomNavigationBar(
  //         backgroundColor: const Color(0xFFE6F8F0),
  //         currentIndex: _currentIndex,
  //         selectedItemColor: const Color(0xFF00B686),
  //         unselectedItemColor: Colors.black54,
  //         type: BottomNavigationBarType.fixed,
  //         onTap: (index) => setState(() => _currentIndex = index),
  //         items: const [
  //           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
  //           BottomNavigationBarItem(icon: Icon(Icons.meeting_room), label: "Rooms"),
  //           BottomNavigationBarItem(icon: Icon(Icons.people), label: "Friends"),
  //         ],
  //       ),
  //     );
  //   }
  // }

//idhr bhi animation add ki (sliding)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          // Slide from right if new index > old index, else from left
          final inAnimation = Tween<Offset>(
            begin: Offset(_currentIndex > _previousIndex ? 1.0 : -1.0, 0),
            end: Offset.zero,
          ).animate(animation);

          return SlideTransition(position: inAnimation, child: child);
        },
        child: _pages[_currentIndex],
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFE6F8F0),
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF00B686),
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _previousIndex = _currentIndex; // store previous tab for direction
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.meeting_room), label: "Rooms",),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Friends"),
        ],
      ),
    );
  }
}
