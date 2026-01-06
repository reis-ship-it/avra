import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spots/core/models/reservation.dart';
import 'package:spots/core/models/unified_user.dart';
import 'package:spots/core/services/reservation_service.dart';
import 'package:spots/core/services/reservation_recommendation_service.dart';
import 'package:spots/core/services/expertise_event_service.dart';
import 'package:spots/core/theme/colors.dart';
import 'package:spots/core/theme/app_theme.dart';
import 'package:spots/presentation/blocs/auth/auth_bloc.dart';
import 'package:spots/injection_container.dart' as di;

/// Reservation Creation Page
/// Phase 15: Reservation System Implementation
/// 
/// CRITICAL: Uses AppColors/AppTheme (100% adherence required)
///
/// Features:
/// - Form for reservation details
/// - Integration with spots/events/businesses
/// - Quantum compatibility display
/// - Confirmation flow
class CreateReservationPage extends StatefulWidget {
  final ReservationType? type;
  final String? targetId;
  final String? targetTitle;

  const CreateReservationPage({
    super.key,
    this.type,
    this.targetId,
    this.targetTitle,
  });

  @override
  State<CreateReservationPage> createState() => _CreateReservationPageState();
}

class _CreateReservationPageState extends State<CreateReservationPage> {
  final _formKey = GlobalKey<FormState>();
  late final ReservationService _reservationService;
  late final ReservationRecommendationService _recommendationService;
  late final ExpertiseEventService _eventService;

  // Form fields
  ReservationType? _selectedType;
  String? _selectedTargetId;
  String? _selectedTargetTitle;
  DateTime? _reservationTime;
  int _partySize = 1;
  int _ticketCount = 1;
  String? _specialRequests;
  double? _compatibilityScore;

  // State
  bool _isLoading = false;
  bool _isLoadingCompatibility = false;
  String? _error;
  UnifiedUser? _currentUser;
  List<Map<String, dynamic>> _availableTargets = [];

  @override
  void initState() {
    super.initState();
    _reservationService = di.sl<ReservationService>();
    _recommendationService = di.sl<ReservationRecommendationService>();
    _eventService = ExpertiseEventService();

    // Pre-fill from widget parameters
    _selectedType = widget.type;
    _selectedTargetId = widget.targetId;
    _selectedTargetTitle = widget.targetTitle;

    _loadUserData();
    _loadAvailableTargets();
  }

  Future<void> _loadUserData() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      setState(() {
        _error = 'Please sign in to create reservations';
      });
      return;
    }

    final user = authState.user;

    // Convert User to UnifiedUser
    _currentUser = UnifiedUser(
      id: user.id,
      email: user.email,
      displayName: user.displayName ?? user.name,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      isOnline: user.isOnline ?? false,
    );
  }

  Future<void> _loadAvailableTargets() async {
    if (_selectedType == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_selectedType == ReservationType.event) {
        // Load events
        final events = await _eventService.searchEvents(maxResults: 50);
        setState(() {
          _availableTargets = events.map((e) => {
            'id': e.id,
            'title': e.title,
            'type': 'event',
            'startTime': e.startTime,
            'endTime': e.endTime,
          }).toList();
        });
      } else {
        // For spots and businesses, we'd load from their respective services
        // For now, if targetId is provided, use it
        if (_selectedTargetId != null && _selectedTargetTitle != null) {
          setState(() {
            _availableTargets = [{
              'id': _selectedTargetId,
              'title': _selectedTargetTitle,
              'type': _selectedType.toString(),
            }];
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load available options: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectReservationTime() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _reservationTime ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Also select time
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppTheme.primaryColor,
                onPrimary: AppColors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _reservationTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
        _calculateCompatibility();
      }
    }
  }

  Future<void> _calculateCompatibility() async {
    if (_currentUser == null || _selectedTargetId == null || _reservationTime == null) {
      return;
    }

    setState(() {
      _isLoadingCompatibility = true;
    });

    try {
      // Get recommendations to find compatibility score
      final recommendations = await _recommendationService.getQuantumMatchedReservations(
        userId: _currentUser!.id,
        limit: 50,
      );

      final matchingRecommendation = recommendations.firstWhere(
        (r) => r.targetId == _selectedTargetId,
        orElse: () => recommendations.first,
      );

      setState(() {
        _compatibilityScore = matchingRecommendation.compatibility;
      });
    } catch (e) {
      // Compatibility calculation failed, continue without it
      setState(() {
        _compatibilityScore = null;
      });
    } finally {
      setState(() {
        _isLoadingCompatibility = false;
      });
    }
  }

  Future<void> _createReservation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_currentUser == null) {
      setState(() {
        _error = 'Please sign in to create reservations';
      });
      return;
    }

    if (_selectedType == null || _selectedTargetId == null || _reservationTime == null) {
      setState(() {
        _error = 'Please fill in all required fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Check for existing reservation
      final hasExisting = await _reservationService.hasExistingReservation(
        userId: _currentUser!.id,
        type: _selectedType!,
        targetId: _selectedTargetId!,
        reservationTime: _reservationTime!,
      );

      if (hasExisting) {
        setState(() {
          _error = 'You already have a reservation for this at this time';
          _isLoading = false;
        });
        return;
      }

      // Create reservation
      final reservation = await _reservationService.createReservation(
        userId: _currentUser!.id,
        type: _selectedType!,
        targetId: _selectedTargetId!,
        reservationTime: _reservationTime!,
        partySize: _partySize,
        ticketCount: _ticketCount,
        specialRequests: _specialRequests?.isEmpty ?? true ? null : _specialRequests,
      );

      // Navigate to success page or detail page
      if (mounted) {
        Navigator.of(context).pop(reservation);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reservation created successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to create reservation: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Reservation'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppColors.white,
      ),
      body: _currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.errorColor),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: AppTheme.errorColor),
                        ),
                      ),

                    // Reservation Type
                    DropdownButtonFormField<ReservationType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Reservation Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.event, color: AppTheme.primaryColor),
                      ),
                      items: ReservationType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.toString().split('.').last.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value;
                          _selectedTargetId = null;
                          _selectedTargetTitle = null;
                        });
                        _loadAvailableTargets();
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a reservation type';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Target Selection (Event/Spot/Business)
                    if (_selectedType != null && _availableTargets.isNotEmpty)
                      DropdownButtonFormField<String>(
                        value: _selectedTargetId,
                        decoration: InputDecoration(
                          labelText: _selectedType == ReservationType.event
                              ? 'Select Event'
                              : _selectedType == ReservationType.spot
                                  ? 'Select Spot'
                                  : 'Select Business',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.location_on, color: AppTheme.primaryColor),
                        ),
                        items: _availableTargets.map((target) {
                          return DropdownMenuItem(
                            value: target['id'] as String,
                            child: Text(target['title'] as String),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTargetId = value;
                            _selectedTargetTitle = _availableTargets
                                .firstWhere((t) => t['id'] == value)['title'] as String;
                          });
                          _calculateCompatibility();
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a target';
                          }
                          return null;
                        },
                      ),

                    const SizedBox(height: 16),

                    // Reservation Time
                    InkWell(
                      onTap: _selectReservationTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Reservation Time',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                        ),
                        child: Text(
                          _reservationTime != null
                              ? _reservationTime!.toLocal().toString().split('.')[0]
                              : 'Select date and time',
                          style: TextStyle(
                            color: _reservationTime != null
                                ? AppColors.black
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Party Size
                    TextFormField(
                      initialValue: _partySize.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Party Size',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.people, color: AppTheme.primaryColor),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _partySize = int.tryParse(value) ?? 1;
                          _ticketCount = _partySize;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter party size';
                        }
                        final size = int.tryParse(value);
                        if (size == null || size < 1) {
                          return 'Party size must be at least 1';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Special Requests
                    TextFormField(
                      controller: TextEditingController(text: _specialRequests),
                      decoration: const InputDecoration(
                        labelText: 'Special Requests (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note, color: AppTheme.primaryColor),
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        setState(() {
                          _specialRequests = value.isEmpty ? null : value;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // Quantum Compatibility Score
                    if (_isLoadingCompatibility)
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Calculating compatibility...',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    else if (_compatibilityScore != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.primaryColor),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              'Quantum Compatibility: ${(_compatibilityScore! * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Create Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _createReservation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                              ),
                            )
                          : const Text(
                              'Create Reservation',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
