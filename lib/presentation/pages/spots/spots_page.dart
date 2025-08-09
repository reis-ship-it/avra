import 'package:flutter/material.dart';
import 'package:spots/core/models/unified_models.dart';import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spots/core/theme/category_colors.dart';
import 'package:spots/presentation/blocs/spots/spots_bloc.dart';
import 'package:spots/presentation/pages/spots/create_spot_page.dart';
import 'package:spots/presentation/pages/spots/spot_details_page.dart';
import 'package:spots/presentation/widgets/spots/spot_card.dart';
import 'package:spots/presentation/widgets/common/offline_indicator.dart';
import 'package:spots/core/theme/app_theme.dart';

class SpotsPage extends StatefulWidget {
  const SpotsPage({super.key});

  @override
  State<SpotsPage> createState() => _SpotsPageState();
}

class _SpotsPageState extends State<SpotsPage> {
  @override
  void initState() {
    super.initState();
    // Load spots including respected lists
    context.read<SpotsBloc>().add(LoadSpotsWithRespected());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spots'),
        actions: const [
          OfflineIndicator(),
          SizedBox(width: 16),
        ],
      ),
      body: BlocBuilder<SpotsBloc, SpotsState>(
        builder: (context, state) {
          if (state is SpotsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SpotsLoaded) {
            final allSpots = [...state.spots, ...state.respectedSpots];

            if (allSpots.isEmpty) {
              return const Center(
                child: Text('No spots yet. Create your first spot!'),
              );
            }

            return ListView.builder(
              itemCount: allSpots.length,
              itemBuilder: (context, index) {
                final spot = allSpots[index];
                return SpotCard(
                  spot: spot,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SpotDetailsPage(spot: spot),
                      ),
                    );
                  },
                );
              },
            );
          }

          if (state is SpotsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: AppTheme.errorColor),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SpotsBloc>().add(LoadSpotsWithRespected());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('No spots loaded'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateSpotPage()),
          );
        },
        heroTag: 'spots_page_fab',
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getCategoryColor(String category) => CategoryStyles.colorFor(category);

  IconData _getCategoryIcon(String category) => CategoryStyles.iconFor(category);
}
