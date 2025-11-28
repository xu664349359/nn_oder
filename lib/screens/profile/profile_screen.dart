import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  double _cardOffset = 0.0;
  String? _backgroundImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickBackgroundImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _backgroundImagePath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) return const SizedBox();

    final screenHeight = MediaQuery.of(context).size.height;
    final initialPosition = screenHeight * 0.25; // Start showing some background
    final maxDragDistance = screenHeight * 0.45;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background layer with image/gradient
          // Background layer with image/gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight, // Full height to prevent resizing issues
            child: Stack(
              children: [
                // 1. Blurred Background Fill (for empty spaces)
                if (_backgroundImagePath != null)
                  Positioned.fill(
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                      child: Image.file(
                        File(_backgroundImagePath!),
                        fit: BoxFit.cover, // Fills the screen
                      ),
                    ),
                  ),

                // 2. Main Image (Sharp) with Dynamic Alignment
                if (_backgroundImagePath != null)
                  AnimatedBuilder(
                    animation: _pulseController, // Just to trigger rebuild
                    builder: (context, child) {
                      // Calculate alignment based on drag progress
                      // 0.0 -> topCenter
                      // maxDragDistance -> center
                      final progress = (_cardOffset / maxDragDistance).clamp(0.0, 1.0);
                      final alignmentY = -1.0 + (progress * 1.0); // -1.0 is top, 0.0 is center
                      
                      return Positioned.fill(
                        child: Align(
                          alignment: Alignment(0.0, alignmentY),
                          child: Image.file(
                            File(_backgroundImagePath!),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      );
                    },
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withOpacity(0.3),
                          AppColors.accent.withOpacity(0.5),
                          AppColors.primary.withOpacity(0.4),
                        ],
                      ),
                    ),
                  ),

                // Blur Effect (Gradient Blur) - Keeping this for the bottom fade of the main image
                Positioned.fill(
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.6, 1.0],
                        colors: [Colors.transparent, Colors.black],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.dstIn,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: _backgroundImagePath != null
                          ? AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                final progress = (_cardOffset / maxDragDistance).clamp(0.0, 1.0);
                                final alignmentY = -1.0 + (progress * 1.0);
                                return Align(
                                  alignment: Alignment(0.0, alignmentY),
                                  child: Image.file(
                                    File(_backgroundImagePath!),
                                    fit: BoxFit.fitWidth,
                                  ),
                                );
                              },
                            )
                          : Container(color: Colors.transparent),
                    ),
                  ),
                ),

                // Dynamic White Overlay (The "Curtain")
                AnimatedBuilder(
                  animation: _pulseController, // Trigger rebuild
                  builder: (context, child) {
                    final cardTop = initialPosition + _cardOffset;
                    final coverTop = cardTop + 80; // Start transitioning to white inside the card

                    return Positioned(
                      top: coverTop,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Column(
                        children: [
                          // Gradient Fade at the top of the white cover
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.0),
                                  Colors.white,
                                ],
                              ),
                            ),
                          ),
                          // Solid White Block
                          Expanded(
                            child: Container(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                ),


              ],
            ),
          ),

          // AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              title: const Text('Personal Center'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.image, color: Colors.white),
                  onPressed: _pickBackgroundImage,
                ),
              ],
            ),
          ),

          // Draggable pink card with couple avatars
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            top: initialPosition + _cardOffset,
            left: 16,
            right: 16,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                setState(() {
                  _cardOffset += details.delta.dy;
                  _cardOffset = _cardOffset.clamp(0.0, maxDragDistance);
                });
              },
              onVerticalDragEnd: (details) {
                setState(() {
                  if (_cardOffset > maxDragDistance / 3) {
                    _cardOffset = maxDragDistance;
                  } else {
                    _cardOffset = 0.0;
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.romanticGradient,
                  borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Drag indicator
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Avatars with connection line
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background connection line
                        Positioned(
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              final opacity = 0.3 + (_pulseController.value * 0.4);
                              return Container(
                                width: 100,
                                height: 3,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(opacity),
                                      Colors.white.withOpacity((opacity * 1.2).clamp(0.0, 1.0)),
                                      Colors.white.withOpacity(opacity),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(opacity * 0.8),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        
                        // Sparkle effect
                        Positioned(
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              final position = _pulseController.value * 80 - 40;
                              return Transform.translate(
                                offset: Offset(position, 0),
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.8),
                                        blurRadius: 12,
                                        spreadRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        
                        // Avatars and heart
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    user.nickname[0].toUpperCase(),
                                    style: const TextStyle(fontSize: 32, color: AppColors.primary),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  user.nickname,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            
                            // Animated heart
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                final scale = 1.0 + (_pulseController.value * 0.15);
                                return Transform.scale(
                                  scale: scale,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(_pulseController.value * 0.5),
                                          blurRadius: 15,
                                          spreadRadius: 3,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.favorite,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                );
                              },
                            ),
                            
                            Column(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.white.withOpacity(0.8),
                                  child: const Icon(Icons.person, size: 40, color: AppColors.primary),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Partner',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Settings list follows the pink card
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            left: 0,
            right: 0,
            top: initialPosition + _cardOffset + 280, // Below the pink card
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Settings'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/settings'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.broken_image, color: Colors.orange),
                      title: const Text('Unbind Partner'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Unbind?'),
                            content: const Text('This will delete all shared data. Are you sure?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Unbind not implemented yet.')),
                                  );
                                },
                                child: const Text('Unbind', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Logout'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await context.read<AuthProvider>().logout();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
