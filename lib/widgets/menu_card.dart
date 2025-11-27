import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/menu_model.dart';

class MenuCard extends StatelessWidget {
  final MenuItem menuItem;
  final VoidCallback? onTap;
  final bool isChef;

  const MenuCard({
    super.key,
    required this.menuItem,
    this.onTap,
    this.isChef = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.asset(
                menuItem.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.restaurant, size: 40, color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menuItem.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.favorite, size: 14, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(
                        '${menuItem.intimacyPrice}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
