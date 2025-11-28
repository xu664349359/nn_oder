import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';

class UnboundProfileScreen extends StatelessWidget {
  const UnboundProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.romanticGradient,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () => context.push('/settings'),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),

                // Avatars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Self
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Text(
                            user.nickname[0].toUpperCase(),
                            style: const TextStyle(fontSize: 40, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.nickname,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(width: 40),
                    
                    // Partner (Empty)
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () => context.push('/unbound/invite'),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.3),
                              border: Border.all(color: Colors.white, width: 2, style: BorderStyle.solid),
                            ),
                            child: const Icon(Icons.add, size: 40, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Waiting...',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Spacer(flex: 2),
                
                const Text(
                  'Tap + to connect with your partner',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
