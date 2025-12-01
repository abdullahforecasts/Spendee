import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'password_success_page.dart';
import '../services/api_service.dart';

class NewPasswordPage extends StatefulWidget {
  final String? email;
  final String? providedCode;

  const NewPasswordPage({super.key, this.email, this.providedCode});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}
// state class continues below

class _NewPasswordPageState extends State<NewPasswordPage> {
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ApiService _api = ApiService();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00B686),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 20),
              child: Text(
                'New Password',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),

            // White Rounded Section
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1FFF8),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildPasswordField(
                        label: "New Password",
                        controller: _newPasswordController,
                        obscure: _obscureNew,
                        toggle: () {
                          setState(() => _obscureNew = !_obscureNew);
                        },
                      ),
                      const SizedBox(height: 20),
                      buildPasswordField(
                        label: "Confirm New Password",
                        controller: _confirmPasswordController,
                        obscure: _obscureConfirm,
                        toggle: () {
                          setState(() => _obscureConfirm = !_obscureConfirm);
                        },
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00B686),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: _loading
                              ? null
                              : () async {
                                  final newPass = _newPasswordController.text
                                      .trim();
                                  final confirm = _confirmPasswordController
                                      .text
                                      .trim();
                                  if (newPass.isEmpty || confirm.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please fill both fields',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  if (newPass != confirm) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Passwords do not match'),
                                      ),
                                    );
                                    return;
                                  }

                                  if (widget.email == null ||
                                      widget.providedCode == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Missing email or code'),
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() => _loading = true);
                                  try {
                                    final resp = await _api
                                        .verifyForgotPasswordCode(
                                          widget.email!,
                                          widget.providedCode!,
                                          newPass,
                                        );
                                    if (resp['success'] == true) {
                                      Navigator.pushReplacement(
                                        context,
                                        PageRouteBuilder(
                                          transitionDuration: const Duration(
                                            milliseconds: 800,
                                          ),
                                          pageBuilder: (_, __, ___) =>
                                              const PasswordSuccessPage(),
                                          transitionsBuilder:
                                              (_, anim, __, child) {
                                                return FadeTransition(
                                                  opacity: CurvedAnimation(
                                                    parent: anim,
                                                    curve: Curves.easeInOut,
                                                  ),
                                                  child: child,
                                                );
                                              },
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            resp['message'] ??
                                                'Failed to update password',
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  } finally {
                                    if (mounted)
                                      setState(() => _loading = false);
                                  }
                                },
                          child: Text(
                            "Change Password",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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

  Widget buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback toggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFE6F8F0),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: toggle,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
