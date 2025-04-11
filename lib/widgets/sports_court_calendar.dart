import 'package:ehjez/constants.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

class SportsCourtCalendar extends StatefulWidget {
  final String courtId;
  final String name;
  // Updated callback to pass both the selected time and duration.
  final void Function(DateTime, int)? onTimeSlotSelected;
  // New callback to notify that selection should be reset.
  final VoidCallback? onSelectionReset;

  const SportsCourtCalendar({
    required this.name,
    required this.courtId,
    this.onTimeSlotSelected,
    this.onSelectionReset,
    super.key,
  });

  @override
  State<SportsCourtCalendar> createState() => _SportsCourtCalendarState();
}

class _SportsCourtCalendarState extends State<SportsCourtCalendar> {
  DateTime? _selectedSlotTime;
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  final Map<DateTime, List<Map<String, dynamic>>> _reservations = {};
  bool _isLoading = false;
  int _selectedDuration = 2;
  DateTime? _courtStartTime;
  DateTime? _courtEndTime;
  // flag used when end_time from Supabase is "23:59:59"
  bool _isEndTimeSpecial = false;
  final Map<String, int> _courtSizes = {};
  String? _selectedSize;
  int? _numberOfFields;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _fetchCourtTime();
  }

  Future<void> _fetchCourtTime() async {
    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client
          .from('courts')
          .select(
              'start_time, end_time, size1, number_of_fields1, size2, number_of_fields2, size3, number_of_fields3')
          .eq('id', widget.courtId)
          .single();

      if (response.isNotEmpty) {
        final now = DateTime.now();
        String endTimeStr = response['end_time'] as String;

        // If end_time is exactly "23:59:59", mark it as special.
        if (endTimeStr == "23:59:59") {
          _isEndTimeSpecial = true;
        }

        int startHour = int.parse(response['start_time'].split(':')[0]);
        int endHour = int.parse(endTimeStr.split(':')[0]);

        _courtStartTime = DateTime(now.year, now.month, now.day, startHour);
        // When not special, _courtEndTime remains on the same day (or next day if rolled over)
        _courtEndTime = endHour >= startHour
            ? DateTime(now.year, now.month, now.day, endHour)
            : DateTime(now.year, now.month, now.day + 1, endHour);

        // We keep the original _courtEndTime even for special cases;
        // later in _getAvailableSlots we will adjust how we treat it.
        _courtSizes.clear();
        if (response['size1'] != null &&
            response['size1'].isNotEmpty &&
            response['number_of_fields1'] > 0) {
          _courtSizes[response['size1']] = response['number_of_fields1'];
        }
        if (response['size2'] != null &&
            response['size2'].isNotEmpty &&
            response['number_of_fields2'] > 0) {
          _courtSizes[response['size2']] = response['number_of_fields2'];
        }
        if (response['size3'] != null &&
            response['size3'].isNotEmpty &&
            response['number_of_fields3'] > 0) {
          _courtSizes[response['size3']] = response['number_of_fields3'];
        }

        if (_courtSizes.isNotEmpty) {
          _selectedSize = _courtSizes.keys.first;
          _numberOfFields = _courtSizes[_selectedSize];
        }

        await _fetchReservations();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading court data: $e')),
        );
      }
      _courtStartTime = DateTime.now().copyWith(hour: 8, minute: 0);
      _courtEndTime = DateTime.now()
          .copyWith(hour: 2, minute: 0)
          .add(const Duration(days: 1));
      await _fetchReservations();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchReservations() async {
    if (_selectedSize == null) return;

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client
          .from('reservations')
          .select()
          .eq('court_id', widget.courtId)
          .eq('size', _selectedSize!)
          .gte('date', DateTime.now().toIso8601String().split('T')[0])
          .order('start_time', ascending: true);

      _reservations.clear();
      for (var reservation in response as List<dynamic>) {
        final date = DateTime.parse(reservation['date']);
        final startTimeStr = reservation['start_time'] as String;
        final startHour = int.parse(startTimeStr.split(':')[0]);
        final startMinute = int.parse(startTimeStr.split(':')[1]);
        final startTime =
            DateTime(date.year, date.month, date.day, startHour, startMinute);
        final dateKey = DateTime(date.year, date.month, date.day);
        _reservations[dateKey] ??= [];
        _reservations[dateKey]!.add({
          'start_time': startTime,
          'duration': reservation['duration'],
          'user_id': reservation['user_id'],
          'size': reservation['size'],
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

  int _getMaxConcurrency(DateTime slotStart, DateTime slotEnd,
      List<Map<String, dynamic>> reservations) {
    List<Map<String, dynamic>> overlapping = reservations.where((r) {
      DateTime rStart = r['start_time'];
      DateTime rEnd = rStart.add(Duration(hours: r['duration']));
      return rStart.isBefore(slotEnd) && rEnd.isAfter(slotStart);
    }).toList();

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
    return maxCounter;
  }

  List<Map<String, dynamic>> _getAvailableSlots(DateTime day) {
    if (_courtStartTime == null ||
        _courtEndTime == null ||
        _selectedSize == null ||
        _numberOfFields == null) {
      return [];
    }

    // Compute dayStart from _courtStartTime.
    final dayStart = DateTime(
      day.year,
      day.month,
      day.day,
      _courtStartTime!.hour,
      _courtStartTime!.minute,
    );

    // For a special end time, treat dayEnd as midnight; otherwise, use the provided end time.
    DateTime dayEnd;
    if (_isEndTimeSpecial) {
      dayEnd = DateTime(day.year, day.month, day.day + 1, 0, 0);
    } else {
      dayEnd = _courtEndTime!.isAfter(_courtStartTime!)
          ? DateTime(day.year, day.month, day.day, _courtEndTime!.hour,
              _courtEndTime!.minute)
          : DateTime(day.year, day.month, day.day + 1, _courtEndTime!.hour,
              _courtEndTime!.minute);
    }

    final reservedTimes =
        _reservations[DateTime(day.year, day.month, day.day)] ?? [];

    List<Map<String, dynamic>> slots = [];
    DateTime currentTime = dayStart;

    while (true) {
      final slotEnd = currentTime.add(Duration(hours: _selectedDuration));

      // If the 2-hour slot goes out of range then stop.
      if (_selectedDuration == 2 && slotEnd.isAfter(dayEnd)) break;

      // Stop if current slot start reaches/passes dayEnd.
      if (currentTime.isAtSameMomentAs(dayEnd) || currentTime.isAfter(dayEnd)) {
        break;
      }

      bool isWithinRange;
      if (_isEndTimeSpecial &&
          _selectedDuration == 1 &&
          slotEnd.hour == 0 &&
          slotEnd.minute == 0) {
        isWithinRange =
            _getMaxConcurrency(currentTime, slotEnd, reservedTimes) <
                _numberOfFields!;
      } else if (slotEnd.isAfter(dayEnd)) {
        isWithinRange = false;
      } else {
        isWithinRange =
            _getMaxConcurrency(currentTime, slotEnd, reservedTimes) <
                _numberOfFields!;
      }

      slots.add({
        'time': currentTime,
        'isAvailable': isWithinRange,
      });

      // Move to next slot start time.
      currentTime = currentTime.add(const Duration(hours: 1));
      if (currentTime.isAfter(dayEnd)) break;
    }

    return slots;
  }

  String _formatHour(DateTime time) {
    int hour = time.hour;
    String period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }
    return '$hour:00 $period';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Sizes',
            style: Theme.of(context).appBarTheme.titleTextStyle ??
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        if (_courtSizes.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _courtSizes.keys.map((size) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSize = size;
                      _numberOfFields = _courtSizes[size];
                    });
                    _fetchReservations();
                  },
                  child: Card(
                    elevation: 4,
                    color: _selectedSize == size ? ehjezGreen : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Text(
                        size,
                        style: TextStyle(
                          color: _selectedSize == size
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ] else
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('No sizes available for this court'),
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
              _selectedSlotTime = null; // Clear selected slot when day changes
            });
            // Call parent's onSelectionReset if needed
            // (if parent passes this callback; not shown in your current code)
            // if (widget.onSelectionReset != null) {
            //   widget.onSelectionReset!();
            // }
          },
          eventLoader: (day) =>
              _reservations[DateTime(day.year, day.month, day.day)] ?? [],
          calendarStyle: const CalendarStyle(
            markersAlignment: Alignment.bottomRight,
            selectedDecoration:
                BoxDecoration(color: Color(0xFF068631), shape: BoxShape.circle),
          ),
          availableCalendarFormats: const {CalendarFormat.month: 'Month'},
          calendarFormat: CalendarFormat.month,
          onFormatChanged: null,
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Duration',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Center(
                child: ToggleButtons(
                  isSelected: [_selectedDuration == 1, _selectedDuration == 2],
                  onPressed: (index) {
                    setState(() {
                      _selectedDuration = index + 1;
                      _selectedSlotTime =
                          null; // Clear selected slot when duration changes
                    });
                    // Optionally, notify parent reset via onSelectionReset if provided.
                    // if (widget.onSelectionReset != null) {
                    //   widget.onSelectionReset!();
                    // }
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
        if (_selectedDay != null && _selectedSize != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Available Times for ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year} ($_selectedSize)',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          ..._getAvailableSlots(_selectedDay!).map((slot) {
            final time = slot['time'] as DateTime;
            final isAvailable = slot['isAvailable'] as bool;
            final endTime = time.add(Duration(hours: _selectedDuration));
            final isSelected = _selectedSlotTime == time;
            return GestureDetector(
              onTap: () {
                if (isAvailable) {
                  setState(() {
                    _selectedSlotTime = time;
                  });
                  // Updated callback: notify parent with both time and duration.
                  if (widget.onTimeSlotSelected != null) {
                    widget.onTimeSlotSelected!(time, _selectedDuration);
                  }
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.green[300]
                      : isAvailable
                          ? const Color(0xFFC8E6C9)
                          : Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(color: Colors.green, width: 2)
                      : Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_formatHour(time)} - ${_formatHour(endTime)}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      isAvailable ? 'Available' : 'Reserved',
                      style: TextStyle(
                        color:
                            isAvailable ? Colors.green[800] : Colors.red[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ] else
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Select a day and size to view available slots'),
          ),
      ],
    );
  }
}
