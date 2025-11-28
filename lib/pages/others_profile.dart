import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OthersProfileViewPage extends StatelessWidget {
  const OthersProfileViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape = screenWidth > screenHeight;

    const Color primaryColor = Color(0xFF00D09E);
    const Color lightGreen = Color(0xFFC9F8DC);
    const Color backgroundColor = Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            // FIXED: Added navigation pop
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Spendee",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
        // FIXED: Removed actions (three dots button)
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SafeArea(
            bottom: false,
            child: Container(
              width: double.infinity,
              height: constraints.maxHeight, // Take full available height
              decoration: const BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: isLandscape ? 20 : 30,
                ),
                child: isLandscape
                    ? _buildLandscapeLayout()
                    : _buildPortraitLayout(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Profile",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          const SizedBox(height: 25),

          Stack(
            alignment: Alignment.bottomRight,
            children: [
              const CircleAvatar(
                radius: 70,
                // FIXED: Corrected asset path
                backgroundImage: AssetImage('assets/profile.jpg'),
              ),
              // Optional: You can remove this edit icon container if
              // you don't want any icon on a generic profile.
              // Leaving it out based on "Others Profile" logic usually implies read-only.
            ],
          ),
          const SizedBox(height: 35),

          _buildFixedTile(
            label: "Name",
            value: "Ali Maqsood", // Hardcoded or passed via constructor
          ),
          const SizedBox(height: 20),

          _buildFixedTile(
            label: "UID",
            value: "ABCDE123",
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Profile",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 60,
                // FIXED: Corrected asset path
                backgroundImage: AssetImage('assets/profile.jpg'),
              ),
            ],
          ),
        ),

        // Vertical Divider Line
        Container(
          width: 1,
          margin: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(1),
          ),
        ),

        const SizedBox(width: 20),

        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFixedTile(
                  label: "Name",
                  value: "Ali Maqsood",
                ),
                const SizedBox(height: 20),
                _buildFixedTile(
                  label: "UID",
                  value: "ABCDE123",
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFixedTile({
    required String label,
    required String value,
  }) {
    const Color primaryColor = Color(0xFF00D09E);
    const Color lightGreen = Color(0xFFC9F8DC);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 34,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}