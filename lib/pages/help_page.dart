import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:spendee/pages/feedback_submitted_page.dart';
import '../services/api_service.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _problemController = TextEditingController();
  late AnimationController _shakeController;
  final ApiService _apiService = ApiService();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _problemController.dispose();
    super.dispose();
  }

  void _submitProblem() {
    final text = _problemController.text.trim();
    if (text.isEmpty) {
      // Shake animation if no text
      _shakeController.forward(from: 0.0);
      return;
    }

    // Submit feedback to backend
    _submitFeedback(text);
  }

  Future<void> _submitFeedback(String message) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await _apiService.submitFeedback(message: message);
      if (!mounted) return;
      // Navigate to feedback submitted page
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => const FeedbackSubmittedPage(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit feedback: $msg')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00D09E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Spendee",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 25),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
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
              padding: const EdgeInsets.all(30),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),

                    // Title - EXACTLY as in image
                    Text(
                      'Send Us The Problem You Faced',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Problem input field - NO hint text
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F8F0),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF00D09E),
                          width: 2,
                        ),
                      ),
                      child: TextField(
                        keyboardType:
                            TextInputType.multiline, // Important for multiline
                        textInputAction:
                            TextInputAction.done, // Enter key will be "Done
                        controller: _problemController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Submit button with shake animation
                    AnimatedBuilder(
                      animation: _shakeController,
                      builder: (context, child) {
                        final shake = _shakeController.value;
                        return Transform.translate(
                          offset: Offset(shake * 10 * math.sin(shake * 10), 0),
                          child: child,
                        );
                      },
                      child: SizedBox(
                        width: 200,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _submitProblem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00D09E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            'Submit',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
    );
  }
}
