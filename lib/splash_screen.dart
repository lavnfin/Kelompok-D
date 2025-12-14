import 'package:flutter/material.dart';
import 'dart:math';
import 'home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Controller untuk animasi gradient
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(); // Gradient bergerak terus

    // Auto pindah ke HomePage setelah 2.5 detik
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
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
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,

                // Gradient bergerak mengikuti sin & cos animasi
                colors: [
                  Color.lerp(
                    const Color(0xFFFFC27F),
                    const Color(0xFFE57C23),
                    sin(_controller.value * 2 * pi),
                  )!,
                  Color.lerp(
                    const Color(0xFFEDE0C8),
                    const Color(0xFFE5B344),
                    cos(_controller.value * 2 * pi),
                  )!,
                ],
              ),
            ),
            child: child,
          );
        },

        // Bagian konten: Logo + Teks
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // GANTI DENGAN LOGO KAMU
              // Image.asset("assets/logo.jpg", width: 120),

              const Icon(
                Icons.menu_book_rounded,
                size: 100,
                color: Colors.white,
              ),

              const SizedBox(height: 20),

              const Text(
                "NOTELEARN",
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

