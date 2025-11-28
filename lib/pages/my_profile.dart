import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_payment_account_page.dart';
import 'specific_payment_account_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditingName = false;
  String name = "Israr Hussain";
  final nameController = TextEditingController();

  // --- NEW DATA & LOGIC START ---
  final List<Map<String, dynamic>> _paymentAccounts = [
    {
      'id': '1',
      'name': 'JazzCash',
      'number': '0300-1234567',
    },
    {
      'id': '2',
      'name': 'HBL',
      'number': '1234-5678-9012-3456',
    },
    {
      'id': '3',
      'name': 'JazzCash',
      'number': '0312-3456789',
    },
  ];

  Map<String, List<Map<String, dynamic>>> get _groupedAccounts {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var account in _paymentAccounts) {
      if (!grouped.containsKey(account['name'])) {
        grouped[account['name']] = [];
      }
      grouped[account['name']]!.add(account);
    }
    return grouped;
  }

  void _navigateToSpecificPaymentAccount(Map<String, dynamic> account) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpecificPaymentAccountPage(account: account),
      ),
    );
  }

  void _navigateToAddPaymentAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPaymentAccountPage()),
    );
  }
  // --- NEW DATA & LOGIC END ---

  @override
  void initState() {
    super.initState();
    nameController.text = name;
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape = screenWidth > screenHeight;

    const Color primaryColor = Color(0xFF00D09E);
    const Color backgroundColor = Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
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
        actions: const [
          Icon(Icons.more_vert, color: Colors.black),
          SizedBox(width: 15),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SafeArea(
            bottom: false,
            child: Container(
              width: double.infinity,
              height: constraints.maxHeight,
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
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ---------------------------------------------
          // EXACT UPPER PART (From your provided code)
          // ---------------------------------------------
          const Text(
            "Your Profile",
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
                backgroundImage: AssetImage('assets/profile.jpg'),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 5,
                    )
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 35),

          _buildEditableTile(
            label: "Name",
            value: name,
            controller: nameController,
            isEditing: isEditingName,
            onToggle: () {
              setState(() {
                if (isEditingName) {
                  name = nameController.text.trim();
                }
                isEditingName = !isEditingName;
              });
            },
          ),
          const SizedBox(height: 20),

          _buildFixedTile(
            label: "UID",
            value: "ABCDE123",
          ),

          // ---------------------------------------------
          // NEW LOWER PART (Payment Methods & Button)
          // ---------------------------------------------
          const SizedBox(height: 25),

          // Header
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Payment Methods",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Grouped Expansion List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: _groupedAccounts.length,
            itemBuilder: (context, index) {
              String key = _groupedAccounts.keys.elementAt(index);
              List<Map<String, dynamic>> accounts = _groupedAccounts[key]!;

              // Helper to get initials (e.g. JazzCash -> JC)
              String initials = key.length >= 2 ? key.substring(0, 2).toUpperCase() : key.substring(0, 1).toUpperCase();

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D09E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16),
                        ),
                      ),
                    ),
                    title: Text(
                      key, // Bank Name
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    children: accounts.map((account) {
                      return ListTile(
                        onTap: () => _navigateToSpecificPaymentAccount(account),
                        contentPadding: const EdgeInsets.only(left: 70, right: 20, bottom: 5),
                        title: Text(
                          account['number'],
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.black87),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            size: 14, color: Colors.grey),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 15),

          // Add Payment Account Button (New Style)
          Container(
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D09E).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _navigateToAddPaymentAccount,
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: Text(
                "Add Payment Account",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D09E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  // 1. Original Editable Tile (Upper Part)
  Widget _buildEditableTile({
    required String label,
    required String value,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onToggle,
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
            child: isEditing
                ? TextField(
              controller: controller,
              maxLength: 20,
              maxLines: 1,
              autofocus: true,
              textAlignVertical: TextAlignVertical.center,
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
                isDense: true,
                contentPadding: EdgeInsets.zero,
                floatingLabelBehavior: FloatingLabelBehavior.never,
              ),
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w500),
              onSubmitted: (_) => onToggle(),
            )
                : Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              isEditing ? Icons.check_circle : Icons.edit,
              color: Colors.black54,
              size: 22,
            ),
            onPressed: onToggle,
          ),
        ],
      ),
    );
  }

  // 2. Original Fixed Tile (Upper Part)
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

  // Placeholder for landscape (kept from original code structure)
  Widget _buildLandscapeLayout() {
    return const Center(child: Text("Landscape View"));
  }
}