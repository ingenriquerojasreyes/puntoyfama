import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(const NumleApp());
}

class NumleApp extends StatelessWidget {
  const NumleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NUMLE',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'NUMLE',
                style: TextStyle(
                  color: Color(0xFF534AB7),
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 12,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '•',
                style: TextStyle(
                  color: Color(0xFF534AB7),
                  fontSize: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}