import 'package:ehjez/providers/providers.dart';
import 'package:ehjez/models/reservation.dart';
import 'package:ehjez/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(userReservationsProvider);

    return Scaffold(
      appBar: CustomAppBar(),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (bookings) {
          if (bookings.isEmpty) {
            return const Center(child: Text('No bookings found.'));
          }

          final now = DateTime.now();
          final current = bookings
              .where((b) => b.startDateTime.isAfter(now))
              .toList()
            ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
          final previous = bookings
              .where((b) => !b.startDateTime.isAfter(now))
              .toList()
            ..sort((a, b) => b.startDateTime.compareTo(a.startDateTime));

          return RefreshIndicator(
            // Pull to refresh — re-fetches from Supabase and updates the cache.
            onRefresh: () => ref.refresh(userReservationsProvider.future),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _sectionHeader('Current Bookings'),
                if (current.isEmpty)
                  const ListTile(title: Text('No upcoming bookings'))
                else
                  ...current.expand((b) => [
                        _BookingTile(
                          booking: b,
                          isCurrent: true,
                          onCancel: () => _confirmAndCancel(context, ref, b),
                        ),
                        const Divider(),
                      ]),
                _sectionHeader('Previous Bookings'),
                if (previous.isEmpty)
                  const ListTile(title: Text('No previous bookings'))
                else
                  ...previous.expand((b) => [
                        _BookingTile(booking: b, isCurrent: false),
                        const Divider(),
                      ]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }

  Future<void> _confirmAndCancel(
      BuildContext context, WidgetRef ref, Reservation booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text(
            'Cancel your booking at ${booking.courtName ?? 'this court'} on ${booking.date}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child:
                const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref
          .read(reservationRepositoryProvider)
          .deleteReservation(booking.id);
      // Invalidate so BookingsScreen auto-refreshes with the new list.
      ref.invalidate(userReservationsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cancelling booking: $e')),
        );
      }
    }
  }
}

class _BookingTile extends StatelessWidget {
  final Reservation booking;
  final bool isCurrent;
  final VoidCallback? onCancel;

  const _BookingTile({
    required this.booking,
    required this.isCurrent,
    this.onCancel,
  });

  IconData get _icon {
    switch ((booking.courtCategory ?? '').toLowerCase()) {
      case 'padel':
      case 'tennis':
      case 'badminton':
        return Icons.sports_tennis;
      case 'basketball':
        return Icons.sports_basketball;
      case 'volleyball':
        return Icons.sports_volleyball;
      default:
        return Icons.sports_soccer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Theme.of(context).cardColor,
      leading: Icon(_icon, size: 32),
      title: Text(
        booking.courtName ?? 'Unknown Court',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
          'Date: ${booking.date}\nStart: ${booking.startTime}, Duration: ${booking.duration}h'),
      trailing: isCurrent
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: onCancel,
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }
}
