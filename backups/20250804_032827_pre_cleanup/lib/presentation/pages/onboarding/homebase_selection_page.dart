import 'dart:async';
import 'package:spots/core/models/unified_models.dart';import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:spots/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomebaseSelectionPage extends StatefulWidget {
  final String? selectedHomebase;
  final Function(String) onHomebaseChanged;
  final VoidCallback? onNext;

  const HomebaseSelectionPage({
    super.key,
    this.selectedHomebase,
    required this.onHomebaseChanged,
    this.onNext,
  });

  @override
  State<HomebaseSelectionPage> createState() => _HomebaseSelectionPageState();
}

class _HomebaseSelectionPageState extends State<HomebaseSelectionPage> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  String? _selectedNeighborhood;
  bool _isLoadingLocation = false;
  bool _hasLocationPermission = false;
  bool _mapLoaded = false;
  Timer? _debounceTimer;
  
  // Cache for geocoding results
  static final Map<String, String> _geocodingCache = {};
  static const String _cacheKey = 'homebase_geocoding_cache';

  @override
  void initState() {
    super.initState();
    developer.log('HomebaseSelectionPage: initState called');
    _loadCachedLocation();
    _initializeMap();
    _preloadCommonLocations();
  }

  Future<void> _preloadCommonLocations() async {
    // Preload geocoding for common locations to improve performance
    final commonLocations = [
      const LatLng(40.7128, -74.0060), // NYC
      const LatLng(34.0522, -118.2437), // LA
      const LatLng(41.8781, -87.6298), // Chicago
      const LatLng(29.7604, -95.3698), // Houston
      const LatLng(33.7490, -84.3880), // Atlanta
    ];

    for (final location in commonLocations) {
      final cacheKey = '${location.latitude.toStringAsFixed(4)}_${location.longitude.toStringAsFixed(4)}';
      if (!_geocodingCache.containsKey(cacheKey)) {
        // Preload in background
        _getNeighborhoodName(location).catchError((e) {
          developer.log('HomebaseSelectionPage: Error preloading location $location: $e');
        });
      }
    }
  }

  Future<void> _loadCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedLat = prefs.getDouble('cached_lat');
      final cachedLng = prefs.getDouble('cached_lng');
      final cachedNeighborhood = prefs.getString('cached_neighborhood');
      
      if (cachedLat != null && cachedLng != null) {
        _currentLocation = LatLng(cachedLat, cachedLng);
        if (cachedNeighborhood != null) {
          _selectedNeighborhood = cachedNeighborhood;
          widget.onHomebaseChanged(cachedNeighborhood);
        }
        developer.log('HomebaseSelectionPage: Loaded cached location: $_currentLocation, neighborhood: $_selectedNeighborhood');
      }
    } catch (e) {
      developer.log('HomebaseSelectionPage: Error loading cached location: $e');
    }
  }

  Future<void> _saveCachedLocation(LatLng location, String neighborhood) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('cached_lat', location.latitude);
      await prefs.setDouble('cached_lng', location.longitude);
      await prefs.setString('cached_neighborhood', neighborhood);
      developer.log('HomebaseSelectionPage: Saved location to cache');
    } catch (e) {
      developer.log('HomebaseSelectionPage: Error saving cached location: $e');
    }
  }

  Future<void> _initializeMap() async {
    developer.log('HomebaseSelectionPage: Initializing map');
    
    // Set a default location first to ensure map loads
    if (_currentLocation == null) {
      _currentLocation = const LatLng(40.7128, -74.0060); // NYC default
    }
    
    setState(() {
      _mapLoaded = true;
    });
    
    // Then try to get current location
    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    
    developer.log('HomebaseSelectionPage: Getting current location');
    
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      developer.log('HomebaseSelectionPage: Initial permission status: $permission');
      
      if (permission == LocationPermission.denied) {
        developer.log('HomebaseSelectionPage: Requesting location permission');
        permission = await Geolocator.requestPermission();
        developer.log('HomebaseSelectionPage: Permission after request: $permission');
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        _hasLocationPermission = true;
        developer.log('HomebaseSelectionPage: Location permission granted');

        // Get current position with medium accuracy for faster results
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium, // Faster than high accuracy
            timeLimit: Duration(seconds: 8), // Reduced from 15 seconds
          ),
        );

        developer.log('HomebaseSelectionPage: Got position: ${position.latitude}, ${position.longitude}');

        // Update current location
        _currentLocation = LatLng(position.latitude, position.longitude);

        // Center map on user's location
        _mapController.move(_currentLocation!, 15);

        // Get neighborhood name for the centered location (in parallel)
        _getNeighborhoodName(_currentLocation!);
      } else {
        developer.log('HomebaseSelectionPage: Location permission denied, using default location');
        // Default to a central location if no permission
        _mapController.move(const LatLng(40.7128, -74.0060), 15); // NYC
        _getNeighborhoodName(const LatLng(40.7128, -74.0060));
      }
    } catch (e) {
      developer.log('HomebaseSelectionPage: Error getting location: $e');
      // Default to a central location on error
      _mapController.move(const LatLng(40.7128, -74.0060), 15); // NYC
      _getNeighborhoodName(const LatLng(40.7128, -74.0060));
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _getNeighborhoodName(LatLng location) async {
    developer.log('HomebaseSelectionPage: Getting neighborhood name for location: ${location.latitude}, ${location.longitude}');
    
    // Create cache key
    final cacheKey = '${location.latitude.toStringAsFixed(4)}_${location.longitude.toStringAsFixed(4)}';
    
    // Check cache first
    if (_geocodingCache.containsKey(cacheKey)) {
      final cachedResult = _geocodingCache[cacheKey]!;
      developer.log('HomebaseSelectionPage: Using cached result: $cachedResult');
      if (mounted) {
        setState(() {
          _selectedNeighborhood = cachedResult;
        });
      }
      widget.onHomebaseChanged(cachedResult);
      await _saveCachedLocation(location, cachedResult);
      return;
    }
    
    try {
      // Use multiple geocoding services for better accuracy with timeout
      final completer = Completer<List<Placemark>>();
      
      // Set a timeout for geocoding
      Timer(const Duration(seconds: 5), () {
        if (!completer.isCompleted) {
          completer.completeError('Geocoding timeout');
        }
      });

      // Start geocoding
      placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      ).then((placemarks) {
        if (!completer.isCompleted) {
          completer.complete(placemarks);
        }
      }).catchError((error) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      });

      final placemarks = await completer.future;
      developer.log('HomebaseSelectionPage: Got ${placemarks.length} placemarks');

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        developer.log('HomebaseSelectionPage: First placemark: ${place.name}, ${place.thoroughfare}, ${place.locality}');

        String neighborhood = _extractNeighborhood(place);
        developer.log('HomebaseSelectionPage: Extracted neighborhood: $neighborhood');

        // Cache the result
        _geocodingCache[cacheKey] = neighborhood;

        if (mounted) {
          setState(() {
            _selectedNeighborhood = neighborhood;
          });
        }

        // Update the homebase selection
        if (neighborhood != 'Unknown Location') {
          widget.onHomebaseChanged(neighborhood);
          await _saveCachedLocation(location, neighborhood);
        }
      } else {
        developer.log('HomebaseSelectionPage: No placemarks found');
        if (mounted) {
          setState(() {
            _selectedNeighborhood = 'Unknown Location';
          });
        }
      }
    } catch (e) {
      developer.log('HomebaseSelectionPage: Error in geocoding: $e');
      // Try reverse geocoding as fallback with shorter timeout
      try {
        final completer = Completer<List<Placemark>>();
        
        Timer(const Duration(seconds: 3), () {
          if (!completer.isCompleted) {
            completer.completeError('Reverse geocoding timeout');
          }
        });

        placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        ).then((placemarks) {
          if (!completer.isCompleted) {
            completer.complete(placemarks);
          }
        }).catchError((error) {
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        });

        final reversePlacemarks = await completer.future;

        if (reversePlacemarks.isNotEmpty) {
          Placemark place = reversePlacemarks.first;
          String neighborhood = _extractNeighborhood(place);

          // Cache the result
          _geocodingCache[cacheKey] = neighborhood;

          if (mounted) {
            setState(() {
              _selectedNeighborhood = neighborhood;
            });
          }
        }
      } catch (e2) {
        developer.log('HomebaseSelectionPage: Error in reverse geocoding: $e2');
        // Handle geocoding error
        if (mounted) {
          setState(() {
            _selectedNeighborhood = 'Unknown Location';
          });
        }
      }
    }
  }

  String _extractNeighborhood(Placemark place) {
    // Try to get the most specific neighborhood name
    // For NYC and other cities, prioritize thoroughfare over sublocality

    // First, try to get the thoroughfare (street name) which is more specific
    if (place.thoroughfare?.isNotEmpty == true) {
      return place.thoroughfare!;
    }

    // For NYC specifically, try to extract neighborhood from address components
    if (place.locality?.toLowerCase().contains('new york') == true ||
        place.administrativeArea?.toLowerCase().contains('new york') == true) {
      // Try to get neighborhood from street name or address
      String street = place.street ?? '';
      String thoroughfare = place.thoroughfare ?? '';

      // Common NYC neighborhood patterns in street names
      List<String> nycNeighborhoods = [
        'gowanus',
        'red hook',
        'upper east side',
        'upper west side',
        'lower east side',
        'lower west side',
        'chelsea',
        'greenwich village',
        'soho',
        'noho',
        'tribeca',
        'financial district',
        'battery park',
        'east village',
        'west village',
        'harlem',
        'morningside heights',
        'washington heights',
        'inwood',
        'astoria',
        'long island city',
        'sunnyside',
        'woodside',
        'jackson heights',
        'flushing',
        'forest hills',
        'kew gardens',
        'bayside',
        'douglaston',
        'williamsburg',
        'greenpoint',
        'bushwick',
        'bedford-stuyvesant',
        'crown heights',
        'prospect heights',
        'park slope',
        'carroll gardens',
        'cobble hill',
        'boerum hill',
        'brooklyn heights',
        'dumbo',
        'vinegar hill',
        'fort greene',
        'clinton hill',
        'prospect lefferts gardens',
        'bay ridge',
        'sunset park',
        'borough park',
        'bensonhurst',
        'sheepshead bay',
        'brighton beach',
        'coney island',
        'flatbush',
        'east flatbush',
        'canarsie',
        'brownsville',
        'east new york'
      ];

      // Check if any neighborhood name is in the street or thoroughfare
      String searchText =
          '${street.toLowerCase()} ${thoroughfare.toLowerCase()}'.trim();
      for (String neighborhood in nycNeighborhoods) {
        if (searchText.contains(neighborhood)) {
          return neighborhood
              .split(' ')
              .map((word) =>
                  word.substring(0, 1).toUpperCase() + word.substring(1))
              .join(' ');
        }
      }
    }

    // Fallback to sublocality (borough for NYC)
    if (place.subLocality?.isNotEmpty == true) {
      return place.subLocality!;
    }

    // Fallback to subadministrative area (borough for NYC)
    if (place.subAdministrativeArea?.isNotEmpty == true) {
      if (place.locality?.isNotEmpty == true) {
        return '${place.subAdministrativeArea}, ${place.locality}';
      }
      return place.subAdministrativeArea!;
    }

    // Fallback to locality (city name)
    if (place.locality?.isNotEmpty == true) {
      return place.locality!;
    }

    // Final fallback to administrative area (state)
    if (place.administrativeArea?.isNotEmpty == true) {
      return place.administrativeArea!;
    }

    return 'Unknown Location';
  }

  void _onMapMoved() {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Get current map center (where the fixed marker is positioned)
    final center = _mapController.camera.center;
    // Debounce the geocoding call with shorter delay for faster response
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _getNeighborhoodName(center);
      }
    });
  }

  void _onMapZoomChanged() {
    // Disable zoom in if user hasn't zoomed out first
    final zoom = _mapController.camera.zoom;
    if (zoom > 15) {
      // If zoomed in too much, zoom out to neighborhood level
      _mapController.move(_mapController.camera.center, 15);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Where\'s your homebase?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Position the marker over your homebase. Only the location name will appear on your profile.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),

          // Debug info (only in debug mode)
          if (const bool.fromEnvironment('dart.vm.product') == false)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Debug Info:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text('Map Loaded: $_mapLoaded'),
                  Text('Loading: $_isLoadingLocation'),
                  Text('Has Permission: $_hasLocationPermission'),
                  Text('Selected: $_selectedNeighborhood'),
                  Text('Current Location: $_currentLocation'),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _getCurrentLocation,
                        child: const Text('Test Location'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          developer.log('HomebaseSelectionPage: Manual test button pressed');
                          _getNeighborhoodName(const LatLng(40.7128, -74.0060));
                        },
                        child: const Text('Test Geocoding'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Map Container
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Map
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter:
                            _currentLocation ?? const LatLng(40.7128, -74.0060),
                        initialZoom: 15,
                        minZoom: 10,
                        maxZoom: 15,
                        onMapEvent: (event) {
                          if (event is MapEventMove) {
                            _onMapMoved();
                            _onMapZoomChanged();
                          }
                        },
                        onMapReady: () {
                          developer.log('HomebaseSelectionPage: Map is ready');
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.spots.app',
                          maxZoom: 18,
                        ),
                      ],
                    ),

                    // Fixed center marker (always in center of map)
                    Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),

                    // Loading overlay
                    if (_isLoadingLocation || !_mapLoaded)
                      Container(
                        color: Colors.black.withOpacity(0.3),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Colors.white,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Loading map...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Selected neighborhood indicator
                    if (_selectedNeighborhood != null)
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  _selectedNeighborhood!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Location permission warning
                    if (!_hasLocationPermission)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_off,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Location access needed to find your neighborhood',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _getCurrentLocation,
                                child: const Text(
                                  'Enable',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Retry button for location issues
                    if (_selectedNeighborhood == null && !_isLoadingLocation)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.refresh,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Tap to refresh location',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _getCurrentLocation,
                                child: const Text(
                                  'Retry',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }
}
