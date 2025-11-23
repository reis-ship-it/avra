import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:spots/core/models/expertise_event.dart';
import 'package:spots/core/services/expertise_event_service.dart';
import 'package:spots/core/theme/app_colors.dart';
import 'package:spots/core/theme/app_theme.dart';
import 'package:spots/presentation/blocs/auth/auth_bloc.dart';
import 'package:spots/presentation/widgets/expertise/expertise_event_widget.dart';
import 'package:spots/presentation/pages/events/event_details_page.dart';

/// Event Discovery UI - Browse/Search Page
/// Agent 2: Event Discovery & Hosting UI (Phase 1, Section 1)
/// 
/// CRITICAL: Uses AppColors/AppTheme (100% adherence required)
/// 
/// Features:
/// - List view of events
/// - Search by title, category, location
/// - Filters: category, location, date, price
/// - Pull-to-refresh
/// - Integration with ExpertiseEventService
class EventsBrowsePage extends StatefulWidget {
  const EventsBrowsePage({super.key});

  @override
  State<EventsBrowsePage> createState() => _EventsBrowsePageState();
}

class _EventsBrowsePageState extends State<EventsBrowsePage> {
  final ExpertiseEventService _eventService = ExpertiseEventService();
  final TextEditingController _searchController = TextEditingController();
  
  List<ExpertiseEvent> _events = [];
  List<ExpertiseEvent> _filteredEvents = [];
  bool _isLoading = false;
  String? _error;
  
  // Filters
  String? _selectedCategory;
  String? _selectedLocation;
  String? _selectedDateFilter; // "all", "upcoming", "this_week", "this_month"
  String? _selectedPriceFilter; // "all", "free", "paid"
  ExpertiseEventType? _selectedEventType;
  
  // Available categories (from service or hardcoded for now)
  final List<String> _categories = [
    'Coffee',
    'Bookstores',
    'Restaurants',
    'Bars',
    'Parks',
    'Museums',
    'Music',
    'Art',
    'Sports',
    'Other',
  ];
  
  // Date filter options
  final Map<String, String> _dateFilters = {
    'all': 'All Events',
    'upcoming': 'Upcoming',
    'this_week': 'This Week',
    'this_month': 'This Month',
  };
  
  // Price filter options
  final Map<String, String> _priceFilters = {
    'all': 'All',
    'free': 'Free',
    'paid': 'Paid',
  };
  
  // Event types
  final List<ExpertiseEventType> _eventTypes = ExpertiseEventType.values;

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final events = await _eventService.searchEvents(
        category: _selectedCategory,
        location: _selectedLocation,
        eventType: _selectedEventType,
        startDate: _getStartDateFilter(),
        maxResults: 50,
      );
      
      setState(() {
        _events = events;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load events: $e';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = List<ExpertiseEvent>.from(_events);
    
    // Apply search text filter
    final searchText = _searchController.text.toLowerCase().trim();
    if (searchText.isNotEmpty) {
      filtered = filtered.where((event) {
        final titleMatch = event.title.toLowerCase().contains(searchText);
        final categoryMatch = event.category.toLowerCase().contains(searchText);
        final locationMatch = event.location?.toLowerCase().contains(searchText) ?? false;
        return titleMatch || categoryMatch || locationMatch;
      }).toList();
    }
    
    // Apply price filter
    if (_selectedPriceFilter == 'free') {
      filtered = filtered.where((e) => !e.isPaid).toList();
    } else if (_selectedPriceFilter == 'paid') {
      filtered = filtered.where((e) => e.isPaid).toList();
    }
    
    // Apply date filter
    if (_selectedDateFilter != null && _selectedDateFilter != 'all') {
      final now = DateTime.now();
      filtered = filtered.where((event) {
        if (_selectedDateFilter == 'upcoming') {
          return event.startTime.isAfter(now);
        } else if (_selectedDateFilter == 'this_week') {
          final weekEnd = now.add(const Duration(days: 7));
          return event.startTime.isAfter(now) && event.startTime.isBefore(weekEnd);
        } else if (_selectedDateFilter == 'this_month') {
          final monthEnd = DateTime(now.year, now.month + 1, 1);
          return event.startTime.isAfter(now) && event.startTime.isBefore(monthEnd);
        }
        return true;
      }).toList();
    }
    
    setState(() {
      _filteredEvents = filtered;
    });
  }

  DateTime? _getStartDateFilter() {
    if (_selectedDateFilter == null || _selectedDateFilter == 'all') {
      return null;
    }
    
    final now = DateTime.now();
    if (_selectedDateFilter == 'upcoming') {
      return now;
    } else if (_selectedDateFilter == 'this_week') {
      return now;
    } else if (_selectedDateFilter == 'this_month') {
      return now;
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Events',
          style: TextStyle(color: AppTheme.textColor),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadEvents,
        color: AppColors.electricGreen,
        child: Column(
          children: [
            // Search Bar
            _buildSearchBar(),
            
            // Filters
            _buildFilters(),
            
            // Event List
            Expanded(
              child: _buildEventList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.background,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search events...',
          hintStyle: TextStyle(color: AppColors.textHint),
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.grey100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.grey300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.grey300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
        ),
        style: TextStyle(color: AppTheme.textColor),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Category Filter
            _buildFilterChip(
              label: _selectedCategory ?? 'All Categories',
              onTap: () => _showCategoryFilter(),
            ),
            const SizedBox(width: 8),
            
            // Location Filter
            _buildFilterChip(
              label: _selectedLocation ?? 'All Locations',
              onTap: () => _showLocationFilter(),
            ),
            const SizedBox(width: 8),
            
            // Date Filter
            _buildFilterChip(
              label: _dateFilters[_selectedDateFilter] ?? _dateFilters['all']!,
              onTap: () => _showDateFilter(),
            ),
            const SizedBox(width: 8),
            
            // Price Filter
            _buildFilterChip(
              label: _priceFilters[_selectedPriceFilter] ?? _priceFilters['all']!,
              onTap: () => _showPriceFilter(),
            ),
            const SizedBox(width: 8),
            
            // Clear Filters
            if (_hasActiveFilters())
              _buildFilterChip(
                label: 'Clear',
                onTap: () => _clearFilters(),
                isClear: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onTap,
    bool isClear = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isClear ? AppColors.error.withOpacity(0.1) : AppColors.grey200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isClear 
                ? AppColors.error 
                : (_selectedCategory != null || _selectedLocation != null || 
                    _selectedDateFilter != null || _selectedPriceFilter != null)
                    ? AppTheme.primaryColor
                    : AppColors.grey300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isClear 
                ? AppColors.error 
                : (_selectedCategory != null || _selectedLocation != null || 
                    _selectedDateFilter != null || _selectedPriceFilter != null)
                    ? AppTheme.primaryColor
                    : AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedCategory != null ||
        _selectedLocation != null ||
        _selectedDateFilter != null ||
        _selectedPriceFilter != null;
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All Categories'),
                  selected: _selectedCategory == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = null;
                    });
                    _loadEvents();
                    Navigator.pop(context);
                  },
                  selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: _selectedCategory == null 
                        ? AppTheme.primaryColor 
                        : AppColors.textPrimary,
                  ),
                ),
                ..._categories.map((category) {
                  return ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : null;
                      });
                      _loadEvents();
                      Navigator.pop(context);
                    },
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: _selectedCategory == category 
                          ? AppTheme.primaryColor 
                          : AppColors.textPrimary,
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationFilter() {
    // For now, show a simple text input
    // In production, this would use location services
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(
          'Filter by Location',
          style: TextStyle(color: AppTheme.textColor),
        ),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Enter location...',
            hintStyle: TextStyle(color: AppColors.textHint),
          ),
          style: TextStyle(color: AppTheme.textColor),
          onSubmitted: (value) {
            setState(() {
              _selectedLocation = value.isEmpty ? null : value;
            });
            _loadEvents();
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedLocation = null;
              });
              _loadEvents();
              Navigator.pop(context);
            },
            child: Text(
              'Clear',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  void _showDateFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Date',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 16),
            ..._dateFilters.entries.map((entry) {
              return ListTile(
                title: Text(
                  entry.value,
                  style: TextStyle(color: AppTheme.textColor),
                ),
                selected: _selectedDateFilter == entry.key,
                onTap: () {
                  setState(() {
                    _selectedDateFilter = entry.key;
                  });
                  _applyFilters();
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showPriceFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Price',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 16),
            ..._priceFilters.entries.map((entry) {
              return ListTile(
                title: Text(
                  entry.value,
                  style: TextStyle(color: AppTheme.textColor),
                ),
                selected: _selectedPriceFilter == entry.key,
                onTap: () {
                  setState(() {
                    _selectedPriceFilter = entry.key;
                  });
                  _applyFilters();
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedLocation = null;
      _selectedDateFilter = null;
      _selectedPriceFilter = null;
      _selectedEventType = null;
      _searchController.clear();
    });
    _loadEvents();
  }

  Widget _buildEventList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEvents,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_filteredEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No events found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _hasActiveFilters() || _searchController.text.isNotEmpty
                  ? 'Try adjusting your filters'
                  : 'Check back later for new events',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    // Get current user from AuthBloc
    final currentUser = context.read<AuthBloc>().state;
    final user = currentUser is Authenticated ? currentUser.user : null;
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredEvents.length,
      itemBuilder: (context, index) {
        final event = _filteredEvents[index];
        return ExpertiseEventWidget(
          event: event,
          currentUser: null, // TODO: Convert User to UnifiedUser when needed
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailsPage(event: event),
              ),
            );
          },
        );
      },
    );
  }
}

