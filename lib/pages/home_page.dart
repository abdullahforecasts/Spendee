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
import 'package:animations/animations.dart';
import 'trip_details_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> _recentTrips = [
      {
        'title': 'Murree Trip',
        'creator': 'Ali Maqsood',
        'isCreator': true,
        'progress': 0.8,
        'ratio': '4/5 paid',
        'myStatus': 'Paid',
      },
      {
        'title': 'Saturday Night',
        'creator': 'Abdullah',
        'isCreator': false,
        'progress': 0.5,
        'ratio': '5/10 paid',
        'myStatus': 'Unpaid',
      },
      {
        'title': 'Car Pooling',
        'creator': 'Anas',
        'isCreator': false,
        'progress': 0.4,
        'ratio': '2/5 paid',
        'myStatus': 'Paid',
      },
    ];

    return Stack(
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
                  ..._recentTrips.map((trip) => _buildTripCard(context, trip)).toList(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTripCard(BuildContext context, Map<String, dynamic> trip) {
    bool isCreator = trip['isCreator'];
    bool isPaid = trip['myStatus'] == 'Paid';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => const TripDetailsPage(),
          transitionsBuilder: (_, animation, __, child) => FadeScaleTransition(animation: animation, child: child),
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F8F0),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.group_work, color: Color(0xFF00D09E), size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trip['title'], style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(isCreator ? "Created by You" : "Created by ${trip['creator']}", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 10),
                  if (isCreator) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: trip['progress'],
                        backgroundColor: const Color(0xFFF1F1F1),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00D09E)),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(trip['ratio'], style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w500)),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPaid ? const Color(0xFFE6F8F0) : const Color(0xFFFFF0F0),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isPaid ? const Color(0xFF00D09E) : Colors.redAccent.withOpacity(0.5)),
                      ),
                      child: Text(isPaid ? "Status: Paid" : "Status: Unpaid", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: isPaid ? const Color(0xFF00D09E) : Colors.redAccent)),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}