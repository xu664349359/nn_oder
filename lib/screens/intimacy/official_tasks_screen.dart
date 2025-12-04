import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/intimacy_task_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import 'task_detail_screen.dart';

class OfficialTasksScreen extends StatefulWidget {
  final TaskType type; // weekend or bounty

  const OfficialTasksScreen({super.key, required this.type});

  @override
  State<OfficialTasksScreen> createState() => _OfficialTasksScreenState();
}

class _OfficialTasksScreenState extends State<OfficialTasksScreen> {
  final _supabaseService = SupabaseService();
  bool _isLoading = true;
  List<IntimacyTask> _tasks = [];
  List<TaskExecution> _myExecutions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user == null) return;

      final tasks = await _supabaseService.getIntimacyTasks(
        type: widget.type,
      );
      
      final executions = await _supabaseService.getTaskExecutions(user.id);
      
      if (mounted) {
        setState(() {
          _tasks = tasks;
          _myExecutions = executions;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == TaskType.weekend ? 'Weekend Battle' : 'Bounty Hunter';
    final gradient = widget.type == TaskType.weekend
        ? const LinearGradient(colors: [Color(0xFFFEF3C7), Color(0xFFFFF7ED)])
        : const LinearGradient(colors: [Color(0xFFF3E8FF), Color(0xFFFAF5FF)]);
    final icon = widget.type == TaskType.weekend ? Icons.weekend : Icons.stars;
    final color = widget.type == TaskType.weekend ? Colors.orange : Colors.purple;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                final isClaimed = _myExecutions.any((e) => e.taskId == task.id);
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Column(
                      children: [
                        // Banner
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(gradient: gradient),
                          child: Stack(
                            children: [
                              Positioned(
                                right: -20,
                                top: -20,
                                child: Icon(
                                  icon,
                                  size: 150,
                                  color: color.withOpacity(0.1),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${task.rewardPoints} Points',
                                        style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                task.description ?? '',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: isClaimed
                                    ? OutlinedButton.icon(
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => TaskDetailScreen(task: task),
                                          ),
                                        ),
                                        icon: const Icon(Icons.check),
                                        label: const Text('View Details'),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        ),
                                      )
                                    : ElevatedButton(
                                        onPressed: () async {
                                          final user = context.read<AuthProvider>().currentUser;
                                          await _supabaseService.claimTask(task.id, user!.id);
                                          _loadData();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: color,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          elevation: 0,
                                        ),
                                        child: const Text('Accept Challenge'),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
