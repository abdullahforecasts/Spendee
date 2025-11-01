import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TripDetailsPage extends StatelessWidget {
  const TripDetailsPage({super.key});

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
          children: [
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Murree Trip",
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text("Rs. 32,000", style: GoogleFonts.poppins(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 35,
              backgroundImage: AssetImage('assets/profile.jpg'),
            ),
            const SizedBox(height: 8),
            Text("Ali Maqsood", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 25),
            _buildMemberCard("Anas Faisal", "Unpaid", "Rs. 8000"),
            _buildMemberCard("Abdullah", "Paid", "Rs. 8000"),
            _buildMemberCard("Israr Hussain", "Unpaid", "Rs. 8000"),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(String name, String status, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF00D09E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage('assets/profile.jpg'),
                radius: 20,
              ),
              const SizedBox(width: 10),
              Text(name,
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
          Text(
            "$status • $amount",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
