import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedbackSubmittedPage extends StatefulWidget {
  const FeedbackSubmittedPage({super.key});

  @override
  State<FeedbackSubmittedPage> createState() => _FeedbackSubmittedPageState();
}

class _FeedbackSubmittedPageState extends State<FeedbackSubmittedPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _loadingController;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();

    _loadingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Show loading for 1.5 seconds, then success
    _loadingController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _showSuccess = true);

          // Navigate back after 2 seconds of showing success
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated circle container
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00D09E), width: 5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D09E).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: _showSuccess
                      ? const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF00D09E),
                    size: 70,
                  )
                      : SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: _loadingController.value,
                      strokeWidth: 6,
                      color: const Color(0xFF00D09E),
                      backgroundColor: const Color(0xFF00D09E).withOpacity(0.2),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Text content
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _showSuccess
                  ? Column(
                children: [
                  Text(
                    "Feedback Submitted!",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00D09E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Thank you for your feedback.\nWe'll get back to you soon.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              )
                  : Column(
                children: [
                  Text(
                    "Submitting...",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00D09E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Please wait while we process\nyour feedback",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Loading dots (only show during loading)
            if (!_showSuccess)
              AnimatedBuilder(
                animation: _loadingController,
                builder: (context, child) {
                  final value = _loadingController.value;
                  final dotOpacities = [
                    _opacityForDot(value, 0.0),
                    _opacityForDot(value, 0.33),
                    _opacityForDot(value, 0.66),
                  ];

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Opacity(
                        opacity: dotOpacities[index],
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00D09E),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  double _opacityForDot(double value, double delay) {
    const double period = 1 / 3;
    double phase = (value - delay) % 1.0;
    if (phase < 0) phase += 1.0;
    return phase < period ? 1.0 - (phase / period) : 0.2;
  }
}