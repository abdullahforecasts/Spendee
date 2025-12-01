// ...existing code...
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../utils/user_model.dart';

class TripDetailsPage extends StatefulWidget {
  final String groupId;

  const TripDetailsPage({Key? key, required this.groupId}) : super(key: key);

  @override
  State<TripDetailsPage> createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  final ApiService _apiService = ApiService();

  GroupModel? _group;
  UserModel? _currentUser;
  bool _isLoading = false;
  String _errorMessage = '';

  // For user's saved payment methods
  List<Map<String, dynamic>> _myPaymentMethods = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load current user
      final profileData = await _apiService.getProfile();
      _currentUser = UserModel.fromJson(profileData['user']);

      // Load group details
      // debug: log the target URL
      try {
        // ApiService exposes baseUrl as a static const
        // ignore: avoid_print
        print('Fetching group details for id=${widget.groupId}');
      } catch (_) {}

      final groupData = await _apiService.getGroupDetails(widget.groupId);
      _group = GroupModel.fromJson(groupData);

      // Load user's payment methods
      final paymentMethodsData = await _apiService.getMyPaymentMethods();
      _myPaymentMethods = List<Map<String, dynamic>>.from(paymentMethodsData);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // Try to extract JSON message if present
      String message = e.toString().replaceAll('Exception: ', '');
      try {
        final decoded = message.startsWith('{') ? jsonDecode(message) : null;
        if (decoded != null && decoded['message'] != null) {
          message = decoded['message'];
        }
      } catch (_) {}

      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
      // also show a SnackBar for immediate feedback
      try {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      } catch (_) {}
    }
  }

  bool get _isCreator =>
      _currentUser != null &&
      _group != null &&
      _group!.leader.id == _currentUser!.id;

  Future<void> _markAsPaid(String memberId, double amount) async {
    try {
      await _apiService.markPayment(widget.groupId, memberId, amount);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment marked successfully!'),
          backgroundColor: Color(0xFF00D09E),
        ),
      );

      _loadData(); // Refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _launchPaymentLink(String deepLink) async {
    final Uri url = Uri.parse(deepLink);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open payment app'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showMarkPaidDialog(GroupMemberModel member) {
    final TextEditingController amountController = TextEditingController(
      text: (member.shareAmount - member.amountPaid).toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Mark Payment',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Member: ${member.user.name}', style: GoogleFonts.poppins()),
            const SizedBox(height: 10),
            Text(
              'Amount to pay: Rs. ${(member.shareAmount - member.amountPaid).toStringAsFixed(0)}',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount Paid',
                prefixText: 'Rs. ',
                filled: true,
                fillColor: const Color(0xFFF5F6FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                Navigator.pop(context);
                _markAsPaid(member.user.id, amount);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D09E),
            ),
            child: Text(
              'Mark as Paid',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteGroup() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          "Delete Group?",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to delete this group? This cannot be undone.",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _apiService.deleteGroup(widget.groupId);
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context, true); // Go back and refresh
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Group deleted successfully")),
                );
              } catch (e) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceAll('Exception: ', '')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(
              "Delete",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Check if user has account for a specific bank
  bool _doIHaveBank(String bankType) {
    return _myPaymentMethods.any((method) => method['type'] == bankType);
  }

  // Get user's accounts for a specific bank
  List<Map<String, dynamic>> _getMyAccountsForBank(String bankType) {
    return _myPaymentMethods
        .where((method) => method['type'] == bankType)
        .toList();
  }

  void _showPaymentDialog() {
    if (_group == null || _group!.paymentMethods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No payment methods available')),
      );
      return;
    }

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
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "The creator prefers these banks. Options you don't have are grayed out.",
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // List Creator's Payment Methods
              ..._group!.paymentMethods.map((method) {
                final bool isAvailable = _doIHaveBank(method.type);
                IconData icon;

                switch (method.type) {
                  case 'jazzcash':
                    icon = Icons.account_balance_wallet;
                    break;
                  case 'easypaisa':
                    icon = Icons.account_balance_wallet;
                    break;
                  case 'bank':
                    icon = Icons.account_balance;
                    break;
                  default:
                    icon = Icons.payment;
                }

                return ListTile(
                  enabled: isAvailable,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? const Color(0xFFE6F8F0)
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: isAvailable
                          ? const Color(0xFF00D09E)
                          : Colors.grey,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    method.accountTitle ?? method.type.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: isAvailable ? Colors.black : Colors.grey,
                    ),
                  ),
                  subtitle: method.accountNumber != null
                      ? Text(
                          method.accountNumber!,
                          style: GoogleFonts.poppins(fontSize: 11),
                        )
                      : null,
                  trailing: isAvailable
                      ? const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.black54,
                        )
                      : null,
                  onTap: isAvailable
                      ? () {
                          Navigator.pop(context);
                          _showMyAccountsDialog(method.type, method);
                        }
                      : null,
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showMyAccountsDialog(
    String bankType,
    PaymentMethodModel creatorMethod,
  ) {
    final myRelevantAccounts = _getMyAccountsForBank(bankType);

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
                "Pay via ${bankType.toUpperCase()}",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Select one of your accounts to proceed.",
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              ...myRelevantAccounts.map((account) {
                return ListTile(
                  leading: const Icon(
                    Icons.credit_card,
                    color: Color(0xFF00D09E),
                  ),
                  title: Text(
                    account['accountTitle'] ?? 'My Account',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    account['accountNumber'] ?? '',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.send, color: Color(0xFF00D09E)),
                  onTap: () async {
                    if (creatorMethod.deepLink != null) {
                      await _launchPaymentLink(creatorMethod.deepLink!);
                    }
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Launching ${bankType.toUpperCase()}..."),
                      ),
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF00D09E),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF00D09E),
        appBar: AppBar(backgroundColor: const Color(0xFF00D09E), elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.white),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  _errorMessage,
                  style: GoogleFonts.poppins(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton(
                onPressed: _loadData,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: Text(
                  'Retry',
                  style: GoogleFonts.poppins(color: const Color(0xFF00D09E)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_group == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF00D09E),
        body: const Center(child: Text('Group not found')),
      );
    }

    // Sort members: unpaid first for creator view
    List<GroupMemberModel> sortedMembers = List.from(_group!.members);
    if (_isCreator) {
      sortedMembers.sort((a, b) {
        if (a.hasPaid == b.hasPaid) return 0;
        return a.hasPaid ? 1 : -1; // Paid goes to bottom
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
          if (_isCreator)
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
                      const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Delete Group",
                        style: GoogleFonts.poppins(color: Colors.red),
                      ),
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
                  _group!.name,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _isCreator
                      ? "Total: Rs. ${_group!.goalAmount.toStringAsFixed(0)}"
                      : _currentUser != null
                      ? "Your Share: Rs. ${_group!.members.firstWhere((m) => m.user.id == _currentUser!.id, orElse: () => _group!.members.first).shareAmount.toStringAsFixed(0)}"
                      : "Rs. ${_group!.goalAmount.toStringAsFixed(0)}",
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
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Members List
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadData,
                      color: const Color(0xFF00D09E),
                      child: ListView.builder(
                        itemCount: sortedMembers.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return _buildMemberTile(sortedMembers[index]);
                        },
                      ),
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

  Widget _buildMemberTile(GroupMemberModel member) {
    bool isPaid = member.hasPaid;
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
            // Profile Picture
            CircleAvatar(
              backgroundImage:
                  member.user.profilePic != null &&
                      member.user.profilePic!.startsWith('http')
                  ? NetworkImage(member.user.profilePic!)
                  : const AssetImage('assets/profile.jpg') as ImageProvider,
              radius: 22,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.user.name,
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
                "Rs. ${member.shareAmount.toStringAsFixed(0)}",
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
                onChanged: (val) {
                  if (val && !isPaid) {
                    // Mark as paid
                    _markAsPaid(
                      member.user.id,
                      member.shareAmount - member.amountPaid,
                    );
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
// ...existing code...