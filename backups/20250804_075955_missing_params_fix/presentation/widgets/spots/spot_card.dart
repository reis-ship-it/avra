import 'package:flutter/material.dart';
import 'package:spots/core/models/unified_models.dart';import 'package:spots/core/models/spot.dart';

class SpotCard extends StatelessWidget {
  final Spot spot;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SpotCard({
    super.key,
    required this.spot,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(spot.category),
          child: Icon(
            _getCategoryIcon(spot.category),
            color: Colors.white,
          ),
        ),
        title: Text(spot.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(spot.description),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                Text(' ${spot.rating.toStringAsFixed(1)}'),
                const SizedBox(width: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(spot.category).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    spot.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getCategoryColor(spot.category),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'coffee':
        return Colors.brown;
      case 'bakery':
        return Colors.orange;
      case 'park':
        return Colors.green;
      case 'restaurant':
        return Colors.red;
      case 'attraction':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'coffee':
        return Icons.coffee;
      case 'bakery':
        return Icons.cake;
      case 'park':
        return Icons.park;
      case 'restaurant':
        return Icons.restaurant;
      case 'attraction':
        return Icons.attractions;
      default:
        return Icons.place;
    }
  }
}
