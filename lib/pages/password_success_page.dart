import 'package:flutter/material.dart';

class PasswordSuccessPage extends StatefulWidget {
  const PasswordSuccessPage({super.key});

  @override
  State<PasswordSuccessPage> createState() => _PasswordSuccessPageState();
}

class _PasswordSuccessPageState extends State<PasswordSuccessPage>
    with TickerProviderStateMixin {
  late AnimationController _dotsController;
  late AnimationController _tickController;
  bool showTick = false;

  @override
  void initState() {
    super.initState();

    // Three-dot looping animation
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    // After few seconds, stop dots & show tick
    //then reroute to login page

    Future.delayed(const Duration(seconds: 2), () {
      _dotsController.stop();
      setState(() => showTick = true);
      _tickController.forward();
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/login');
      });
    });


    // Tick animation
    _tickController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _dotsController.dispose();
    _tickController.dispose();
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
            // Circle
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xFF00D09E), width: 5),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF00D09E),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: showTick
                      ? ScaleTransition(
                          scale: CurvedAnimation(
                            parent: _tickController,
                            curve: Curves.easeOutBack,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color: Color(0xFF00D09E),
                            size: 70,
                          ),
                        )
                      : _buildLoadingDots(),
                ),
              ),
            ),

            const SizedBox(height: 30),
            Text(
              "Password Reset Successful!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00D09E),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "You can now log in with your new password.",
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingDots() {
    return AnimatedBuilder(
      animation: _dotsController,
      builder: (context, child) {
        final value = _dotsController.value;
        final dotOpacities = [
          _opacityForDot(value, 0.0),
          _opacityForDot(value, 0.33),
          _opacityForDot(value, 0.66),
        ];
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return Opacity(
              opacity: dotOpacities[index],
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Color(0xFF00D09E),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  double _opacityForDot(double value, double delay) {
    const double period = 1 / 3;
    double phase = (value - delay) % 1.0;
    if (phase < 0) phase += 1.0;
    return phase < period ? 1.0 - (phase / period) : 0.2;
  }
}
