import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpecificPaymentAccountPage extends StatelessWidget {
  final Map<String, dynamic> account;
  const SpecificPaymentAccountPage({super.key, required this.account});

  void _removeAccount(BuildContext context) {
    // Logic to remove
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Account removed successfully")),
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
        centerTitle: true,
        title: Text(
          "Account Details",
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
        margin: EdgeInsets.only(top: 10 * scale),
        width: double.infinity,
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 10 * scale),

                    // Large Icon
                    Container(
                      width: 80 * scale,
                      height: 80 * scale,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F8F0),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF00D09E), width: 2),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        size: 40 * scale,
                        color: const Color(0xFF00D09E),
                      ),
                    ),
                    SizedBox(height: 30 * scale),

                    // Read Only Fields
                    _buildReadOnlyField("Bank/Account Name", account['name'] ?? 'Unknown', scale),
                    SizedBox(height: 20 * scale),
                    _buildReadOnlyField("Account Number / IBAN", account['number'] ?? 'Unknown', scale),
                  ],
                ),
              ),
            ),

            // Remove Button
            SizedBox(
              width: double.infinity,
              height: 55 * scale,
              child: ElevatedButton(
                onPressed: () => _removeAccount(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.1),
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15 * scale),
                  ),
                ),
                child: Text(
                  "Remove Account",
                  style: GoogleFonts.poppins(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, double scale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 15 * scale, vertical: 15 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(15 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12 * scale,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 5 * scale),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}