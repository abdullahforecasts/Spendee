import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'new_password_page.dart';

class VerificationPinPage extends StatefulWidget {
  final String email;
  const VerificationPinPage({super.key, required this.email});

  @override
  State<VerificationPinPage> createState() => _VerificationPinPageState();
}

class _VerificationPinPageState extends State<VerificationPinPage> {
  String _pin = '';
  final int _pinLength = 6; 
  bool _isLoading = false;

  final String baseUrl = "http://192.168.X.X:3000/api";

  void _addDigit(String digit) {
    if (_pin.length < _pinLength) {
      setState(() {
        _pin += digit;
      });
    }
  }

  void _removeDigit() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  Future<void> _sendVerificationCode() async {
    try {
      setState(() => _isLoading = true);
      final response = await http.patch(
        Uri.parse("$baseUrl/auth/send-verification-code"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": widget.email}),
      );
      setState(() => _isLoading = false);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verification code sent!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Failed to send code")),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _verifyCode() async {
    if (_pin.length != _pinLength) return;
    try {
      setState(() => _isLoading = true);
      final response = await http.patch(
        Uri.parse("$baseUrl/auth/verify-verification-code"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": widget.email,
          "providedCode": _pin,
        }),
      );
      setState(() => _isLoading = false);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account verified!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NewPasswordPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Invalid code")),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _sendVerificationCode(); // auto-send when page opens
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00B686),
      body: SafeArea(
        child: Column(
          children: [
            // 🟢 Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 40, bottom: 30),
              color: const Color(0xFF00B686),
              child: Text(
                'Email Verification',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),

            // ⚪ Main content
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      Text(
                        'Enter the 6-digit verification code\nsent to your email',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // 🔘 PIN Circles
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pinLength, (index) {
                          bool filled = index < _pin.length;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: filled ? Colors.black : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 40),

                      // 🔢 Keypad
                      buildKeypad(),

                      const SizedBox(height: 40),

                      // ✅ Verify Button
                      SizedBox(
                        width: 200,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              _isLoading || _pin.length != _pinLength ? null : _verifyCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00B686),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Verify",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 🔁 Resend Code
                      OutlinedButton(
                        onPressed: _isLoading ? null : _sendVerificationCode,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF00B686), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Send Again",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00B686),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Keypad Builder
  Widget buildKeypad() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildKeypadRow(['1', '2', '3']),
        const SizedBox(height: 20),
        buildKeypadRow(['4', '5', '6']),
        const SizedBox(height: 20),
        buildKeypadRow(['7', '8', '9']),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 60),
            buildKeyButton('0'),
            IconButton(
              onPressed: _removeDigit,
              icon: const Icon(Icons.backspace_outlined, size: 28),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildKeypadRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => buildKeyButton(d)).toList(),
    );
  }

  Widget buildKeyButton(String digit) {
    return GestureDetector(
      onTap: () => _addDigit(digit),
      child: Container(
        width: 60,
        height: 60,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xFFE6F8F0),
          shape: BoxShape.circle,
        ),
        child: Text(
          digit,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
