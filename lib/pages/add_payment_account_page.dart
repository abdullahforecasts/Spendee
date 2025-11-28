import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class AddPaymentAccountPage extends StatefulWidget {
  const AddPaymentAccountPage({super.key});

  @override
  State<AddPaymentAccountPage> createState() => _AddPaymentAccountPageState();
}

class _AddPaymentAccountPageState extends State<AddPaymentAccountPage> {
  // Hardcoded list of banks/accounts
  final List<String> _bankOptions = [
    'JazzCash',
    'EasyPaisa',
    'HBL',
    'Meezan Bank',
    'Sadapay',
    'Nayapay',
    'Allied Bank',
    'Bank Alfalah'
  ];

  String? _selectedBank;
  String _selectedIdType = 'Account Number'; // Default selection
  final TextEditingController _numberController = TextEditingController();

  // Validation & Add Logic
  void _addAccount() {
    if (_selectedBank == null) {
      _showSnack('Please select a Bank/Account');
      return;
    }

    String number = _numberController.text.trim();

    if (_selectedIdType == 'Account Number') {
      // Must be exactly 10 digits (since +92 is fixed in UI)
      if (number.length != 10) {
        _showSnack('Account number must be 10 digits');
        return;
      }
    } else {
      // IBAN validation (basic length check)
      if (number.isEmpty || number.length > 24) {
        _showSnack('Please enter a valid IBAN (max 24 chars)');
        return;
      }
    }

    // Success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_selectedBank account added successfully!'),
        backgroundColor: const Color(0xFF00D09E),
      ),
    );
    Navigator.pop(context);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / 390;

    return Scaffold(
      backgroundColor: const Color(0xFF00D09E),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 20 * scale),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8 * scale),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 15 * scale),
                  Text(
                    "Add Payment Method",
                    style: GoogleFonts.poppins(
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // White Container
            Expanded(
              child: Container(
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
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Account Details",
                              style: GoogleFonts.poppins(
                                fontSize: 18 * scale,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 25 * scale),

                            // 1. Bank/Account Dropdown
                            _buildLabel("Bank/Account"),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 15 * scale),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F6FA),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedBank,
                                  hint: Text("Select Bank/Account", style: GoogleFonts.poppins(color: Colors.grey.shade400)),
                                  isExpanded: true,
                                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                                  items: _bankOptions.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value, style: GoogleFonts.poppins()),
                                    );
                                  }).toList(),
                                  onChanged: (val) => setState(() => _selectedBank = val),
                                ),
                              ),
                            ),
                            SizedBox(height: 20 * scale),

                            // 2. ID Type Selection (Radio/Toggle look)
                            _buildLabel("Identification Type"),
                            Container(
                              height: 50 * scale,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F6FA),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  _buildToggleOption("Account Number", scale),
                                  _buildToggleOption("IBAN", scale),
                                ],
                              ),
                            ),
                            SizedBox(height: 20 * scale),

                            // 3. Number Input
                            _buildLabel(_selectedIdType),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F6FA),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  // Prefix for Account Number
                                  if (_selectedIdType == 'Account Number')
                                    Padding(
                                      padding: EdgeInsets.only(left: 16 * scale),
                                      child: Text(
                                        "+92 ",
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),

                                  Expanded(
                                    child: TextField(
                                      controller: _numberController,
                                      keyboardType: _selectedIdType == 'Account Number'
                                          ? TextInputType.number
                                          : TextInputType.text,
                                      textCapitalization: TextCapitalization.characters,
                                      inputFormatters: [
                                        if (_selectedIdType == 'Account Number') ...[
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(10),
                                        ] else ...[
                                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                                          LengthLimitingTextInputFormatter(24),
                                        ]
                                      ],
                                      decoration: InputDecoration(
                                        hintText: _selectedIdType == 'Account Number'
                                            ? "3001234567"
                                            : "PK36MEZN...",
                                        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 16 * scale,
                                            horizontal: 16 * scale
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Add Button
                    SizedBox(height: 10 * scale),
                    Container(
                      width: double.infinity,
                      height: 55 * scale,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00D09E).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _addAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D09E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Add Account",
                          style: GoogleFonts.poppins(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption(String title, double scale) {
    bool isSelected = _selectedIdType == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIdType = title;
            _numberController.clear();
          });
        },
        child: Container(
          margin: EdgeInsets.all(4 * scale),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)
            ] : [],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13 * scale,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? const Color(0xFF00D09E) : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.black54,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}