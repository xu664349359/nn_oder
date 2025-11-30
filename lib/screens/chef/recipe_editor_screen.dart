import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants.dart';
import '../../models/menu_model.dart';
import '../../services/supabase_service.dart';
import '../../widgets/video_player_dialog.dart' as vpd;

class RecipeEditorScreen extends StatefulWidget {
  final MenuItem menuItem;

  const RecipeEditorScreen({super.key, required this.menuItem});

  @override
  State<RecipeEditorScreen> createState() => _RecipeEditorScreenState();
}

class _RecipeEditorScreenState extends State<RecipeEditorScreen> {
  final _supabaseService = SupabaseService();
  List<RecipeStep> _steps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipeSteps();
  }

  Future<void> _loadRecipeSteps() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabaseService.getRecipeSteps(widget.menuItem.id);
      setState(() {
        _steps = data.map((e) => RecipeStep.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading recipe steps: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addStep() async {
    await showDialog(
      context: context,
      builder: (context) => _RecipeStepDialog(
        menuItemId: widget.menuItem.id,
        stepNumber: _steps.length + 1,
      ),
    );
    
    // Always reload after dialog closes
    await _loadRecipeSteps();
  }

  Future<void> _editStep(RecipeStep step) async {
    await showDialog(
      context: context,
      builder: (context) => _RecipeStepDialog(
        menuItemId: widget.menuItem.id,
        existingStep: step,
      ),
    );
    
    // Always reload after dialog closes
    await _loadRecipeSteps();
  }

  Future<void> _deleteStep(RecipeStep step) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Step'),
        content: const Text('Are you sure you want to delete this step?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && step.id != null) {
      await _supabaseService.deleteRecipeStep(step.id!);
      await _loadRecipeSteps();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe: ${widget.menuItem.name}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _steps.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No recipe steps yet'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _addStep,
                        icon: const Icon(Icons.add),
                        label: const Text('Add First Step'),
                      ),
                    ],
                  ),
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _steps.length,
                  onReorder: (oldIndex, newIndex) {
                    // TODO: Implement reordering
                  },
                  itemBuilder: (context, index) {
                    final step = _steps[index];
                    return _RecipeStepCard(
                      key: ValueKey(step.id),
                      step: step,
                      onEdit: () => _editStep(step),
                      onDelete: () => _deleteStep(step),
                    );
                  },
                ),
      floatingActionButton: _steps.isNotEmpty
          ? FloatingActionButton(
              onPressed: _addStep,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _RecipeStepCard extends StatelessWidget {
  final RecipeStep step;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RecipeStepCard({
    super.key,
    required this.step,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text('${step.stepNumber}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    step.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
            if (step.imageUrl != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  step.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            if (step.videoUrl != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  // Show video player dialog
                  showDialog(
                    context: context,
                    builder: (context) => vpd.VideoPlayerDialog(videoUrl: step.videoUrl!),
                  );
                },
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_circle_outline, size: 48),
                        SizedBox(height: 8),
                        Text('Tap to play video'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecipeStepDialog extends StatefulWidget {
  final String menuItemId;
  final RecipeStep? existingStep;
  final int? stepNumber;

  const _RecipeStepDialog({
    required this.menuItemId,
    this.existingStep,
    this.stepNumber,
  });

  @override
  State<_RecipeStepDialog> createState() => _RecipeStepDialogState();
}

class _RecipeStepDialogState extends State<_RecipeStepDialog> {
  final _descriptionController = TextEditingController();
  final _supabaseService = SupabaseService();
  String? _imageUrl;
  String? _videoUrl;
  File? _selectedImage;
  File? _selectedVideo;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingStep != null) {
      _descriptionController.text = widget.existingStep!.description;
      _imageUrl = widget.existingStep!.imageUrl;
      _videoUrl = widget.existingStep!.videoUrl;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);

    if (video != null) {
      final file = File(video.path);
      final fileSize = await file.length();

      // Check file size (limit to 50MB)
      if (fileSize > 50 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video size must be less than 50MB')),
        );
        return;
      }

      setState(() {
        _selectedVideo = file;
      });
    }
  }

  Future<void> _save() async {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final stepId = widget.existingStep?.id ?? const Uuid().v4();

      // Upload image if selected
      if (_selectedImage != null) {
        _imageUrl = await _supabaseService.uploadRecipeMedia(
          _selectedImage!.path,
          stepId,
          isVideo: false,
        );
      }

      // Upload video if selected
      if (_selectedVideo != null) {
        _videoUrl = await _supabaseService.uploadRecipeMedia(
          _selectedVideo!.path,
          stepId,
          isVideo: true,
        );
      }

      // Save step
      final stepData = {
        if (widget.existingStep?.id != null) 'id': widget.existingStep!.id,
        'menu_item_id': widget.menuItemId,
        'step_number': widget.existingStep?.stepNumber ?? widget.stepNumber ?? 1,
        'description': _descriptionController.text,
        if (_imageUrl != null) 'image_url': _imageUrl,
        if (_videoUrl != null) 'video_url': _videoUrl,
      };

      await _supabaseService.saveRecipeStep(stepData);

      if (!mounted) return;
      Navigator.pop(context); // Just close the dialog, parent will reload
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingStep != null ? 'Edit Step' : 'Add Step'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            // Image picker
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: Text(_selectedImage != null || _imageUrl != null
                  ? 'Change Image'
                  : 'Add Image (Optional)'),
            ),
            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_selectedImage!, height: 100, fit: BoxFit.cover),
                ),
              )
            else if (_imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(_imageUrl!, height: 100, fit: BoxFit.cover),
                ),
              ),
            
            const SizedBox(height: 12),
            
            // Video picker
            OutlinedButton.icon(
              onPressed: _pickVideo,
              icon: const Icon(Icons.videocam),
              label: Text(_selectedVideo != null || _videoUrl != null
                  ? 'Change Video'
                  : 'Add Video (Optional)'),
            ),
            if (_selectedVideo != null || _videoUrl != null)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Video selected'),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isUploading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isUploading ? null : _save,
          child: _isUploading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
