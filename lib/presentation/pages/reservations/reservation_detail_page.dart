import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spots/core/models/reservation.dart';
import 'package:spots/core/models/unified_user.dart';
import 'package:spots/core/services/reservation_service.dart';
import 'package:spots/core/theme/colors.dart';
import 'package:spots/core/theme/app_theme.dart';
import 'package:spots/presentation/blocs/auth/auth_bloc.dart';
import 'package:spots/injection_container.dart' as di;

/// Reservation Detail Page
/// Phase 15: Reservation System Implementation
/// 
/// CRITICAL: Uses AppColors/AppTheme (100% adherence required)
/// 
/// Features:
/// - Full reservation details
/// - Modification options
/// - Cancellation flow
/// - Dispute filing
class ReservationDetailPage extends StatefulWidget {
  final String reservationId;

  const ReservationDetailPage({
    super.key,
    required this.reservationId,
  });

  @override
  State<ReservationDetailPage> createState() => _ReservationDetailPageState();
}

class _ReservationDetailPageState extends State<ReservationDetailPage> {
  late final ReservationService _reservationService;

  Reservation? _reservation;
  bool _isLoading = false;
  bool _isCancelling = false;
  String? _error;
  UnifiedUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _reservationService = di.sl<ReservationService>();
    _loadReservation();
  }

  Future<void> _loadReservation() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      setState(() {
        _error = 'Please sign in to view reservation details';
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

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get all user reservations and find the one we need
      final reservations = await _reservationService.getUserReservations(
        userId: _currentUser!.id,
      );

      final reservation = reservations.firstWhere(
        (r) => r.id == widget.reservationId,
        orElse: () => throw Exception('Reservation not found'),
      );

      setState(() {
        _reservation = reservation;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load reservation: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelReservation() async {
    if (_reservation == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Reservation'),
        content: const Text('Are you sure you want to cancel this reservation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isCancelling = true;
      _error = null;
    });

    try {
      await _reservationService.cancelReservation(
        reservationId: _reservation!.id,
        reason: 'User request',
      );

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate refresh needed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reservation cancelled successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to cancel reservation: $e';
        _isCancelling = false;
      });
    }
  }

  Color _getStatusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.pending:
        return AppTheme.warningColor;
      case ReservationStatus.confirmed:
        return AppTheme.successColor;
      case ReservationStatus.cancelled:
        return AppTheme.errorColor;
      case ReservationStatus.completed:
        return AppTheme.primaryColor;
      case ReservationStatus.noShow:
        return AppTheme.errorColor;
    }
  }

  String _getTypeLabel(ReservationType type) {
    switch (type) {
      case ReservationType.event:
        return 'Event';
      case ReservationType.spot:
        return 'Spot';
      case ReservationType.business:
        return 'Business';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation Details'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppColors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: TextStyle(color: AppTheme.errorColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadReservation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: AppColors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _reservation == null
                  ? const Center(child: Text('Reservation not found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _getStatusColor(_reservation!.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _getStatusColor(_reservation!.status)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _reservation!.status.toString().split('.').last.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(_reservation!.status),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Reservation Type
                          _DetailRow(
                            icon: Icons.category,
                            label: 'Type',
                            value: _getTypeLabel(_reservation!.type),
                          ),

                          const SizedBox(height: 16),

                          // Target ID
                          _DetailRow(
                            icon: Icons.location_on,
                            label: 'Target',
                            value: _reservation!.targetId,
                          ),

                          const SizedBox(height: 16),

                          // Reservation Time
                          _DetailRow(
                            icon: Icons.calendar_today,
                            label: 'Reservation Time',
                            value: _reservation!.reservationTime.toLocal().toString().split('.')[0],
                          ),

                          const SizedBox(height: 16),

                          // Party Size
                          _DetailRow(
                            icon: Icons.people,
                            label: 'Party Size',
                            value: '${_reservation!.partySize} ${_reservation!.partySize == 1 ? 'person' : 'people'}',
                          ),

                          const SizedBox(height: 16),

                          // Ticket Count
                          _DetailRow(
                            icon: Icons.confirmation_number,
                            label: 'Tickets',
                            value: '${_reservation!.ticketCount}',
                          ),

                          if (_reservation!.specialRequests != null) ...[
                            const SizedBox(height: 16),
                            _DetailRow(
                              icon: Icons.note,
                              label: 'Special Requests',
                              value: _reservation!.specialRequests!,
                            ),
                          ],

                          if (_reservation!.ticketPrice != null) ...[
                            const SizedBox(height: 16),
                            _DetailRow(
                              icon: Icons.attach_money,
                              label: 'Ticket Price',
                              value: '\$${_reservation!.ticketPrice!.toStringAsFixed(2)}',
                            ),
                          ],

                          if (_reservation!.depositAmount != null) ...[
                            const SizedBox(height: 16),
                            _DetailRow(
                              icon: Icons.payment,
                              label: 'Deposit',
                              value: '\$${_reservation!.depositAmount!.toStringAsFixed(2)}',
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Actions
                          if (_reservation!.status != ReservationStatus.cancelled &&
                              _reservation!.status != ReservationStatus.completed &&
                              _reservation!.status != ReservationStatus.noShow)
                            ElevatedButton(
                              onPressed: _isCancelling ? null : _cancelReservation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.errorColor,
                                foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isCancelling
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Cancel Reservation',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                            ),
                        ],
                      ),
                    ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
