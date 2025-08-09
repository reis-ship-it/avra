import 'package:flutter/material.dart';
import 'package:spots/core/models/unified_models.dart';import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spots/core/models/spot.dart';
import 'package:spots/core/models/list.dart';
import 'package:spots/core/theme/app_theme.dart';
import 'package:spots/presentation/blocs/lists/lists_bloc.dart';

class SpotDetailsPage extends StatelessWidget {
  final Spot spot;

  const SpotDetailsPage({super.key, required this.spot});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(spot.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Spot Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(spot.category),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            spot.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (spot.rating > 0)
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                spot.rating.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      spot.name,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    if (spot.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        spot.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Location Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (spot.address != null) ...[
                      Text(
                        spot.address!,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      'Latitude: ${spot.latitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      'Longitude: ${spot.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Maps integration coming soon!')),
                        );
                      },
                      icon: const Icon(Icons.directions),
                      label: const Text('Get Directions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Additional Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Created', _formatDate(spot.createdAt)),
                    _buildDetailRow('Updated', _formatDate(spot.updatedAt)),
                    if (spot.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Tags: ${spot.tags.join(', ')}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showAddToListDialog(context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add to List'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Share feature coming soon!')),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddToListDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<ListsBloc, ListsState>(
        builder: (context, state) {
          if (state is ListsLoaded) {
            if (state.lists.isEmpty) {
              return AlertDialog(
                title: const Text('No Lists Available'),
                content: const Text('Create a list first to add spots to it.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              );
            }

            return AlertDialog(
              title: const Text('Add to List'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.lists.length,
                  itemBuilder: (context, index) {
                    final list = state.lists[index];
                    final isInList = list.spotIds.contains(spot.id);

                    return ListTile(
                      leading: Icon(
                        isInList
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isInList ? Colors.green : null,
                      ),
                      title: Text(list.title),
                      subtitle: Text(list.description),
                      onTap: () {
                        if (!isInList) {
                          _addSpotToList(context, list);
                        }
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            );
          }

          return const AlertDialog(
            title: Text('Loading Lists'),
            content: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  void _addSpotToList(BuildContext context, SpotList list) {
    final updatedList = list.copyWith(
      spotIds: [...list.spotIds, spot.id],
      updatedAt: DateTime.now(),
    );

    context.read<ListsBloc>().add(UpdateList(updatedList));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${spot.name} to ${list.title}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'restaurant':
        return Colors.red;
      case 'cafe':
        return Colors.brown;
      case 'bar':
        return Colors.purple;
      case 'shop':
        return Colors.blue;
      case 'park':
        return Colors.green;
      case 'museum':
        return Colors.orange;
      case 'theater':
        return Colors.pink;
      case 'hotel':
        return Colors.teal;
      case 'landmark':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}
