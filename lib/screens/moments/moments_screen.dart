import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/moment_model.dart';
import '../../providers/auth_provider.dart';

class MomentsScreen extends StatefulWidget {
  const MomentsScreen({super.key});

  @override
  State<MomentsScreen> createState() => _MomentsScreenState();
}

class _MomentsScreenState extends State<MomentsScreen> {
  // Mock data for now
  final List<Moment> _moments = [
    Moment(
      id: '1',
      userId: 'chef1',
      userName: 'Chef Alex',
      content: 'Just made a delicious pasta! 🍝',
      imageUrl: 'assets/images/pasta.jpg',
      likes: 5,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Moment(
      id: '2',
      userId: 'foodie1',
      userName: 'Foodie Sam',
      content: 'Can\'t wait for dinner! 😋',
      likes: 2,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: _moments.length,
        itemBuilder: (context, index) {
          final moment = _moments[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(moment.userName[0]),
                  ),
                  title: Text(moment.userName),
                  subtitle: Text(
                    '${moment.timestamp.hour}:${moment.timestamp.minute}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                if (moment.content.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(moment.content),
                  ),
                if (moment.imageUrl != null)
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 50, color: Colors.grey),
                    // In real app: Image.asset(moment.imageUrl!)
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite_border),
                        onPressed: () {},
                      ),
                      Text('${moment.likes}'),
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
          );
        },
      ),
    );
  }
}
