import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../utils/session.dart';

class SpecificPaymentAccountPage extends StatefulWidget {
  final Map<String, dynamic>? account;
  final String? methodId;

  const SpecificPaymentAccountPage({super.key, this.account, this.methodId});

  @override
  State<SpecificPaymentAccountPage> createState() =>
      _SpecificPaymentAccountPageState();
}

class _SpecificPaymentAccountPageState
    extends State<SpecificPaymentAccountPage> {
  Map<String, dynamic>? account;
  bool _loading = false;
  final String baseUrl = "http://192.168.100.12:3000/api";

  @override
  void initState() {
    super.initState();
    account = widget.account;
    if (widget.methodId != null && account == null) {
      _fetchMethod(widget.methodId!);
    }
  }

  Future<void> _fetchMethod(String id) async {
    if (Session.authHeader == null) return;
    setState(() => _loading = true);
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
          final List methods = data['paymentMethods'];
          final found = methods.firstWhere(
            (m) => (m['_id'] ?? m['id']) == id,
            orElse: () => null,
          );
          if (found != null) {
            setState(() {
              account = {
                '_id': found['_id'] ?? found['id'],
                'type': found['type'],
                'accountTitle': found['accountTitle'] ?? found['name'],
                'accountNumber': found['accountNumber'] ?? found['number'],
                'iban': found['iban'],
                'bankName': found['bankName'],
                'isDefault': found['isDefault'] ?? false,
              };
            });
          }
        }
      }
    } catch (e) {
      // ignore for now
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _removeAccount() async {
    final id = account?['_id'] ?? widget.methodId;
    if (id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No account id')));
      return;
    }

    if (Session.authHeader == null) return;

    final uri = Uri.parse('$baseUrl/users/payment-methods/$id');
    try {
      final resp = await http.delete(
        uri,
        headers: {
          'client': 'not-browser',
          'authorization': Session.authHeader!,
        },
      );
      final data = jsonDecode(resp.body);
      if (resp.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'] ?? 'Removed')));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Remove failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / 390;

    final displayName =
        (account?['accountTitle'] ??
                account?['bankName'] ??
                account?['type'] ??
                account?['name'])
            ?.toString() ??
        'Unknown';
    final displayNumber =
        (account?['accountNumber'] ?? account?['iban'] ?? account?['number'])
            ?.toString() ??
        '—';
    final isDefault = account?['isDefault'] == true;

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
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20 * scale,
            color: Colors.white,
          ),
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
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
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
                              border: Border.all(
                                color: const Color(0xFF00D09E),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.account_balance_wallet,
                              size: 40 * scale,
                              color: const Color(0xFF00D09E),
                            ),
                          ),
                          SizedBox(height: 30 * scale),

                          // Read Only Fields
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: _buildReadOnlyField(
                                  "Bank/Account Name",
                                  displayName,
                                  scale,
                                ),
                              ),
                              if (isDefault) ...[
                                SizedBox(width: 10 * scale),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8 * scale,
                                    vertical: 6 * scale,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F8EE),
                                    borderRadius: BorderRadius.circular(
                                      20 * scale,
                                    ),
                                    border: Border.all(
                                      color: const Color(0xFF00D09E),
                                    ),
                                  ),
                                  child: Text(
                                    'Default',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12 * scale,
                                      color: const Color(0xFF00D09E),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 20 * scale),
                          _buildReadOnlyField(
                            "Account Number / IBAN",
                            displayNumber,
                            scale,
                          ),
                        ],
                      ),
                    ),
            ),

            // Remove Button
            SizedBox(
              width: double.infinity,
              height: 55 * scale,
              child: ElevatedButton(
                onPressed: _removeAccount,
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
      padding: EdgeInsets.symmetric(
        horizontal: 15 * scale,
        vertical: 15 * scale,
      ),
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
