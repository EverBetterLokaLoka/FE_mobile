import 'package:flutter/material.dart';
import 'package:lokaloka/features/auth/screens/sign_up_screen.dart';

import '../../../core/styles/colors.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // image: DecorationImage(
          //   image: AssetImage("assets/SC_000_Background.png"),
          //   fit: BoxFit.cover,
          // ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD9A7C7), Color(0xFFFFFCDC)], // Gradient màu nền
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              'TRAVEL APP',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 20),

            const Text.rich(
              TextSpan(
                text: 'Enjoy your\nperfect ',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: 'journey',
                    style: TextStyle(color: AppColors.orangeColor),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Image.asset('assets/logo.png', width: 80),
            ),

            const SizedBox(height: 30),

            const Text(
              '“Easy trips, perfect journeys!”',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.white),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignUp(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orangeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: Text(
                'Get Started',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}