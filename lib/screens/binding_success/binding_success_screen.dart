import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class BindingSuccessScreen extends StatefulWidget {
  const BindingSuccessScreen({super.key});

  @override
  State<BindingSuccessScreen> createState() => _BindingSuccessScreenState();
}

class _BindingSuccessScreenState extends State<BindingSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _heartbeatController;

  @override
  void initState() {
    super.initState();
    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Navigate after animation completes
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        final user = context.read<AuthProvider>().currentUser;
        if (user?.role == UserRole.chef) {
          context.go('/chef/home');
        } else {
          context.go('/foodie/home');
        }
      }
    });

    // Start heartbeat at 0.7s
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        _heartbeatController.forward().then((_) {
          _heartbeatController.reverse();
        });
      }
    });
  }

  @override
  void dispose() {
    _heartbeatController.dispose();
    super.dispose();
  }

  String _getAvatar(UserRole role) {
    return role == UserRole.chef ? '👨‍🍳' : '🐛';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) return const SizedBox();

    final partnerRole = user.role == UserRole.chef ? UserRole.foodie : UserRole.chef;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background particles
          ...List.generate(20, (index) {
            return Positioned(
              left: (index * 50.0) % MediaQuery.of(context).size.width,
              top: (index * 80.0) % MediaQuery.of(context).size.height,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              )
                  .animate()
                  .fadeIn(delay: (index * 50).ms, duration: 400.ms)
                  .scale(begin: const Offset(0, 0), end: const Offset(1, 1)),
            );
          }),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar collision section
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Collision light wave (0.2s - 0.4s)
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.3),
                            AppColors.accent.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    )
                        .animate(delay: 200.ms)
                        .fadeIn(duration: 100.ms)
                        .scale(
                          begin: const Offset(0.5, 0.5),
                          end: const Offset(2, 2),
                          duration: 200.ms,
                          curve: Curves.easeOut,
                        )
                        .fadeOut(duration: 100.ms, delay: 100.ms),

                    // Energy line (0.4s - 0.7s)
                    Container(
                      width: 120,
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.accent,
                            AppColors.primary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    )
                        .animate(delay: 400.ms)
                        .scaleX(
                          begin: 0,
                          end: 1,
                          duration: 300.ms,
                          curve: Curves.easeInOut,
                        )
                        .fadeIn(duration: 200.ms),

                    // Heart Logo (0.7s - 1.0s)
                    AnimatedBuilder(
                      animation: _heartbeatController,
                      builder: (context, child) {
                        final scale = 1.0 + (_heartbeatController.value * 0.2);
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: const Icon(
                        Icons.favorite,
                        size: 60,
                        color: AppColors.primary,
                      )
                          .animate(delay: 700.ms)
                          .fadeIn(duration: 200.ms)
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1, 1),
                            duration: 300.ms,
                            curve: Curves.elasticOut,
                          ),
                    ),

                    // Left avatar (Chef)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _getAvatar(user.role),
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                        )
                            .animate()
                            .slideX(
                              begin: -3,
                              end: 0,
                              duration: 200.ms,
                              curve: Curves.easeOut,
                            )
                            .fadeIn(duration: 150.ms),

                        const SizedBox(width: 10),

                        // Right avatar (Partner)
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.accent, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _getAvatar(partnerRole),
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                        )
                            .animate()
                            .slideX(
                              begin: 3,
                              end: 0,
                              duration: 200.ms,
                              curve: Curves.easeOut,
                            )
                            .fadeIn(duration: 150.ms),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                // Success text (1.0s - 1.4s)
                Text(
                  '绑定成功！',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    shadows: [
                      Shadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                )
                    .animate(delay: 1000.ms)
                    .fadeIn(duration: 200.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      duration: 400.ms,
                      curve: Curves.easeOut,
                    )
                    .moveY(begin: 10, end: 0, duration: 400.ms),

                const SizedBox(height: 20),

                // Role labels (1.4s - 1.8s)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user.role == UserRole.chef ? 'Chef' : 'Foodie',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                        .animate(delay: 1400.ms)
                        .fadeIn(duration: 200.ms)
                        .slideY(begin: 0.5, end: 0),

                    const SizedBox(width: 80),

                    Text(
                      partnerRole == UserRole.chef ? 'Chef' : 'Foodie',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                        .animate(delay: 1400.ms)
                        .fadeIn(duration: 200.ms)
                        .slideY(begin: 0.5, end: 0),
                  ],
                ),
              ],
            ),
          ),

          // Heart particles burst (1.4s - 1.8s)
          ...List.generate(15, (index) {
            final angle = (index / 15) * 2 * 3.14159;
            final distance = 100.0;
            return Positioned(
              left: MediaQuery.of(context).size.width / 2 + (distance * (index % 3 - 1) * 0.8),
              top: MediaQuery.of(context).size.height / 2 + (distance * ((index ~/ 3) - 2) * 0.8),
              child: Icon(
                Icons.favorite,
                size: 12,
                color: AppColors.primary.withOpacity(0.6),
              )
                  .animate(delay: 1400.ms)
                  .fadeIn(duration: 100.ms)
                  .moveX(
                    begin: 0,
                    end: (index % 3 - 1) * 80.0,
                    duration: 400.ms,
                    curve: Curves.easeOut,
                  )
                  .moveY(
                    begin: 0,
                    end: ((index ~/ 3) - 2) * 80.0,
                    duration: 400.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeOut(duration: 200.ms, delay: 200.ms),
            );
          }),
        ],
      )
          .animate(delay: 1800.ms)
          .fadeOut(duration: 400.ms), // Whole page fade out
    );
  }
}
