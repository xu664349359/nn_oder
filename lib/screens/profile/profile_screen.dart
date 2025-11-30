import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nn_oder/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _snapController;
  Animation<double>? _snapAnimation;
  final ScrollController _scrollController = ScrollController();
  double _cardOffset = 0.0;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _snapController.addListener(() {
      if (_snapAnimation != null) {
        setState(() {
          _cardOffset = _snapAnimation!.value;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _snapController.dispose();
    _scrollController.dispose();
    super.dispose();
  }



  Future<void> _pickBackgroundImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Background',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Background',
          ),
        ],
      );

      if (croppedFile != null) {
        // Upload to cloud
        try {
          await context.read<AuthProvider>().updateProfileBackground(croppedFile.path);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update background: $e')),
            );
          }
        }
      }
    }
  }

  void _runSnapAnimation(double targetOffset) {
    _snapAnimation = Tween<double>(
      begin: _cardOffset,
      end: targetOffset,
    ).animate(CurvedAnimation(
      parent: _snapController,
      curve: Curves.easeOutCubic, // Smooth deceleration
    ));
    
    _snapController.forward(from: 0);
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
          // Background layer (Parallax/Blur controlled by scroll)
          Positioned.fill(
            child: Stack(
              children: [
                // 1. Full screen blurred background (Always visible for top/bottom edges)
                if (user.backgroundImageUrl != null)
                  Positioned.fill(
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                      child: Image.network(
                        user.backgroundImageUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
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
                
                // 2. Main Image (Sharp) - Moves towards center on pull-down
                if (user.backgroundImageUrl != null)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _pulseController, // Just to keep it alive if needed, but setState handles the drag
                      builder: (context, child) {
                        // Calculate alignment: -1.0 (top) to 0.0 (center) based on drag
                        final progress = (_cardOffset / maxDragDistance).clamp(0.0, 1.0);
                        final alignmentY = -1.0 + (progress * 1.0);
                        
                        return Align(
                          alignment: Alignment(0.0, alignmentY),
                          child: ShaderMask(
                            shaderCallback: (rect) {
                              return const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
                                stops: [0.0, 0.1, 0.9, 1.0], // Tighter fade to show more image
                              ).createShader(rect);
                            },
                            blendMode: BlendMode.dstIn,
                            child: Image.network(
                              user.backgroundImageUrl!,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                // 3. White overlay - Pushed down by drag
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    // The white overlay starts at the middle of the card
                    // We start slightly higher (-50) and use a longer gradient for smoothness
                    final topPosition = initialPosition + _cardOffset + 100 - 50; 
                    
                    return Positioned(
                      top: topPosition,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.0),
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0.8),
                              Colors.white,
                            ],
                            stops: const [0.0, 0.2, 0.5, 1.0], // Much smoother transition
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Scrollable Content with Pull-to-Snap behavior
          Listener(
            onPointerMove: (event) {
              final delta = event.delta.dy;
              
              // If we are expanded, or at the top and pulling down
              if (_cardOffset > 0 || (_scrollController.hasClients && _scrollController.offset <= 0 && delta > 0)) {
                setState(() {
                  _cardOffset += delta;
                  // Clamp between 0 and maxDragDistance (plus some overscroll resistance if desired)
                  if (_cardOffset < 0) _cardOffset = 0;
                  if (_cardOffset > maxDragDistance) _cardOffset = maxDragDistance + (_cardOffset - maxDragDistance) * 0.1;
                });
              }
            },
            onPointerUp: (event) {
              // Snap logic with animation
              if (_cardOffset > 0) {
                final target = (_cardOffset > maxDragDistance / 2) ? maxDragDistance : 0.0;
                _runSnapAnimation(target);
              }
            },
            child: Transform.translate(
              offset: Offset(0, _cardOffset),
              child: CustomScrollView(
                controller: _scrollController,
                // Disable scrolling when expanded to prevent conflict
                physics: _cardOffset > 0 
                    ? const NeverScrollableScrollPhysics() 
                    : const ClampingScrollPhysics(),
                slivers: [
                  // AppBar Placeholder (invisible, just for spacing if needed, or remove expandedHeight if we want card higher)
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    pinned: false, // Don't pin, let it scroll away
                    expandedHeight: initialPosition, 
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(color: Colors.transparent),
                    ),
                    // No title, no actions
                  ),

                  // Pink Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                          backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                                              ? NetworkImage(user.avatarUrl!)
                                              : null,
                                          child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                                              ? Text(
                                                  user.role == UserRole.chef ? '👨‍🍳' : '🐛',
                                                  style: const TextStyle(fontSize: 40),
                                                )
                                              : null,
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
                                    
                                    // Partner Avatar
                                    Consumer<AuthProvider>(
                                      builder: (context, auth, child) {
                                        final partner = auth.partnerUser;
                                        return Column(
                                          children: [
                                            CircleAvatar(
                                              radius: 40,
                                              backgroundColor: Colors.white.withOpacity(0.8),
                                              backgroundImage: partner?.avatarUrl != null && partner!.avatarUrl!.isNotEmpty
                                                  ? NetworkImage(partner.avatarUrl!)
                                                  : null,
                                              child: (partner?.avatarUrl == null || partner!.avatarUrl!.isEmpty)
                                                  ? Text(
                                                      partner?.role == UserRole.chef ? '👨‍🍳' : '🐛',
                                                      style: const TextStyle(fontSize: 40),
                                                    )
                                                  : null,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              partner?.nickname ?? 'Waiting...',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
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

                  // Moments Title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                      child: Text(
                        'Moments',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ),

                  // Moments List
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // Mock data
                        final moments = [
                          {
                            'userName': 'Chef Alex',
                            'content': 'Just made a delicious pasta! 🍝',
                            'time': '12:30',
                            'likes': 5,
                          },
                          {
                            'userName': 'Foodie Sam',
                            'content': 'Can\'t wait for dinner! 😋',
                            'time': '09:15',
                            'likes': 2,
                          },
                          {
                            'userName': 'Chef Alex',
                            'content': 'Testing the new recipe editor! 🎥',
                            'time': 'Yesterday',
                            'likes': 8,
                          },
                          {
                            'userName': 'Foodie Sam',
                            'content': 'Love the new menu updates! ❤️',
                            'time': 'Yesterday',
                            'likes': 4,
                          },
                        ];
                        
                        if (index >= moments.length) return null;
                        
                        final moment = moments[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.primary,
                                    child: Text((moment['userName'] as String)[0]),
                                  ),
                                  title: Text(moment['userName'] as String),
                                  subtitle: Text(
                                    moment['time'] as String,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Text(moment['content'] as String),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.favorite_border),
                                        onPressed: () {},
                                      ),
                                      Text('${moment['likes']}'),
                                      const SizedBox(width: 16),
                                      IconButton(
                                        icon: const Icon(Icons.comment),
                                        onPressed: () {},
                                      ),
                                      const Text('Comment'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: 4,
                    ),
                  ),
                  
                  // Bottom padding
                  const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
                ],
              ),
            ),
          ),

          // Fixed AppBar Icons (Top Right)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false, // No back button
              actions: [
                IconButton(
                  icon: const Icon(Icons.image, color: Colors.white),
                  onPressed: _pickBackgroundImage,
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () => context.push('/settings'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
