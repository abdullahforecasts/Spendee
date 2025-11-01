import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'trip_details_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00D09E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        title: Text("Spendee", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFE6F8F0),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(60),
            topRight: Radius.circular(60),
          ),
        ),
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hi, Welcome Back 👋",
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            _buildTripCard(context, "Murree Trip", "Ali Maqsood", 0.8, "8/10 paid"),
            _buildTripCard(context, "Saturday Night", "Abdullah", 0.5, "5/10 paid"),
            _buildTripCard(context, "Car Pooling", "Anas", 0.4, "2/5 paid"),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, String title, String creator, double progress, String ratioText) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TripDetailsPage()),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFD9F5E9),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFF00D09E),
              child: const Icon(Icons.location_on, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                  Text("Created by $creator",
                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    color: Colors.black,
                    backgroundColor: Colors.white,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 5),
                  Text(ratioText, style: GoogleFonts.poppins(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
