import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nn_oder/l10n/generated/app_localizations.dart';
import '../../core/constants.dart';
import '../../providers/data_provider.dart';
import '../../models/intimacy_task_model.dart';
import '../intimacy/couple_tasks_screen.dart';
import '../intimacy/official_tasks_screen.dart';

class IntimacyManagementScreen extends StatefulWidget {
  const IntimacyManagementScreen({super.key});

  @override
  State<IntimacyManagementScreen> createState() => _IntimacyManagementScreenState();
}

class _IntimacyManagementScreenState extends State<IntimacyManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final intimacyBalance = context.watch<DataProvider>().intimacyBalance;
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // Background Elements
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Floating Decorations (Simulated 3D objects)
          _buildFloatingIcon(Icons.favorite, Colors.redAccent, 50, 100, 2.0),
          _buildFloatingIcon(Icons.star, Colors.amber, 300, 150, 3.0),
          _buildFloatingIcon(Icons.local_dining, Colors.orange, 80, 500, 2.5),
          
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          l10n.intimacyCenter,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fadeIn().slideY(begin: -0.5, end: 0),
                        const SizedBox(height: 30),
                        _build3DGlassCard(intimacyBalance, l10n),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildListDelegate([
                    _buildGridCard(
                      context,
                      title: l10n.intimacyMissions,
                      subtitle: l10n.postForPoints,
                      icon: Icons.favorite,
                      isPrimary: false,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CoupleTasksScreen()),
                      ),

                      delay: 200,
                      l10n: l10n,
                      backgroundImage: 'assets/images/intimacy_card_bg.png',
                    ),
                    _buildGridCard(
                      context,
                      title: l10n.quickAction,
                      subtitle: l10n.acceptByPicture,
                      icon: Icons.camera_alt,
                      isPrimary: true,
                      onTap: () {
                        // Navigate to camera or quick action
                      },
                      delay: 300,
                      l10n: l10n,
                      backgroundImage: 'assets/images/intimacy_card_bg.png',
                    ),
                    _buildGridCard(
                      context,
                      title: l10n.weekendChallenge,
                      subtitle: l10n.officialTasks,
                      icon: Icons.weekend,
                      isPrimary: false,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OfficialTasksScreen(type: TaskType.weekend)),
                      ),
                      delay: 400,
                      l10n: l10n,
                      backgroundImage: 'assets/images/intimacy_card_bg.png',
                    ),
                    _buildGridCard(
                      context,
                      title: l10n.bountyHunter,
                      subtitle: l10n.specialMissions,
                      icon: Icons.stars,
                      isPrimary: false,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OfficialTasksScreen(type: TaskType.bounty)),
                      ),
                      delay: 500,
                      l10n: l10n,
                      backgroundImage: 'assets/images/intimacy_card_bg.png',
                    ),
                  ]),
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _build3DGlassCard(int score, AppLocalizations l10n) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(-0.1),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Base Shadow/Platform
          Transform.translate(
            offset: const Offset(0, 40),
            child: Container(
              width: 200,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          // Glass Card
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 240,
                height: 140,
                decoration: BoxDecoration(
                  gradient: AppColors.glassGradient,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.glassBorder, width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.intimacyPoint,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '\$$score',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black26, blurRadius: 10)],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '.00',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .moveY(begin: 0, end: -10, duration: 3.seconds, curve: Curves.easeInOut);
  }

  Widget _buildGridCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
    required int delay,
    required AppLocalizations l10n,
    String? backgroundImage,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isPrimary ? null : AppColors.cardSurface,
        gradient: isPrimary ? AppColors.peachGradient : null,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
               if (backgroundImage != null)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Opacity(
                    opacity: 0.5,
                    child: Image.asset(
                      backgroundImage,
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                      errorBuilder: (_,__,___) => const SizedBox(),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isPrimary ? Colors.white.withOpacity(0.2) : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: isPrimary ? Colors.white : Colors.black87,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isPrimary ? Colors.white : Colors.black87,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isPrimary ? Colors.white.withOpacity(0.8) : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isPrimary ? Colors.white : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      // child: Row(
                      //   mainAxisSize: MainAxisSize.min,
                      //   children: [
                      //     Text(
                      //       l10n.open,
                      //       style: TextStyle(
                      //         fontSize: 12,
                      //         fontWeight: FontWeight.bold,
                      //         color: isPrimary ? AppColors.accent : Colors.black87,
                      //       ),
                      //     ),
                      //     const SizedBox(width: 4),
                      //     Icon(
                      //       Icons.keyboard_arrow_down,
                      //       size: 14,
                      //       color: isPrimary ? AppColors.accent : Colors.black87,
                      //     ),
                      //   ],
                      // ),
                    ),
                  ],
                ),
              ),
              if (backgroundImage != null)
                Positioned(
                  right: -20,
                  top: 0,
                  child: Opacity(
                    opacity: 0.5,
                    child: Image.asset(
                      backgroundImage,
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                      errorBuilder: (_,__,___) => const SizedBox(),
                    ),
                  ),
                ),
              // Decorative Circle
              Positioned(
                right: -20,
                top: 40,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        (isPrimary ? Colors.white : Colors.grey).withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildFloatingIcon(IconData icon, Color color, double left, double top, double duration) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Icon(icon, color: color, size: 24),
      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
       .moveY(begin: 0, end: -20, duration: duration.seconds, curve: Curves.easeInOut),
    );
  }
}
