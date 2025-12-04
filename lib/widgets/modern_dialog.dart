import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants.dart';

class ModernDialog extends StatelessWidget {
  final String title;
  final Widget? content;
  final String? description;
  final List<Widget>? actions;
  final IconData? icon;
  final Color? iconColor;

  const ModernDialog({
    super.key,
    required this.title,
    this.content,
    this.description,
    this.actions,
    this.icon,
    this.iconColor,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    Widget? content,
    String? description,
    List<Widget>? actions,
    IconData? icon,
    Color? iconColor,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => ModernDialog(
        title: title,
        content: content,
        description: description,
        actions: actions,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with Icon
              if (icon != null) ...[
                const SizedBox(height: 32),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: iconColor ?? AppColors.primary,
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
              ],
              
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              if (description != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                    description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              if (content != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: content!,
                ),

              const SizedBox(height: 24),

              // Actions
              if (actions != null && actions!.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.05),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions!.map((action) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: action,
                      );
                    }).toList(),
                  ),
                )
              else
                const SizedBox(height: 8),
            ],
          ),
        ).animate().fade(duration: 300.ms).scale(duration: 300.ms, curve: Curves.easeOutBack),
      ),
    );
  }
}
