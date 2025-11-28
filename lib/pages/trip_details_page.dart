// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// class TripDetailsPage extends StatelessWidget {
//   const TripDetailsPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF00D09E),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF00D09E),
//         elevation: 0,
//         title: Text("Spendee", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
//           children: [
//             const SizedBox(height: 15),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "Murree Trip",
//                   style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 Text("Rs. 32,000", style: GoogleFonts.poppins(fontSize: 16)),
//               ],
//             ),
//             const SizedBox(height: 20),
//             const CircleAvatar(
//               radius: 35,
//               backgroundImage: AssetImage('assets/profile.jpg'),
//             ),
//             const SizedBox(height: 8),
//             Text("Ali Maqsood", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
//             const SizedBox(height: 25),
//             _buildMemberCard("Anas Faisal", "Unpaid", "Rs. 8000"),
//             _buildMemberCard("Abdullah", "Paid", "Rs. 8000"),
//             _buildMemberCard("Israr Hussain", "Unpaid", "Rs. 8000"),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMemberCard(String name, String status, String amount) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: const Color(0xFF00D09E),
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               const CircleAvatar(
//                 backgroundImage: AssetImage('assets/profile.jpg'),
//                 radius: 20,
//               ),
//               const SizedBox(width: 10),
//               Text(name,
//                   style: GoogleFonts.poppins(
//                       fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
//             ],
//           ),
//           Text(
//             "$status • $amount",
//             style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'others_profile.dart'; // Import for profile navigation

class TripDetailsPage extends StatefulWidget {
  const TripDetailsPage({super.key});

  @override
  State<TripDetailsPage> createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  // --- STATE ---
  // Default to true (Creator View), toggle via Eye icon to test Member View
  bool _isCreator = true;

  // Creator's Preferred Banks (Mock)
  final List<String> _creatorPreferredBanks = ['JazzCash', 'Meezan Bank', 'Sadapay'];

  // My (User's) Payment Accounts (Mock)
  final List<Map<String, dynamic>> _myAccounts = [
    {'bank': 'JazzCash', 'number': '0300-1234567', 'title': 'My Jazz Personal'},
    {'bank': 'HBL', 'number': '1234-5678-9012', 'title': 'HBL Freedom'},
    {'bank': 'Sadapay', 'number': '0312-3456789', 'title': 'My SadaPay'},
  ];

  // Group Members Data
  final List<Map<String, dynamic>> _members = [
    {'id': '1', 'name': 'Ali Maqsood', 'amount': 5000, 'isPaid': false, 'image': 'assets/profile.jpg'},
    {'id': '2', 'name': 'Abdullah', 'amount': 5000, 'isPaid': true, 'image': 'assets/profile.jpg'},
    {'id': '3', 'name': 'Anas Faisal', 'amount': 5000, 'isPaid': false, 'image': 'assets/profile.jpg'},
    {'id': '4', 'name': 'Hassan', 'amount': 5000, 'isPaid': false, 'image': 'assets/profile.jpg'},
  ];

  // --- LOGIC ---

  void _togglePaidStatus(int index, bool value) {
    setState(() {
      _members[index]['isPaid'] = value;
    });
  }

  // Check if I have an account for a specific bank
  bool _doIHaveBank(String bankName) {
    return _myAccounts.any((account) => account['bank'] == bankName);
  }

  // Get my accounts for a specific bank
  List<Map<String, dynamic>> _getMyAccountsForBank(String bankName) {
    return _myAccounts.where((account) => account['bank'] == bankName).toList();
  }

  // --- UI ACTIONS ---

  void _confirmDeleteGroup() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Group?", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete this group? This cannot be undone.", style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // Close Dialog
              Navigator.pop(context); // Go back to Home Page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Group deleted successfully")),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text("Delete", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- UI BUILDERS ---

  void _showPaymentDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Payment Method",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Text(
                "The creator prefers these banks. Options you don't have are grayed out.",
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // List of Creator's Banks
              ..._creatorPreferredBanks.map((bank) {
                final bool isAvailable = _doIHaveBank(bank);
                return ListTile(
                  enabled: isAvailable,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isAvailable ? const Color(0xFFE6F8F0) : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance,
                      color: isAvailable ? const Color(0xFF00D09E) : Colors.grey,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    bank,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: isAvailable ? Colors.black : Colors.grey,
                    ),
                  ),
                  trailing: isAvailable
                      ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54)
                      : null,
                  onTap: isAvailable ? () {
                    Navigator.pop(context); // Close first sheet
                    _showMyAccountsDialog(bank); // Open second sheet
                  } : null,
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showMyAccountsDialog(String bankName) {
    final myRelevantAccounts = _getMyAccountsForBank(bankName);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pay via $bankName",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Text(
                "Select one of your accounts to proceed.",
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              ...myRelevantAccounts.map((account) {
                return ListTile(
                  leading: const Icon(Icons.credit_card, color: Color(0xFF00D09E)),
                  title: Text(account['title'], style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  subtitle: Text(account['number'], style: GoogleFonts.poppins(fontSize: 12)),
                  trailing: const Icon(Icons.send, color: Color(0xFF00D09E)),
                  onTap: () {
                    print("TO IMPLEMENT: Deep link to $bankName app with account ${account['number']}");
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Launching $bankName...")),
                    );
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCreator) {
      _members.sort((a, b) {
        if (a['isPaid'] == b['isPaid']) return 0;
        return a['isPaid'] ? 1 : -1; // Paid goes to bottom
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF00D09E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Spendee",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 25,
            color: Colors.white,
          ),
        ),
        actions: [
          // Toggle View Button (For Testing)
          IconButton(
            tooltip: "Toggle View (Creator/Member)",
            icon: Icon(
              _isCreator ? Icons.visibility : Icons.visibility_off,
              color: Colors.white70,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _isCreator = !_isCreator;
              });
            },
          ),
          // Three Dots Menu -> Delete Group
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'delete') {
                _confirmDeleteGroup();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 10),
                    Text("Delete Group", style: GoogleFonts.poppins(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Column(
              children: [
                Text(
                  "Murree Trip",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _isCreator ? "Total: Rs. 20,000" : "Your Share: Rs. 5,000",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // White Sheet
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFE6F8F0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Group Members",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _isCreator ? "(Creator View)" : "(Member View)",
                        style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Members List
                  Expanded(
                    child: ListView.builder(
                      itemCount: _members.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return _buildMemberTile(_members[index], index);
                      },
                    ),
                  ),

                  // Pay Now Button (Only for Non-Creators)
                  if (!_isCreator) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _showPaymentDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D09E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Pay Now",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTile(Map<String, dynamic> member, int index) {
    bool isPaid = member['isPaid'];
    bool isGrayedOut = _isCreator && isPaid;

    return Opacity(
      opacity: isGrayedOut ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            if (!isGrayedOut)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Row(
          children: [
            // PROFILE NAVIGATION
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OthersProfileViewPage()),
                );
              },
              child: CircleAvatar(
                backgroundImage: AssetImage(member['image']),
                radius: 22,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member['name'],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  if (_isCreator && isPaid)
                    Text(
                      "Paid",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),

            // CREATOR VIEW: Show Amount + Switch
            if (_isCreator) ...[
              Text(
                "Rs. ${member['amount']}",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(width: 10),
              Switch(
                value: isPaid,
                activeColor: const Color(0xFF00D09E),
                onChanged: (val) => _togglePaidStatus(index, val),
              ),
            ]
          ],
        ),
      ),
    );
  }
}