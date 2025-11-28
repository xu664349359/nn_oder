import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start navigation after animation (slightly longer for the slow ease)
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        _navigate();
      }
    });
  }

  void _navigate() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      context.go('/login');
    } else {
      if (user.partnerId == null) {
        context.go('/binding');
      } else {
        if (user.role == UserRole.chef) {
          context.go('/chef/home');
        } else {
          context.go('/foodie/home');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Dark Background (Base)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2E1A47), Color(0xFF4A2B5E)], // Deep Mystic Purple
              ),
            ),
          ),

          // 2. Light Warm Background (Fade In)
          // "Background from deep soft gradient -> light warm"
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.splashGradient,
            ),
          )
              .animate()
              .fadeIn(duration: 1500.ms, curve: Curves.easeOutQuint), // Opacity 0 -> 100%

          // 3. Center Glowing Ring (The "Hazy" element)
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 1500.ms, curve: Curves.easeOutQuint) // Opacity 0 -> 100%
              .blur(
                begin: const Offset(24, 24),
                end: const Offset(0, 0),
                duration: 1500.ms,
                curve: Curves.easeOutQuint,
              ) // Blur 24px -> 0px
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.1, 1.1),
                duration: 2000.ms,
                curve: Curves.easeOutSine,
              ),
        ],
      ),
    );
  }
}
