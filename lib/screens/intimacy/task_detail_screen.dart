import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';
import '../../models/intimacy_task_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../widgets/modern_dialog.dart';

class TaskDetailScreen extends StatefulWidget {
  final IntimacyTask task;
  final TaskExecution? execution; // If null, user hasn't claimed it yet (or we need to fetch)

  const TaskDetailScreen({super.key, required this.task, this.execution});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _supabaseService = SupabaseService();
  final _picker = ImagePicker();
  bool _isLoading = false;
  TaskExecution? _execution;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _execution = widget.execution;
    if (_execution == null) {
      _loadExecution();
    }
  }

  Future<void> _loadExecution() async {
    // Check if current user has an execution for this task
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    final executions = await _supabaseService.getTaskExecutions(user.id);
    try {
      final existing = executions.firstWhere((e) => e.taskId == widget.task.id);
      if (mounted) setState(() => _execution = existing);
    } catch (e) {
      // Not found
    }
  }

  Future<void> _claimTask() async {
    setState(() => _isLoading = true);
    try {
      final user = context.read<AuthProvider>().currentUser;
      await _supabaseService.claimTask(widget.task.id, user!.id);
      
      // Simulate refresh
      final executions = await _supabaseService.getTaskExecutions(user.id);
      final newExecution = executions.firstWhere((e) => e.taskId == widget.task.id);
      
      if (mounted) {
        setState(() {
          _execution = newExecution;
          _isLoading = false;
          _showConfetti = true;
        });
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _showConfetti = false);
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _submitProof() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => _isLoading = true);
    try {
      final url = await _supabaseService.uploadTaskProof(pickedFile.path, _execution!.id);
      await _supabaseService.submitTaskProof(_execution!.id, url);
      
      if (mounted) {
        setState(() {
          _execution = _execution!.copyWith(
            status: TaskStatus.submitted,
            proofImageUrl: url,
          );
          _isLoading = false;
        });
        HapticFeedback.mediumImpact();
        Navigator.pop(context); // Go back to refresh list
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _approveTask() async {
    // This should only be called if the current user is the creator (for couple tasks)
    // or admin (for official tasks - but admins might not use this app).
    // For couple tasks, the partner approves.
    // Let's assume the viewer is the creator/partner.
    
    setState(() => _isLoading = true);
    try {
      await _supabaseService.approveTask(
        _execution!.id, 
        _execution!.userId, // The user who did the task
        widget.task.rewardPoints,
      );
      
      if (mounted) {
        setState(() {
          _execution = _execution!.copyWith(
            status: TaskStatus.approved,
            completedAt: DateTime.now(),
          );
          _isLoading = false;
          _showConfetti = true;
        });
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _showConfetti = false);
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final isCreator = user?.id == widget.task.creatorId;
    final isMyExecution = _execution?.userId == user?.id;
    final statusIndex = _execution == null ? 0 : TaskStatus.values.indexOf(_execution!.status) + 1;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    widget.task.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.romanticGradient,
                    ),
                    child: Center(
                      child: Icon(
                        widget.task.type == TaskType.couple ? Icons.favorite : Icons.star,
                        size: 80,
                        color: Colors.white.withOpacity(0.3),
                      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                       .scale(duration: 2.seconds, begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Reward Badge
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                          ),
                          child: Text(
                            '🏆 Reward: ${widget.task.rewardPoints} Points',
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),
                      ),
                      const SizedBox(height: 24),
                      
                      // Description
                      const Text(
                        'Mission Brief',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ).animate().fadeIn().slideX(),
                      const SizedBox(height: 8),
                      Text(
                        widget.task.description ?? 'No description provided.',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.6),
                      ).animate().fadeIn(delay: 100.ms).slideX(),
                      const SizedBox(height: 32),

                      // Progress Stepper
                      const Text(
                        'Progress',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ).animate().fadeIn(delay: 200.ms).slideX(),
                      const SizedBox(height: 16),
                      _buildStepper(statusIndex).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 32),

                      // Actions
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (_execution == null)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              _claimTask();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('Accept Challenge', style: TextStyle(fontSize: 18)),
                          ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
                        )
                      else ...[
                        // Proof Image
                        if (_execution!.proofImageUrl != null) ...[
                          const Text(
                            'Proof Submission',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ).animate().fadeIn(),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              _execution!.proofImageUrl!,
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ).animate().fadeIn().scale(),
                          const SizedBox(height: 24),
                        ],

                        // Action Buttons
                        if (isMyExecution && _execution!.status == TaskStatus.claimed)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                _submitProof();
                              },
                              icon: const Icon(Icons.upload),
                              label: const Text('Upload Proof'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ).animate().slideY(begin: 0.2, end: 0),
                        
                        if (isCreator && _execution!.status == TaskStatus.submitted)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                _approveTask();
                              },
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Approve & Award Points'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ).animate().slideY(begin: 0.2, end: 0),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_showConfetti)
          Positioned.fill(
            child: IgnorePointer(
              child: _buildConfetti(),
            ),
          ),
      ],
    );
  }

  Widget _buildStepper(int currentIndex) {
    const steps = ['Available', 'Claimed', 'Submitted', 'Approved'];
    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          return Expanded(
            child: Container(
              height: 2,
              color: index ~/ 2 < currentIndex - 1 ? AppColors.primary : Colors.grey[300],
            ).animate(target: index ~/ 2 < currentIndex - 1 ? 1 : 0).tint(color: AppColors.primary),
          );
        }
        final stepIndex = index ~/ 2;
        final isActive = stepIndex < currentIndex;
        final isCurrent = stepIndex == currentIndex - 1;
        
        return Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.grey[200],
                shape: BoxShape.circle,
                border: isCurrent ? Border.all(color: AppColors.primary, width: 2) : null,
              ),
              child: Center(
                child: isActive
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Text('${stepIndex + 1}', style: TextStyle(color: Colors.grey[500])),
              ),
            ).animate(target: isActive ? 1 : 0).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
            const SizedBox(height: 4),
            Text(
              steps[stepIndex],
              style: TextStyle(
                fontSize: 10,
                color: isActive ? AppColors.primary : Colors.grey[500],
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildConfetti() {
    // Simple confetti simulation using random positioned containers
    // In a real app, use a package like 'confetti'
    return Stack(
      children: List.generate(50, (index) {
        final random = Random();
        return Positioned(
          left: random.nextDouble() * MediaQuery.of(context).size.width,
          top: -20,
          child: Container(
            width: 10,
            height: 10,
            color: Colors.primaries[random.nextInt(Colors.primaries.length)],
          ).animate()
           .moveY(begin: 0, end: MediaQuery.of(context).size.height, duration: (1 + random.nextDouble()).seconds)
           .rotate(duration: 1.seconds)
           .fadeOut(delay: 1.5.seconds),
        );
      }),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.claimed: return Colors.blue;
      case TaskStatus.submitted: return Colors.orange;
      case TaskStatus.approved: return Colors.green;
      case TaskStatus.rejected: return Colors.red;
    }
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.claimed: return Icons.timelapse;
      case TaskStatus.submitted: return Icons.upload_file;
      case TaskStatus.approved: return Icons.check_circle;
      case TaskStatus.rejected: return Icons.cancel;
    }
  }
}
