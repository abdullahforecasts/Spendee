// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'trip_details_page.dart';
// import 'group_creation_page.dart';
// import 'package:animations/animations.dart';
//
// class HomePage extends StatelessWidget {
//   const HomePage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF00D09E),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF00D09E),
//         elevation: 0,
//         title: Text(
//           "Spendee",
//           style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
//         ),
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
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Hi, Welcome Back 👋",
//               style: GoogleFonts.poppins(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 20),
//             _buildTripCard(
//               context,
//               "Murree Trip",
//               "Ali Maqsood",
//               0.8,
//               "8/10 paid",
//             ),
//             _buildTripCard(
//               context,
//               "Saturday Night",
//               "Abdullah",
//               0.5,
//               "5/10 paid",
//             ),
//             _buildTripCard(context, "Car Pooling", "Anas", 0.4, "2/5 paid"),
//           ],
//         ),
//       ),
//
//       //bottom right pe + ka button(opens group creation page with an animation)
//
//       floatingActionButton: OpenContainer(
//         transitionDuration: const Duration(milliseconds: 500),
//         openElevation: 0,
//         closedElevation: 6,
//         closedShape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(50),
//         ),
//         closedColor: const Color(0xFF00B686),
//         openColor: const Color(0xFFE6F8F0),
//         openBuilder: (context, _) => const GroupCreationPage(),
//         closedBuilder: (context, openContainer) => FloatingActionButton(
//           onPressed: openContainer, // triggers the animation
//           backgroundColor: const Color(0xFF00B686),
//           child: const Icon(Icons.add),
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//
//     );
//   }
//
//   //iisme animation add krdi ha (small container to whole page)
//   Widget _buildTripCard(
//     BuildContext context,
//     String title,
//     String creator,
//     double progress,
//     String ratioText,
//   ) {
//     return OpenContainer(
//       transitionDuration: const Duration(milliseconds: 500),
//       closedElevation: 0,
//       closedColor: const Color(0xFFD9F5E9),
//       openColor: const Color(0xFFE6F8F0),
//       closedShape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(15),
//       ),
//       openBuilder: (context, _) => const TripDetailsPage(),
//       closedBuilder: (context, openContainer) => Material(
//         color: Colors.transparent, // let OpenContainer's color show
//         child: InkWell(
//           borderRadius: BorderRadius.circular(15),
//           onTap: openContainer, // triggers the OpenContainer animation
//           splashColor: const Color(0xFF00D09E).withOpacity(
//             0.2,
//           ), // visible ripple(taake tap pe kuch color change ho)
//           highlightColor: Colors.transparent,
//
//           child: Container(
//             margin: const EdgeInsets.only(bottom: 15),
//             padding: const EdgeInsets.all(15),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 25,
//                   backgroundColor: const Color(0xFF00D09E),
//                   child: const Icon(
//                     Icons.location_on,
//                     color: Colors.white,
//                     size: 26,
//                   ),
//                 ),
//                 const SizedBox(width: 15),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         title,
//                         style: GoogleFonts.poppins(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       Text(
//                         "Created by $creator",
//                         style: GoogleFonts.poppins(
//                           fontSize: 13,
//                           color: Colors.black54,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       LinearProgressIndicator(
//                         value: progress,
//                         color: Colors.black,
//                         backgroundColor: Colors.white,
//                         minHeight: 8,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       const SizedBox(height: 5),
//                       Text(ratioText, style: GoogleFonts.poppins(fontSize: 12)),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'trip_details_page.dart';
import 'group_creation_page.dart';
import 'help_page.dart';
import 'package:animations/animations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
            fontSize: 25,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              // TODO: Handle menu options
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Stack(
        children: [
          Container(color: const Color(0xFF00D09E)),
          Positioned.fill(
            top: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFE6F8F0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
              ),
              margin: const EdgeInsets.only(top: 0),
              padding: const EdgeInsets.all(25),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi, Welcome Back 👋",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTripCard(
                      context,
                      "Murree Trip",
                      "Ali Maqsood",
                      0.8,
                      "8/10 paid",
                    ),
                    _buildTripCard(
                      context,
                      "Saturday Night",
                      "Abdullah",
                      0.5,
                      "5/10 paid",
                    ),
                    _buildTripCard(
                      context,
                      "Car Pooling",
                      "Anas",
                      0.4,
                      "2/5 paid",
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: OpenContainer(
        transitionDuration: const Duration(milliseconds: 500),
        openElevation: 0,
        closedElevation: 6,
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        closedColor: const Color(0xFF00B686),
        openColor: const Color(0xFFE6F8F0),
        openBuilder: (context, _) => const GroupCreationPage(),
        closedBuilder: (context, openContainer) => FloatingActionButton(
          onPressed: openContainer,
          backgroundColor: const Color(0xFF00B686),
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // DRAWER - NOW ONLY 3/4 OF SCREEN WIDTH, FULL HEIGHT
  Widget _buildDrawer(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.75, // 75% width
      child: Drawer(
        backgroundColor: const Color(0xFFE6F8F0),
        child: Column(
          children: [
            // Header with gradient
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

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.notifications, color: Color(0xFF00D09E)),
                      title: Text(
                        'Notifications',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D09E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '3',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const Divider(color: Colors.grey, height: 1),

            ListTile(
              leading: const Icon(Icons.help, color: Color(0xFF00D09E)),
              title: Text(
                'Help',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    reverseTransitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                    const HelpPage(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOutCubic;

                      final tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(
      BuildContext context,
      String title,
      String creator,
      double progress,
      String ratioText,
      ) {
    return OpenContainer(
      transitionDuration: const Duration(milliseconds: 500),
      closedElevation: 0,
      closedColor: const Color(0xFFD9F5E9),
      openColor: const Color(0xFFE6F8F0),
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      openBuilder: (context, _) => const TripDetailsPage(),
      closedBuilder: (context, openContainer) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: openContainer,
          splashColor: const Color(0xFF00D09E).withOpacity(0.2),
          highlightColor: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFF00D09E),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Created by $creator",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        color: Colors.black,
                        backgroundColor: Colors.white,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        ratioText,
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}