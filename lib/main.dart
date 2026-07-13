import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'home_screen.dart';
import 'registro_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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

    Future.delayed(const Duration(seconds: 2), () {
      _navegarSiguiente();
    });
  }

  Future<void> _navegarSiguiente() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RegistroScreen()),
        );
      }
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();

    if (!mounted) return;

    if (doc.exists) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RegistroScreen()),
        );
      }
    }
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