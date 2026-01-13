import 'dart:async';
import 'package:shopdhika/onboardingpage.dart';
import 'package:flutter/material.dart';

class SplashScreenState extends StatefulWidget {
  const SplashScreenState({Key? key}) : super(key: key);

  @override
  State<SplashScreenState> createState() => _SplashScreenStateState();
}

class _SplashScreenStateState extends State<SplashScreenState> {
  @override
  void initState() {
    super.initState();
    Timer(
        const Duration(seconds: 3),
        () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => OnboardingPage())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("./lib/images/cart.png", scale: 1.2),
            const Text("Pal Store", style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
