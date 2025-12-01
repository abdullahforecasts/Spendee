import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_payment_account_page.dart';
import 'specific_payment_account_page.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../utils/session.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditingName = false;
  String name = "Israr Hussain";
  final nameController = TextEditingController();

  // Profile data
  String uid = "";
  String? profilePicUrl;
  File? _newProfileImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  final String baseUrl = "http://192.168.100.12:3000/api";

  // --- NEW DATA & LOGIC START ---
  // Loaded from backend
  List<Map<String, dynamic>> _paymentAccounts = [];

  Map<String, List<Map<String, dynamic>>> get _groupedAccounts {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var account in _paymentAccounts) {
      final name = account['accountTitle'] ?? account['type'] ?? 'Other';
      if (!grouped.containsKey(name)) grouped[name] = [];
      grouped[name]!.add(account);
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
    // Navigate to add page and refresh list when returning
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPaymentAccountPage()),
    ).then((_) {
      _fetchPaymentMethods();
    });
  }
  // --- NEW DATA & LOGIC END ---

  @override
  void initState() {
    super.initState();
    nameController.text = name;
    _fetchProfile();
    _fetchPaymentMethods();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _fetchProfile() async {
    if (Session.authHeader == null) return;
    setState(() => _isLoading = true);
    try {
      final uri = Uri.parse('$baseUrl/auth/profile');
      final resp = await http.get(
        uri,
        headers: {
          'client': 'not-browser',
          'authorization': Session.authHeader!,
        },
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true && data['user'] != null) {
          final user = data['user'];
          setState(() {
            final fetchedName = (user['name'] ?? this.name) as String;
            this.name = fetchedName;
            uid = (user['uuid'] ?? '') as String;
            profilePicUrl = user['profilePic'] as String?;
            nameController.text = fetchedName;
          });
        }
      } else {
        final data = jsonDecode(resp.body);
        _showSnack(data['message'] ?? 'Failed to fetch profile');
      }
    } catch (e) {
      _showSnack('Network error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchPaymentMethods() async {
    if (Session.authHeader == null) return;
    try {
      final uri = Uri.parse('$baseUrl/users/payment-methods');
      final resp = await http.get(
        uri,
        headers: {
          'client': 'not-browser',
          'authorization': Session.authHeader!,
        },
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true && data['paymentMethods'] != null) {
          final List serverList = data['paymentMethods'];
          setState(() {
            _paymentAccounts = serverList.map((m) {
              // normalize to a map with consistent keys
              return {
                '_id': m['_id'] ?? m['id'],
                'type': m['type'],
                'accountTitle': m['accountTitle'] ?? m['name'],
                'accountNumber': m['accountNumber'] ?? m['number'],
                'iban': m['iban'],
                'bankName': m['bankName'],
                'isDefault': m['isDefault'] ?? false,
              };
            }).toList();
          });
        }
      } else {
        // ignore silently or show toast
      }
    } catch (e) {
      // ignore for now
    }
  }

  Future<void> _deletePaymentMethod(String methodId) async {
    if (Session.authHeader == null) return;
    try {
      final uri = Uri.parse('$baseUrl/users/payment-methods/$methodId');
      final resp = await http.delete(
        uri,
        headers: {
          'client': 'not-browser',
          'authorization': Session.authHeader!,
        },
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) {
          _showSnack(data['message'] ?? 'Deleted');
          await _fetchPaymentMethods();
        }
      } else {
        final data = jsonDecode(resp.body);
        _showSnack(data['message'] ?? 'Delete failed');
      }
    } catch (e) {
      _showSnack('Network error: $e');
    }
  }

  Future<void> _updatePaymentMethod(
    String methodId,
    String? accountTitle,
    String? value,
    String? iban,
    bool isDefault,
  ) async {
    if (Session.authHeader == null) return;

    try {
      final uri = Uri.parse('$baseUrl/users/payment-methods/$methodId');

      final Map<String, dynamic> body = {};
      if (accountTitle != null) body['accountTitle'] = accountTitle;
      if (value != null && value.isNotEmpty) {
        if (iban != null && iban.isNotEmpty)
          body['iban'] = value;
        else
          body['accountNumber'] = value;
      }
      body['isDefault'] = isDefault;

      final resp = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'client': 'not-browser',
          'authorization': Session.authHeader!,
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(resp.body);
      if (resp.statusCode == 200) {
        _showSnack(data['message'] ?? 'Payment method updated');
        await _fetchPaymentMethods();
      } else {
        _showSnack(data['message'] ?? 'Update failed');
      }
    } catch (e) {
      _showSnack('Network error: $e');
    }
  }

  Future<void> _updateProfile({String? name, File? imageFile}) async {
    if (Session.authHeader == null) {
      _showSnack('Not authenticated');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final uri = Uri.parse('$baseUrl/auth/profile');
      final request = http.MultipartRequest('PATCH', uri);
      request.headers['client'] = 'not-browser';
      request.headers['authorization'] = Session.authHeader!;

      if (name != null) request.fields['name'] = name;

      if (imageFile != null) {
        final mf = await http.MultipartFile.fromPath(
          'profilePic',
          imageFile.path,
        );
        request.files.add(mf);
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['user'] != null) {
          final user = data['user'];
          setState(() {
            final updatedName = (user['name'] ?? this.name) as String;
            this.name = updatedName;
            uid = (user['uuid'] ?? uid) as String;
            profilePicUrl = user['profilePic'] as String? ?? profilePicUrl;
            nameController.text = updatedName;
          });
          _showSnack(data['message'] ?? 'Profile updated');
        }
      } else {
        final data = jsonDecode(response.body);
        _showSnack(data['message'] ?? 'Update failed');
      }
    } catch (e) {
      _showSnack('Network error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
          const SizedBox(height: 25),

          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 70,
                backgroundImage: profilePicUrl != null
                    ? NetworkImage(profilePicUrl!) as ImageProvider
                    : const AssetImage('assets/profile.jpg'),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black),
                  onPressed: () async {
                    final picked = await _picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (picked != null) {
                      final file = File(picked.path);
                      await _updateProfile(imageFile: file);
                    }
                  },
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
            onToggle: () async {
              setState(() {
                if (isEditingName) {
                  // will be handled after toggling
                }
                isEditingName = !isEditingName;
              });
              if (!isEditingName) {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty && newName != name) {
                  await _updateProfile(name: newName);
                }
              }
            },
          ),
          const SizedBox(height: 20),

          _buildFixedTile(label: "UID", value: uid.isNotEmpty ? uid : '—'),

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
              String initials = key.length >= 2
                  ? key.substring(0, 2).toUpperCase()
                  : key.substring(0, 1).toUpperCase();

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
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
                            fontSize: 16,
                          ),
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
                      final displayId =
                          account['ac countNumber'] ?? account['iban'] ?? '—';
                      return ListTile(
                        onTap: () => _navigateToSpecificPaymentAccount(account),
                        contentPadding: const EdgeInsets.only(
                          left: 70,
                          right: 12,
                          bottom: 5,
                        ),
                        title: Text(
                          displayId,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: account['isDefault'] == true
                            ? Text(
                                'Default',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.black54,
                                size: 20,
                              ),
                              onPressed: () async {
                                // Edit dialog
                                final updated =
                                    await showDialog<Map<String, dynamic>>(
                                      context: context,
                                      builder: (context) {
                                        final titleController =
                                            TextEditingController(
                                              text:
                                                  account['accountTitle']
                                                      ?.toString() ??
                                                  '',
                                            );
                                        final numberController =
                                            TextEditingController(
                                              text:
                                                  account['accountNumber'] ??
                                                  account['iban'] ??
                                                  '',
                                            );
                                        bool isIban =
                                            account['iban'] != null &&
                                            (account['iban'] as String)
                                                .isNotEmpty;
                                        bool isDefault =
                                            account['isDefault'] == true;
                                        return StatefulBuilder(
                                          builder: (context, setState) =>
                                              AlertDialog(
                                                title: const Text(
                                                  'Edit payment method',
                                                ),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    TextField(
                                                      controller:
                                                          titleController,
                                                      decoration:
                                                          const InputDecoration(
                                                            labelText: 'Title',
                                                          ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    TextField(
                                                      controller:
                                                          numberController,
                                                      decoration:
                                                          const InputDecoration(
                                                            labelText:
                                                                'Account/IBAN',
                                                          ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        Checkbox(
                                                          value: isDefault,
                                                          onChanged: (v) =>
                                                              setState(
                                                                () =>
                                                                    isDefault =
                                                                        v ??
                                                                        false,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        const Text(
                                                          'Set as default',
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context, {
                                                        'accountTitle':
                                                            titleController.text
                                                                .trim(),
                                                        'value':
                                                            numberController
                                                                .text
                                                                .trim(),
                                                        'isDefault': isDefault,
                                                      });
                                                    },
                                                    child: const Text('Save'),
                                                  ),
                                                ],
                                              ),
                                        );
                                      },
                                    );
                                if (updated != null) {
                                  final id = account['_id']?.toString();
                                  if (id != null) {
                                    await _updatePaymentMethod(
                                      id,
                                      updated['accountTitle'] as String?,
                                      updated['value'] as String?,
                                      null,
                                      updated['isDefault'] == true,
                                    );
                                  }
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete payment method'),
                                    content: const Text(
                                      'Are you sure you want to delete this payment method?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  final id = account['_id']?.toString();
                                  if (id != null)
                                    await _deletePaymentMethod(id);
                                }
                              },
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.grey,
                            ),
                          ],
                        ),
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
                ),
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
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 3),
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
                  fontSize: 14,
                ),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
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
  Widget _buildFixedTile({required String label, required String value}) {
    const Color primaryColor = Color(0xFF00D09E);
    const Color lightGreen = Color(0xFFC9F8DC);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 3),
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
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
