import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Existing pages
import 'pages/splash_screen.dart';
import 'pages/launch_page.dart';
import 'pages/welcome_page.dart'; // Login page
import 'pages/create_account_page.dart';
import 'pages/forgot_password_page.dart';
import 'pages/security_pin_page.dart';
import 'pages/my_profile.dart';
import 'pages/others_profile.dart';

// New post-login pages
import 'pages/main_navigation_page.dart'; // <- new file we'll add
import 'pages/home_page.dart';
import 'pages/rooms_page.dart';
import 'pages/friends_page.dart';

import 'pages/notifications_page.dart';
import 'pages/add_friend_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spendee',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00B686)),
        scaffoldBackgroundColor: const Color(0xFFE6F8F0),
        useMaterial3: true,
      ),

      // Start from splash screen
      initialRoute: '/',

      routes: {
        '/': (context) => const SplashScreen(),
        '/launch': (context) => const LaunchPage(),
        '/login': (context) => const LoginPage(),
        '/create-account': (context) => const CreateAccountPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/security-pin': (context) => const SecurityPinPage(),
        '/my-profile': (context) => const ProfilePage(),
        '/others-profile': (context) => const OthersProfileViewPage(),

        // 🧭 Main post-login navigation shell
        '/main': (context) => const MainNavigationPage(),
      },
    );
  }
}
