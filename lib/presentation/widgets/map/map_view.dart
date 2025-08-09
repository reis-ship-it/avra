import 'package:flutter/material.dart';
import 'package:spots/core/models/unified_models.dart';import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:spots/core/theme/map_themes.dart';
import 'package:spots/core/theme/map_theme_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spots/presentation/blocs/spots/spots_bloc.dart';
import 'package:spots/presentation/blocs/lists/lists_bloc.dart';
import 'package:spots/core/models/spot.dart';
import 'package:spots/core/models/list.dart';
import 'package:spots/presentation/widgets/map/spot_marker.dart';
import 'package:spots/presentation/pages/spots/spot_details_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:spots/presentation/widgets/common/offline_indicator.dart';
import 'package:spots/presentation/blocs/auth/auth_bloc.dart';
import 'package:spots/core/theme/app_theme.dart';
import 'package:spots/core/theme/colors.dart';
import 'dart:developer' as developer;

class MapView extends StatefulWidget {
  final SpotList? initialSelectedList;
  final ValueChanged<SpotList?>? onListSelected;
  final bool showAppBar;
  final String? appBarTitle;

  const MapView({
    super.key,
    this.initialSelectedList,
    this.onListSelected,
    this.showAppBar = true,
    this.appBarTitle,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final MapController _mapController = MapController();
  LatLng? _center;
  final double _currentZoom = 13.0;
  bool _isLoadingLocation = false;
  String? _locationError;
  MapTheme _currentTheme = MapThemes.spotsBlue;
  SpotList? _selectedList;

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<String> _searchSuggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _selectedList = widget.initialSelectedList;
    _loadSavedTheme();
    _loadSpots();
    _initializeSearchSuggestions();

    // Load spots and lists if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpotsBloc>().add(LoadSpots());
      context.read<ListsBloc>().add(LoadLists());

      // Request location permission and auto-locate user
      _requestLocationPermission();
      _getCurrentLocationWithRetry();
    });
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      developer.log('Getting current location...', name: 'MapView');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          timeLimit: Duration(seconds: 15),
        ),
      );
      developer.log(
          'Location obtained: ${position.latitude}, ${position.longitude}',
          name: 'MapView');
      return position;
    } catch (e) {
      developer.log('Error getting location: $e', name: 'MapView');
      return null;
    }
  }

  Future<Position?> _getCurrentLocationWithRetry() async {
    try {
      developer.log('Getting current location with retry...', name: 'MapView');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          timeLimit: Duration(seconds: 15),
        ),
      );
      developer.log(
          'Location obtained with retry: ${position.latitude}, ${position.longitude}',
          name: 'MapView');
      return position;
    } catch (e) {
      developer.log('Error getting location with retry: $e', name: 'MapView');
      return null;
    }
  }

  Future<void> _requestLocationPermission() async {
    developer.log('Requesting location permission...', name: 'MapView');
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      developer.log('Location permission denied, requesting...',
          name: 'MapView');
      final requestedPermission = await Geolocator.requestPermission();
      if (requestedPermission == LocationPermission.denied) {
        developer.log('Location permission still denied', name: 'MapView');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Location permission is required for map functionality')),
          );
        }
      } else if (requestedPermission == LocationPermission.deniedForever) {
        developer.log('Location permission denied forever', name: 'MapView');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Please enable location permissions in settings')),
          );
        }
      } else {
        developer.log('Location permission granted', name: 'MapView');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission granted!')),
          );
        }
      }
    } else if (permission == LocationPermission.deniedForever) {
      developer.log('Location permission denied forever', name: 'MapView');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please enable location permissions in settings')),
        );
      }
    } else {
      developer.log('Location permission already granted', name: 'MapView');
    }
  }

  Future<void> _loadSavedTheme() async {
    final savedTheme = await MapThemeManager.getCurrentTheme();
    setState(() {
      _currentTheme = savedTheme;
    });
  }

  void _initializeSearchSuggestions() {
    _searchSuggestions = [
      'Coffee shops',
      'Restaurants',
      'Parks',
      'Museums',
      'Bars',
      'Shopping',
      'Gyms',
      'Libraries',
      'Near me',
      'Popular spots',
      'New places',
      'Trending',
    ];
  }

  void _loadSpots() {
    context.read<SpotsBloc>().add(LoadSpots());
  }

  void _handleSearch(String query) {
    if (query.isEmpty) {
      // Clear search and show all spots
      context.read<SpotsBloc>().add(SearchSpots(query: ''));
      setState(() {
        _showSuggestions = false;
      });
      return;
    }

    // Check if it's a location search
    if (query.toLowerCase().contains('near me') ||
        query.toLowerCase().contains('nearby')) {
      _searchNearbySpots();
      return;
    }

    // Check if it's a category search
    if (_isCategorySearch(query)) {
      _searchByCategory(query);
      return;
    }

    // Regular text search
    context.read<SpotsBloc>().add(SearchSpots(query: query));
    setState(() {
      _showSuggestions = false;
    });
  }

  bool _isCategorySearch(String query) {
    final categories = [
      'coffee',
      'restaurant',
      'park',
      'museum',
      'bar',
      'shopping',
      'gym',
      'library',
      'cafe',
      'food',
      'drink',
      'entertainment'
    ];
    return categories.any((category) => query.toLowerCase().contains(category));
  }

  void _searchByCategory(String query) {
    final category = _extractCategory(query);
    context.read<SpotsBloc>().add(SearchSpots(query: category));
    setState(() {
      _showSuggestions = false;
    });
  }

  String _extractCategory(String query) {
    final lowerQuery = query.toLowerCase();
    if (lowerQuery.contains('coffee') || lowerQuery.contains('cafe'))
      return 'coffee';
    if (lowerQuery.contains('restaurant') || lowerQuery.contains('food'))
      return 'restaurant';
    if (lowerQuery.contains('park')) return 'park';
    if (lowerQuery.contains('museum')) return 'museum';
    if (lowerQuery.contains('bar') || lowerQuery.contains('drink'))
      return 'bar';
    if (lowerQuery.contains('shopping')) return 'shopping';
    if (lowerQuery.contains('gym')) return 'gym';
    if (lowerQuery.contains('library')) return 'library';
    return query;
  }

  void _searchNearbySpots() {
    if (_center != null) {
      // For now, just show all spots since we don't have distance calculation
      // In a real app, you'd filter by distance from current location
      context.read<SpotsBloc>().add(SearchSpots(query: ''));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Showing all spots near your location'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Location not available. Please enable location services.'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
    }
    setState(() {
      _showSuggestions = false;
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _isSearching = value.isNotEmpty;
      if (value.isEmpty) {
        _showSuggestions = false;
        context.read<SpotsBloc>().add(SearchSpots(query: ''));
      } else {
        _showSuggestions = true;
        // Filter suggestions based on input
        _searchSuggestions = _searchSuggestions
            .where((suggestion) =>
                suggestion.toLowerCase().contains(value.toLowerCase()))
            .toList();
      }
    });
  }

  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    _handleSearch(suggestion);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = widget.showAppBar
        ? AppBar(
            title: Text(widget.appBarTitle ?? 'Map'),
            leading: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is Authenticated) {
                  return IconButton(
                    icon: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(
                        state.user.displayName?.substring(0, 1).toUpperCase() ??
                            state.user.email.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onPressed: () {
                      _showProfileMenu(context);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            actions: [
              IconButton(
                icon:
                    Icon(_selectedList == null ? Icons.list : Icons.checklist),
                tooltip: 'Choose list',
                onPressed: () async {
                  final listState = context.read<ListsBloc>().state;
                  if (listState is ListsLoaded && listState.lists.isNotEmpty) {
                    final selected = await showModalBottomSheet<SpotList?>(
                      context: context,
                      builder: (context) {
                        return SafeArea(
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.list),
                                title: const Text('All Spots'),
                                selected: _selectedList == null,
                                onTap: () => Navigator.pop(context, null),
                              ),
                              ...listState.lists.map((list) => ListTile(
                                    leading: const Icon(Icons.checklist),
                                    title: Text(list.title),
                                    selected: _selectedList?.id == list.id,
                                    onTap: () => Navigator.pop(context, list),
                                  )),
                            ],
                          ),
                        );
                      },
                    );
                    if (selected != null || _selectedList != selected) {
                      setState(() {
                        _selectedList = selected;
                      });
                      if (widget.onListSelected != null) {
                        widget.onListSelected!(selected);
                      }
                    }
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.palette),
                onPressed: _showThemeSelector,
                tooltip: 'Change map theme',
              ),
              IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: _getCurrentLocation,
                tooltip: 'Center on my location',
              ),
              OfflineIndicator(),
            ],
          )
        : null;

    return Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          // Enhanced search bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Search input
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.grey100
                        : AppColors.grey800,
                    borderRadius: BorderRadius.circular(12),
                    border: _isSearching
                        ? Border.all(color: AppTheme.primaryColor, width: 2)
                        : null,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    onSubmitted: _handleSearch,
                    decoration: InputDecoration(
                      hintText: 'Search spots, categories, or "near me"...',
                      hintStyle: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: _isSearching
                            ? AppTheme.primaryColor
                            : AppColors.grey600,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _handleSearch('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

                // Search suggestions
                if (_showSuggestions && _searchSuggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.white
                          : AppColors.grey900,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _searchSuggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = _searchSuggestions[index];
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            _getSuggestionIcon(suggestion),
                            size: 20,
                            color: AppTheme.primaryColor,
                          ),
                          title: Text(
                            suggestion,
                            style: const TextStyle(fontSize: 14),
                          ),
                          onTap: () => _onSuggestionTap(suggestion),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Map content
          Expanded(
            child: _isLoadingLocation
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Getting your location...'),
                      ],
                    ),
                  )
                : BlocBuilder<SpotsBloc, SpotsState>(
                    builder: (context, spotState) {
                      if (spotState is SpotsLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (spotState is SpotsLoaded) {
                        List<Spot> spots = spotState.filteredSpots.isNotEmpty
                            ? spotState.filteredSpots
                            : spotState.spots;

                        if (_selectedList != null) {
                          spots = spots
                              .where(
                                  (s) => _selectedList!.spotIds.contains(s.id))
                              .toList();
                        }

                        return FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _center ??
                                (spots.isNotEmpty
                                    ? LatLng(spots.first.latitude,
                                        spots.first.longitude)
                                    : LatLng(37.7749, -122.4194)),
                            initialZoom: _currentZoom,
                            minZoom: 3.0,
                            maxZoom: 18.0,
                            onMapReady: () {
                              developer.log('Map is ready', name: 'MapView');
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: _getTileUrlTemplate(),
                              userAgentPackageName: 'com.example.spots',
                              subdomains: _currentTheme.getSubdomains() ?? [],
                              maxZoom: 18,
                              tileProvider: NetworkTileProvider(),
                            ),
                            // User location marker
                            if (_locationError == null && _center != null)
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: _center!,
                                    width: 40,
                                    height: 40,
                                    child: Icon(
                                      Icons.my_location,
                                      color: _currentTheme.primaryColor,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            // Spot markers
                            if (spots.isNotEmpty)
                              MarkerLayer(
                                markers: spots
                                    .map((spot) => Marker(
                                          point: LatLng(
                                              spot.latitude, spot.longitude),
                                          width: 30,
                                          height: 30,
                                          child: SpotMarker(
                                            spot: spot,
                                            color: _currentTheme.primaryColor,
                                            onTap: () {
                                              _showSpotInfo(context, spot);
                                            },
                                          ),
                                        ))
                                    .toList(),
                              ),
                          ],
                        );
                      }
                      return const Center(child: Text('No spots loaded'));
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _locationError != null
          ? FloatingActionButton.extended(
              onPressed: _getCurrentLocation,
              label: const Text('Retry Location'),
              icon: const Icon(Icons.refresh),
            )
          : null,
    );
  }

  String _getTileUrlTemplate() {
    final url = _currentTheme.getTileUrl(0, 0, 0);
    if (url.contains('{s}')) {
      return url.replaceAll('/0/0/0.png', '/{z}/{x}/{y}.png');
    } else if (url.contains('{r}')) {
      return url.replaceAll('/0/0/0.png', '/{z}/{x}/{y}{r}.png');
    } else if (url.contains('{z}/{y}/{x}')) {
      return url;
    } else {
      return url.replaceAll('/0/0/0.png', '/{z}/{x}/{y}.png');
    }
  }

  void _showThemeSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Text(
              'Choose Map Theme',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Select from different map styles and color themes',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey600,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: MapThemes.allThemes.length,
                itemBuilder: (context, index) {
                  final theme = MapThemes.allThemes[index];
                  final isSelected = theme.name == _currentTheme.name;
                  return GestureDetector(
                    onTap: () async {
                      await MapThemeManager.setTheme(theme);
                      setState(() {
                        _currentTheme = theme;
                      });
                      Navigator.pop(context);
                    },
                    child: Card(
                      elevation: isSelected ? 4 : 2,
                      color: isSelected
                          ? theme.primaryColor.withOpacity(0.1)
                          : theme.surfaceColor,
                      child: Container(
                        decoration: BoxDecoration(
                          border: isSelected
                              ? Border.all(color: theme.primaryColor, width: 2)
                              : null,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: theme.primaryColor,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Icon(
                                  _getThemeIcon(theme.name),
                                  color: AppColors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                theme.name,
                                style: TextStyle(
                                  color: theme.textColor,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                theme.tileServerName,
                                style: TextStyle(
                                  color: theme.textColor.withOpacity(0.7),
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getThemeIcon(String themeName) {
    switch (themeName.toLowerCase()) {
      case 'satellite':
        return Icons.satellite;
      case 'terrain':
        return Icons.terrain;
      case 'nature':
        return Icons.eco;
      case 'sunset':
        return Icons.wb_sunny;
      case 'purple':
        return Icons.palette;
      case 'minimalist':
        return Icons.crop_square;
      case 'dark':
        return Icons.dark_mode;
      case 'outdoors':
        return Icons.hiking;
      case 'street':
        return Icons.directions_car;
      default:
        return Icons.map;
    }
  }

  void _showSpotInfo(BuildContext context, Spot spot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(spot.name),
        content: Text(spot.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SpotDetailsPage(spot: spot),
                ),
              );
            },
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(
                        state.user.displayName?.substring(0, 1).toUpperCase() ??
                            state.user.email.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(state.user.displayName ?? 'User'),
                    subtitle: Text(state.user.email),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Sign Out'),
                    onTap: () {
                      Navigator.pop(context);
                      context.read<AuthBloc>().add(SignOutRequested());
                    },
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  IconData _getSuggestionIcon(String suggestion) {
    final lowerSuggestion = suggestion.toLowerCase();
    if (lowerSuggestion.contains('coffee') || lowerSuggestion.contains('cafe'))
      return Icons.coffee;
    if (lowerSuggestion.contains('restaurant') ||
        lowerSuggestion.contains('food')) return Icons.restaurant;
    if (lowerSuggestion.contains('park')) return Icons.park;
    if (lowerSuggestion.contains('museum')) return Icons.museum;
    if (lowerSuggestion.contains('bar') || lowerSuggestion.contains('drink'))
      return Icons.local_bar;
    if (lowerSuggestion.contains('shopping')) return Icons.shopping_bag;
    if (lowerSuggestion.contains('gym')) return Icons.fitness_center;
    if (lowerSuggestion.contains('library')) return Icons.local_library;
    if (lowerSuggestion.contains('near me') ||
        lowerSuggestion.contains('nearby')) return Icons.near_me;
    if (lowerSuggestion.contains('popular')) return Icons.trending_up;
    if (lowerSuggestion.contains('new')) return Icons.new_releases;
    if (lowerSuggestion.contains('trending')) return Icons.trending_up;
    return Icons.search;
  }
}
