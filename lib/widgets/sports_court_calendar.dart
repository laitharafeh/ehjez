import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

class SportsCourtCalendar extends StatefulWidget {
  final String courtId;
  final String name;

  const SportsCourtCalendar({
    required this.name,
    required this.courtId,
    super.key,
  });

  @override
  State<SportsCourtCalendar> createState() => _SportsCourtCalendarState();
}

class _SportsCourtCalendarState extends State<SportsCourtCalendar> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  final Map<DateTime, List<Map<String, dynamic>>> _reservations = {};
  bool _isLoading = false;
  int _selectedDuration = 2; // Default to 2 hours
  DateTime? _courtStartTime;
  DateTime? _courtEndTime;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _fetchCourtTime();
  }

  /// Fetches the court's start and end time from Supabase
  Future<void> _fetchCourtTime() async {
    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client
          .from('courts')
          .select('start_time, end_time')
          .eq('id', widget.courtId)
          .single();

      if (response != null) {
        final now = DateTime.now();
        _courtStartTime = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(response['start_time'].split(':')[0]),
          0, // Set to HH:00 as requested
        );
        _courtEndTime = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(response['end_time'].split(':')[0]),
          0, // Set to HH:00 as requested
        );

        await _fetchReservations();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading court time: $e')),
        );
      }
      // Fallback to defaults if fetch fails
      _courtStartTime = DateTime.now().copyWith(hour: 8, minute: 0);
      _courtEndTime = DateTime.now().copyWith(hour: 22, minute: 0);
      await _fetchReservations();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Fetches reservations from Supabase
  Future<void> _fetchReservations() async {
    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client
          .from('reservations')
          .select()
          .eq('court_id', widget.courtId)
          .gte('date', DateTime.now().toIso8601String().split('T')[0])
          .order('start_time', ascending: true);

      _reservations.clear();
      for (var reservation in response as List<dynamic>) {
        final date = DateTime.parse(reservation['date']);
        final startTimeStr = reservation['start_time'] as String;
        final startTime = DateTime(
          date.year,
          date.month,
          date.day,
          int.parse(startTimeStr.split(':')[0]),
          int.parse(startTimeStr.split(':')[1]),
        );

        final dateKey = DateTime(date.year, date.month, date.day);
        _reservations[dateKey] ??= [];
        _reservations[dateKey]!.add({
          'start_time': startTime,
          'duration': reservation['duration'],
          'user_id': reservation['user_id'],
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reservations: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Returns available time slots dynamically based on the court's schedule
  List<Map<String, dynamic>> _getAvailableSlots(DateTime day) {
    if (_courtStartTime == null || _courtEndTime == null) return [];

    final dayStart =
        DateTime(day.year, day.month, day.day, _courtStartTime!.hour, 0);
    final dayEnd =
        DateTime(day.year, day.month, day.day, _courtEndTime!.hour, 0);
    final reservedTimes =
        _reservations[DateTime(day.year, day.month, day.day)] ?? [];

    List<Map<String, dynamic>> slots = [];
    DateTime currentTime = dayStart;

    while (currentTime.isBefore(dayEnd)) {
      final slotEnd = currentTime.add(Duration(hours: _selectedDuration));

      bool isReserved = reservedTimes.any((r) {
        final start = r['start_time'] as DateTime;
        final end = start.add(Duration(hours: r['duration'] as int));
        return currentTime.isBefore(end) && slotEnd.isAfter(start);
      });

      if (slotEnd.isAfter(dayEnd)) {
        isReserved = true; // Mark as reserved if it exceeds end time
      }

      slots.add({
        'time': currentTime,
        'isAvailable': !isReserved,
      });

      currentTime = currentTime.add(const Duration(hours: 1)); // Step by 1 hour
    }

    return slots;
  }

  /// Formats a DateTime hour to 12-hour format with AM/PM
  String _formatHour(DateTime time) {
    int hour = time.hour;
    String period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) {
      hour = 12; // Midnight
    } else if (hour > 12) {
      hour -= 12; // Convert to 12-hour
    }
    return '$hour:00 $period';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            widget.name,
            style: Theme.of(context).appBarTheme.titleTextStyle ??
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        TableCalendar(
          availableGestures: AvailableGestures.horizontalSwipe,
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(const Duration(days: 30)),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          eventLoader: (day) {
            return _reservations[DateTime(day.year, day.month, day.day)] ?? [];
          },
          calendarStyle: const CalendarStyle(
            markersAlignment: Alignment.bottomRight,
            selectedDecoration: BoxDecoration(
              color: Color(0xFF068631),
              shape: BoxShape.circle,
            ),
          ),
          availableCalendarFormats: const {
            CalendarFormat.month: 'Month',
          },
          calendarFormat: CalendarFormat.month,
          onFormatChanged: null,
        ),
        const Divider(),

        // Duration Selection Toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Duration',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Center(
                child: ToggleButtons(
                  isSelected: [_selectedDuration == 1, _selectedDuration == 2],
                  onPressed: (index) {
                    setState(() {
                      _selectedDuration = index + 1;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  selectedColor: Colors.white,
                  color: Colors.black,
                  fillColor: const Color(0xFF068631),
                  children: const [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('1 Hour'),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('2 Hours'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (_selectedDay != null) ...[
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Available Times for ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _fetchReservations,
                tooltip: 'Refresh Reservations',
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._getAvailableSlots(_selectedDay!).map((slot) {
            final time = slot['time'] as DateTime;
            final isAvailable = slot['isAvailable'] as bool;
            final endTime = time.add(Duration(hours: _selectedDuration));

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isAvailable ? const Color(0xFFC8E6C9) : Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_formatHour(time)} - ${_formatHour(endTime)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isAvailable ? 'Available' : 'Reserved',
                    style: TextStyle(
                      color: isAvailable ? Colors.green[800] : Colors.red[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ] else
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Select a day to view available slots'),
          ),
      ],
    );
  }
}
