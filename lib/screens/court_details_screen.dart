import 'package:ehjez/constants.dart';
import 'package:ehjez/widgets/image_slider.dart';
import 'package:ehjez/widgets/sports_court_calendar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _launchURL() async {
  final Uri uri = Uri.parse('https://maps.app.goo.gl/UTYee2MTPFi67wna9');

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw "Could not launch";
  }
}

String _formatSelectedTime(DateTime time) {
  int hour = time.hour;
  final minute = time.minute.toString().padLeft(2, '0');
  String period = hour >= 12 ? 'PM' : 'AM';
  if (hour > 12) {
    hour -= 12;
  } else if (hour == 0) {
    hour = 12;
  }
  return '$hour:$minute $period';
}

void _openWhatsAppPoll(String name, DateTime selectedTime, int duration) async {
  // Calculate end time
  DateTime endTime = selectedTime.add(Duration(hours: duration));

  // Format start and end times
  String startTimeFormatted = _formatTime(selectedTime);
  String endTimeFormatted = _formatTime(endTime);
  String timeSlot = "$startTimeFormatted - $endTimeFormatted";

  // Get day of the week
  final daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  String dayOfWeek = daysOfWeek[selectedTime.weekday - 1];

  // Format date as "DD Month"
  final months = [
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
    'December'
  ];
  String dateFormatted =
      "${selectedTime.day} ${months[selectedTime.month - 1]}";

  // Combine day of week and date
  String dayAndDate = "$dayOfWeek, $dateFormatted";

  // Construct the message
  String message = "$name\n$timeSlot\n$dayAndDate\nYes or No?";

  // Encode and launch WhatsApp
  final encodedMessage = Uri.encodeComponent(message);
  final url = "https://wa.me/?text=$encodedMessage";

  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } else {
    throw "Could not open WhatsApp";
  }
}

// Helper method to format a DateTime (e.g., "8:00 PM")
String _formatTime(DateTime time) {
  int hour = time.hour;
  final minute = time.minute.toString().padLeft(2, '0');
  String period = hour >= 12 ? 'PM' : 'AM';
  if (hour > 12) {
    hour -= 12;
  } else if (hour == 0) {
    hour = 12;
  }
  return '$hour:$minute $period';
}

Future<bool> hasActiveBooking(String userId) async {
  final now = DateTime.now();
  final response = await Supabase.instance.client
      .from('reservations')
      .select()
      .eq('user_id', userId);

  for (var r in response as List<dynamic>) {
    final reservationDate = DateTime.parse(r['date']);
    final startTimeStr = r['start_time'] as String;
    final startHour = int.parse(startTimeStr.split(':')[0]);
    final startMinute = int.parse(startTimeStr.split(':')[1]);
    final startTime = DateTime(
      reservationDate.year,
      reservationDate.month,
      reservationDate.day,
      startHour,
      startMinute,
    );
    final endTime = startTime.add(Duration(hours: r['duration'] as int));
    if (endTime.isAfter(now)) {
      return true;
    }
  }
  return false;
}

Future<bool> checkSlotAvailability(
  String courtId,
  DateTime selectedTime,
  int duration,
  String size,
) async {
  try {
    final date = selectedTime.toIso8601String().split('T')[0];

    // Get number of fields from courts_size_price table
    final sizeResponse = await Supabase.instance.client
        .from('courts_size_price')
        .select('number_of_fields')
        .eq('court_id', courtId)
        .eq('size', size)
        .single();

    final numberOfFields = sizeResponse['number_of_fields'] as int?;

    if (numberOfFields == null || numberOfFields <= 0) {
      return false;
    }

    // Fetch reservations for that court, date, and size
    final reservationsResponse = await Supabase.instance.client
        .from('reservations')
        .select('start_time, duration')
        .eq('court_id', courtId)
        .eq('date', date)
        .eq('size', size);

    List<Map<String, dynamic>> reservations = [];
    for (var r in reservationsResponse as List<dynamic>) {
      final startHour = int.parse(r['start_time'].split(':')[0]);
      final startMinute = int.parse(r['start_time'].split(':')[1]);
      final reservationStartTime = DateTime(
        selectedTime.year,
        selectedTime.month,
        selectedTime.day,
        startHour,
        startMinute,
      );
      reservations.add({
        'start_time': reservationStartTime,
        'duration': r['duration'],
      });
    }

    // Calculate overlapping reservations
    DateTime slotStart = selectedTime;
    DateTime slotEnd = slotStart.add(Duration(hours: duration));

    List<Map<String, dynamic>> overlapping = reservations.where((r) {
      DateTime rStart = r['start_time'];
      DateTime rEnd = rStart.add(Duration(hours: r['duration']));
      return rStart.isBefore(slotEnd) && rEnd.isAfter(slotStart);
    }).toList();

    // Calculate max concurrency
    List<Map<String, dynamic>> events = [];
    for (var r in overlapping) {
      DateTime rStart = r['start_time'];
      DateTime rEnd = rStart.add(Duration(hours: r['duration']));
      DateTime effectiveStart = rStart.isAfter(slotStart) ? rStart : slotStart;
      DateTime effectiveEnd = rEnd.isBefore(slotEnd) ? rEnd : slotEnd;
      events.add({'time': effectiveStart, 'type': 'start'});
      events.add({'time': effectiveEnd, 'type': 'end'});
    }

    events.sort((a, b) {
      int cmp = a['time'].compareTo(b['time']);
      if (cmp == 0) {
        if (a['type'] == 'end' && b['type'] == 'start') return -1;
        if (a['type'] == 'start' && b['type'] == 'end') return 1;
      }
      return cmp;
    });

    int counter = 0;
    int maxCounter = 0;
    for (var event in events) {
      if (event['type'] == 'start') {
        counter++;
        maxCounter = counter > maxCounter ? counter : maxCounter;
      } else {
        counter--;
      }
    }

    return maxCounter < numberOfFields;
  } catch (e) {
    if (kDebugMode) {
      print('Error checking slot availability: $e');
    }
    return false;
  }
}

class CourtDetailsScreen extends StatefulWidget {
  final String id;
  final String name;
  final String category;
  final String location;
  final String phone;
  final String imageUrl;
  final String image2Url;
  final String image3Url;

  const CourtDetailsScreen({
    super.key,
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.phone,
    required this.imageUrl,
    required this.image2Url,
    required this.image3Url,
  });

  @override
  State<CourtDetailsScreen> createState() => _CourtDetailsScreenState();
}

class _CourtDetailsScreenState extends State<CourtDetailsScreen> {
  DateTime? _selectedTimeSlot;
  int _selectedDuration = 2;
  String? _selectedSize;
  int? _selectedPrice1;
  int? _selectedPrice2;
  double commission = 0.0;

  Future<void> _fetchPricesForSize(String size) async {
    try {
      final response = await Supabase.instance.client
          .from('courts_size_price')
          .select('price1, price2')
          .eq('court_id', widget.id)
          .eq('size', size)
          .single();

      setState(() {
        _selectedPrice1 = response['price1'] as int?;
        _selectedPrice2 = response['price2'] as int?;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching prices: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> imageUrls = [
      widget.imageUrl,
      widget.image2Url,
      widget.image3Url
    ].where((url) => url.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ImageSlider(imageUrls: imageUrls),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _infoRow(
                              Icons.sports_soccer, "Category", widget.category),
                          _infoRow(
                              Icons.location_on, "Location", widget.location),
                          _infoRow(Icons.phone, "Phone", widget.phone),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _launchURL,
                              icon: const Icon(Icons.map, color: Colors.white),
                              label: const Text(
                                "Open in Maps",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ehjezGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SportsCourtCalendar(
                    courtId: widget.id,
                    name: widget.name,
                    onTimeSlotSelected: (DateTime selectedSlot, int duration,
                        String size) async {
                      await _fetchPricesForSize(size);
                      setState(() {
                        _selectedTimeSlot = selectedSlot;
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
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            )
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
                      ? "Price: ${_selectedDuration == 2 ? (_selectedPrice2 ?? 'N/A') : (_selectedPrice1 ?? 'N/A')} JDs"
                      : "Select time slot",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedTimeSlot != null
                      ? "${_formatSelectedTime(_selectedTimeSlot!)} ($_selectedDuration Hour${_selectedDuration > 1 ? "s" : ""})"
                      : "",
                  style: const TextStyle(
                    fontSize: 16,
                  ),
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
                      widget.name, _selectedTimeSlot!, _selectedDuration)
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
                      final userId =
                          Supabase.instance.client.auth.currentUser?.id;
                      if (userId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Please log in to make a reservation')),
                        );
                        return;
                      }

                      // Check if user has an active booking
                      if (await hasActiveBooking(userId)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'You already have a booking. Only one booking is allowed.'),
                          ),
                        );
                        return;
                      }

                      final date =
                          _selectedTimeSlot!.toIso8601String().split('T')[0];
                      final startTime =
                          '${_selectedTimeSlot!.hour.toString().padLeft(2, '0')}:${_selectedTimeSlot!.minute.toString().padLeft(2, '0')}:00';
                      final duration = _selectedDuration;
                      final size = _selectedSize!;

                      bool isAvailable = await checkSlotAvailability(
                        widget.id,
                        _selectedTimeSlot!,
                        duration,
                        size,
                      );

                      if (isAvailable) {
                        try {
                          await Supabase.instance.client
                              .from('reservations')
                              .insert({
                            'user_id': userId,
                            'court_id': widget.id,
                            'date': date,
                            'start_time': startTime,
                            'duration': duration,
                            'size': size,
                            'commission': _selectedDuration == 2
                                ? (_selectedPrice2! * 0.03)
                                : (_selectedPrice1! * 0.03),
                            'price': _selectedDuration == 2
                                ? _selectedPrice2
                                : _selectedPrice1
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Reservation successful!')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Error making reservation: $e')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Selected slot is no longer available. Please choose another slot.'),
                          ),
                        );
                      }
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
          Icon(icon, color: const Color(0xFF068631), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
