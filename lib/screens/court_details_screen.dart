import 'package:ehjez/constants.dart';
import 'package:ehjez/models/court.dart';
import 'package:ehjez/providers/providers.dart';
import 'package:ehjez/screens/auth/login_check_screen.dart';
import 'package:ehjez/widgets/image_slider.dart';
import 'package:ehjez/widgets/sports_court_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── Helpers ─────────────────────────────────────────────────────────────────

String _formatTime(DateTime time) {
  int hour = time.hour;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = hour >= 12 ? 'PM' : 'AM';
  if (hour == 0)
    hour = 12;
  else if (hour > 12) hour -= 12;
  return '$hour:$minute $period';
}

Future<void> _openWhatsAppPoll(
    String name, DateTime selectedTime, int duration) async {
  final endTime = selectedTime.add(Duration(hours: duration));
  const days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final message =
      '$name\n${_formatTime(selectedTime)} - ${_formatTime(endTime)}\n'
      '${days[selectedTime.weekday - 1]}, ${selectedTime.day} ${months[selectedTime.month - 1]}';
  final url = 'https://wa.me/?text=${Uri.encodeComponent(message)}';
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class CourtDetailsScreen extends ConsumerStatefulWidget {
  // Now accepts a Court model directly — no more long constructor arg lists.
  final Court court;

  const CourtDetailsScreen({super.key, required this.court});

  @override
  ConsumerState<CourtDetailsScreen> createState() => _CourtDetailsScreenState();
}

class _CourtDetailsScreenState extends ConsumerState<CourtDetailsScreen> {
  DateTime? _selectedTimeSlot;
  int _selectedDuration = 2;
  String? _selectedSize;
  int? _selectedPrice1;
  int? _selectedPrice2;

  Future<void> _fetchPricesForSize(String size) async {
    try {
      final sp = await ref
          .read(courtRepositoryProvider)
          .fetchSizePriceForSize(widget.court.id, size);
      if (!mounted) return;
      setState(() {
        _selectedPrice1 = sp.price1;
        _selectedPrice2 = sp.price2;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching prices: $e')),
      );
    }
  }

  Future<void> _makeReservation() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to make a reservation')),
      );
      return;
    }

    final userPhone = Supabase.instance.client.auth.currentUser?.phone;
    if (userPhone == null || userPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not find your phone number on this account'),
        ),
      );
      return;
    }

    final repo = ref.read(reservationRepositoryProvider);

    final hasBooking = await repo.hasActiveBooking(userId);
    if (!mounted) return;
    if (hasBooking) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'You already have a booking. Only one booking is allowed.')),
      );
      return;
    }

    final isAvailable = await repo.checkSlotAvailability(
      courtId: widget.court.id,
      selectedTime: _selectedTimeSlot!,
      duration: _selectedDuration,
      size: _selectedSize!,
    );
    if (!mounted) return;

    if (!isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Slot no longer available. Please choose another time.')),
      );
      return;
    }

    try {
      final price =
          _selectedDuration == 2 ? _selectedPrice2! : _selectedPrice1!;
      await repo.createReservation(
        userId: userId,
        phone: userPhone,
        courtId: widget.court.id,
        date: _selectedTimeSlot!.toIso8601String().split('T')[0],
        startTime:
            '${_selectedTimeSlot!.hour.toString().padLeft(2, '0')}:${_selectedTimeSlot!.minute.toString().padLeft(2, '0')}:00',
        duration: _selectedDuration,
        size: _selectedSize!,
        price: price,
        commission: price * 0.03,
      );
      if (!mounted) return;

      // Invalidate bookings cache so BookingsScreen shows the new reservation.
      ref.invalidate(userReservationsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservation successful!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error making reservation: $e')),
      );
    }
  }

  Future<void> _launchURL() async {
    final url = widget.court.locationUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  int get _displayPrice =>
      _selectedDuration == 2 ? (_selectedPrice2 ?? 0) : (_selectedPrice1 ?? 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.court.name),
        titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ImageSlider(imageUrls: widget.court.imageUrls),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _infoRow(Icons.sports_soccer, 'Category',
                              widget.court.category),
                          _infoRow(Icons.location_on, 'Location',
                              widget.court.location),
                          _infoRow(Icons.phone, 'Phone', widget.court.phone),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _launchURL,
                              icon: const Icon(Icons.map, color: Colors.white),
                              label: const Text('Get directions',
                                  style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ehjezGreen,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SportsCourtCalendar(
                    courtId: widget.court.id,
                    name: widget.court.name,
                    onTimeSlotSelected:
                        (DateTime slot, int duration, String size) async {
                      await _fetchPricesForSize(size);
                      setState(() {
                        _selectedTimeSlot = slot;
                        _selectedDuration = duration;
                        _selectedSize = size;
                      });
                    },
                    onSelectionReset: () {
                      setState(() {
                        _selectedTimeSlot = null;
                        _selectedSize = null;
                        _selectedPrice1 = null;
                        _selectedPrice2 = null;
                      });
                    },
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(40, 20, 25, 40),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedTimeSlot != null
                      ? 'Price: $_displayPrice JDs'
                      : 'Select time slot',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                if (_selectedTimeSlot != null)
                  Text(
                    '${_formatTime(_selectedTimeSlot!)} ($_selectedDuration Hour${_selectedDuration > 1 ? "s" : ""})',
                    style: const TextStyle(fontSize: 16),
                  ),
              ],
            ),
            IconButton(
              icon: Icon(
                Icons.wechat,
                color: _selectedTimeSlot != null
                    ? ehjezGreen
                    : Colors.grey.shade400,
              ),
              onPressed: _selectedTimeSlot != null
                  ? () => _openWhatsAppPoll(
                      widget.court.name, _selectedTimeSlot!, _selectedDuration)
                  : null,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedTimeSlot != null
                    ? ehjezGreen
                    : Colors.grey.shade400,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _selectedTimeSlot != null
                  ? () async {
                      // ── Guest guard ───────────────────────────────────
                      // If not logged in, send user to login first.
                      final userId = ref.read(currentUserIdProvider);
                      if (userId == null) {
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => LoginCheckScreen()),
                        );
                        return;
                      }

                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Confirm Reservation'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Court: ${widget.court.name}'),
                              const SizedBox(height: 8),
                              Text(
                                  'Date: ${_selectedTimeSlot!.day}/${_selectedTimeSlot!.month}/${_selectedTimeSlot!.year}'),
                              const SizedBox(height: 8),
                              Text('Time: ${_formatTime(_selectedTimeSlot!)}'),
                              const SizedBox(height: 8),
                              Text(
                                  'Duration: $_selectedDuration Hour${_selectedDuration > 1 ? "s" : ""}'),
                              const SizedBox(height: 8),
                              Text('Size: $_selectedSize'),
                              const SizedBox(height: 8),
                              Text('Price: $_displayPrice JDs'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: ehjezGreen),
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Confirm',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) await _makeReservation();
                    }
                  : null,
              child: const Text('Confirm',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: ehjezGreen, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
