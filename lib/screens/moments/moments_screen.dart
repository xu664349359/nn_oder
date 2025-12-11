import 'package:flutter/material.dart';
import 'package:nn_oder/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/moment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';

class MomentsScreen extends StatefulWidget {
  const MomentsScreen({super.key});

  @override
  State<MomentsScreen> createState() => _MomentsScreenState();
}

class _MomentsScreenState extends State<MomentsScreen> {
  final TextEditingController _contentController = TextEditingController();
  // Image file var (generic to handle web/mobile if needed, but for simplicity assuming mobile File or XFile path logic handled in service/provider or helper)
  // Actually DataProvider expects dynamic imageFile (XFile or File). 
  // We need image_picker.
  
  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _showCreateMomentSheet(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.moments, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: 'Share your joy...', // l10n please? using hardcoded for speed as requested l10n not fully exposed here
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo_library),
                  onPressed: () {
                    // Implement Image Picker here
                    // For now just text or placeholder
                    // In a real step I'd add the picker logic inside this state or a separate widget
                  },
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    final content = _contentController.text;
                    if (content.isNotEmpty) {
                      context.read<DataProvider>().publishMoment(content, null); // passing null image for now to MVP
                      _contentController.clear();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(l10n.done), // 'Done' or 'Post'
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final moments = context.watch<DataProvider>().moments; // Watch real data
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.moments),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () => _showCreateMomentSheet(context, l10n),
          ),
        ],
      ),
      body: moments.isEmpty 
          ? Center(child: Text('No moments yet', style: TextStyle(color: Colors.grey[400])))
          : ListView.builder(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: moments.length,
              itemBuilder: (context, index) {
                final moment = moments[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                          backgroundImage: moment.userAvatar != null ? NetworkImage(moment.userAvatar!) : null,
                          child: moment.userAvatar == null 
                              ? Text(moment.userName.isNotEmpty ? moment.userName[0].toUpperCase() : '?', 
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)) 
                              : null,
                        ),
                        title: Text(
                          moment.userName, 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(
                          _formatTime(moment.timestamp),
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ),
                      if (moment.content.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(moment.content, style: const TextStyle(fontSize: 15, height: 1.4)),
                        ),
                      if (moment.imageUrl != null)
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          width: double.infinity,
                          constraints: const BoxConstraints(maxHeight: 300),
                          child: Image.network(
                            moment.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                                Container(height: 200, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey)),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => context.read<DataProvider>().toggleMomentLike(moment.id),
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.favorite_border, // Simple logic, add 'isLiked' if we want to show red heart
                                      size: 20,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text('${moment.likes}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(l10n.comment, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
