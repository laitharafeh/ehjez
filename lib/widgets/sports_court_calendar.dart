import 'package:ehjez/constants.dart';
import 'package:ehjez/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

class SportsCourtCalendar extends ConsumerStatefulWidget {
  final String courtId;
  final String name;
  final void Function(DateTime, int, String)? onTimeSlotSelected;
  final VoidCallback? onSelectionReset;

  const SportsCourtCalendar({
    required this.name,
    required this.courtId,
    this.onTimeSlotSelected,
    this.onSelectionReset,
    super.key,
  });

  @override
  ConsumerState<SportsCourtCalendar> createState() =>
      _SportsCourtCalendarState();
}

class _SportsCourtCalendarState extends ConsumerState<SportsCourtCalendar> {
  DateTime? _selectedSlotTime;
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  final Map<DateTime, List<Map<String, dynamic>>> _reservations = {};
  bool _isLoading = false;
  int _selectedDuration = 2;
  DateTime? _courtStartTime;
  DateTime? _courtEndTime;
  bool _isEndTimeSpecial = false;
  final Map<String, int> _courtSizes = {};
  String? _selectedSize;
  int? _numberOfFields;
  // Working days — populated from DB. Defaults to all days until loaded.
  List<int> _workingDays = [1, 2, 3, 4, 5, 6, 7];
  // Specific vacation/closed dates set by the admin
  Set<DateTime> _vacationDays = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _fetchCourtData();
  }

  DateTime _normaliseDate(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isVacationDay(DateTime day) =>
      _vacationDays.contains(_normaliseDate(day));

  Widget _buildClosedDayCell(DateTime day, {required bool isOutside}) {
    return Center(
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          shape: BoxShape.circle,
          border: Border.all(
            color: isOutside ? Colors.red.shade100 : Colors.red.shade200,
            width: 1.2,
          ),
        ),
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: isOutside ? Colors.red.shade200 : Colors.red.shade300,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// A day is disabled if it's a non-working weekday OR a specific vacation date.
  bool _isDayEnabled(DateTime day) {
    if (!_workingDays.contains(day.weekday)) return false;
    if (_isVacationDay(day)) return false;
    return true;
  }

  Future<void> _fetchCourtData() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(courtRepositoryProvider);

      // Fetch court data, sizes, and vacation days in parallel
      final results = await Future.wait([
        repo.fetchCourtById(widget.courtId),
        repo.fetchCourtSizePrices(widget.courtId),
        repo.fetchVacationDays(widget.courtId),
      ]);

      final court = results[0] as dynamic;
      final sizes = results[1] as dynamic;
      final vacationDays = results[2] as Set<DateTime>;

      // Process timings
      final startTimeStr = court.startTime as String?;
      final endTimeStr = court.endTime as String?;
      if (startTimeStr != null && endTimeStr != null) {
        final now = DateTime.now();
        _isEndTimeSpecial = endTimeStr == '23:59:59';
        final startHour = int.parse(startTimeStr.split(':')[0]);
        final endHour = int.parse(endTimeStr.split(':')[0]);
        _courtStartTime = DateTime(now.year, now.month, now.day, startHour);
        _courtEndTime = endHour >= startHour
            ? DateTime(now.year, now.month, now.day, endHour)
            : DateTime(now.year, now.month, now.day + 1, endHour);
      }

      // Working days — use court value, fall back to all days
      _workingDays = court.workingDays.isNotEmpty
          ? court.workingDays
          : [1, 2, 3, 4, 5, 6, 7];

      // Vacation days
      _vacationDays = vacationDays;

      // If today is disabled (closed weekday or vacation), advance to next open day
      if (!_isDayEnabled(_selectedDay ?? DateTime.now())) {
        DateTime candidate = _selectedDay ?? DateTime.now();
        for (int i = 1; i <= 365; i++) {
          candidate = candidate.add(const Duration(days: 1));
          if (_isDayEnabled(candidate)) {
            _selectedDay = candidate;
            _focusedDay = candidate;
            break;
          }
        }
      }

      // Process sizes
      _courtSizes.clear();
      for (final sp in sizes) {
        if (sp.size.isNotEmpty && sp.numberOfFields > 0) {
          _courtSizes[sp.size] = sp.numberOfFields;
        }
      }

      if (_courtSizes.isNotEmpty) {
        _selectedSize = _courtSizes.keys.first;
        _numberOfFields = _courtSizes[_selectedSize];
      }

      await _fetchReservations();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading court data: $e')),
        );
        _courtStartTime = DateTime.now().copyWith(hour: 8, minute: 0);
        _courtEndTime = DateTime.now()
            .copyWith(hour: 2, minute: 0)
            .add(const Duration(days: 1));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchReservations() async {
    if (_selectedSize == null) return;
    setState(() => _isLoading = true);
    try {
      final raw = await ref
          .read(reservationRepositoryProvider)
          .fetchReservationsForCourt(
            courtId: widget.courtId,
            size: _selectedSize!,
            fromDate: DateTime.now().toIso8601String().split('T')[0],
          );

      _reservations.clear();
      for (final r in raw) {
        final date = DateTime.parse(r['date']);
        final parts = (r['start_time'] as String).split(':');
        final startTime = DateTime(date.year, date.month, date.day,
            int.parse(parts[0]), int.parse(parts[1]));
        final key = DateTime(date.year, date.month, date.day);
        _reservations[key] ??= [];
        _reservations[key]!.add({
          'start_time': startTime,
          'duration': r['duration'],
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

  List<Map<String, dynamic>> _getAvailableSlots(DateTime day) {
    if (_courtStartTime == null ||
        _courtEndTime == null ||
        _selectedSize == null ||
        _numberOfFields == null) return [];

    final now = DateTime.now();
    final isToday =
        day.year == now.year && day.month == now.month && day.day == now.day;

    final dayStart = DateTime(day.year, day.month, day.day,
        _courtStartTime!.hour, _courtStartTime!.minute);

    final dayEnd = _isEndTimeSpecial
        ? DateTime(day.year, day.month, day.day + 1, 0, 0)
        : (_courtEndTime!.isAfter(_courtStartTime!)
            ? DateTime(day.year, day.month, day.day, _courtEndTime!.hour,
                _courtEndTime!.minute)
            : DateTime(day.year, day.month, day.day + 1, _courtEndTime!.hour,
                _courtEndTime!.minute));

    final reservedTimes =
        _reservations[DateTime(day.year, day.month, day.day)] ?? [];

    // O(n) booking-count map
    final Map<int, int> bookingsPerHour = {};
    for (final r in reservedTimes) {
      final rStart = r['start_time'] as DateTime;
      final rDuration = r['duration'] as int;
      for (int h = 0; h < rDuration; h++) {
        final hour = (rStart.hour + h) % 24;
        bookingsPerHour[hour] = (bookingsPerHour[hour] ?? 0) + 1;
      }
    }

    final slots = <Map<String, dynamic>>[];
    var currentTime = dayStart;

    while (true) {
      if (isToday && currentTime.isBefore(now)) {
        currentTime = currentTime.add(const Duration(hours: 1));
        if (currentTime.isAfter(dayEnd)) break;
        continue;
      }
      if (currentTime.isAtSameMomentAs(dayEnd) || currentTime.isAfter(dayEnd)) {
        break;
      }

      final slotEnd = currentTime.add(Duration(hours: _selectedDuration));
      if (_selectedDuration == 2 && slotEnd.isAfter(dayEnd)) break;

      bool isAvailable = true;
      for (int h = 0; h < _selectedDuration; h++) {
        final hour = (currentTime.hour + h) % 24;
        if ((bookingsPerHour[hour] ?? 0) >= _numberOfFields!) {
          isAvailable = false;
          break;
        }
      }

      slots.add({'time': currentTime, 'isAvailable': isAvailable});
      currentTime = currentTime.add(const Duration(hours: 1));
      if (currentTime.isAfter(dayEnd)) break;
    }

    return slots;
  }

  String _formatHour(DateTime time) {
    int hour = time.hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0)
      hour = 12;
    else if (hour > 12) hour -= 12;
    return '$hour:00 $period';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final selectedDayIsVacation = _selectedDay != null &&
        _vacationDays.contains(_normaliseDate(_selectedDay!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Size selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Sizes',
              style: Theme.of(context).appBarTheme.titleTextStyle ??
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        if (_courtSizes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _courtSizes.keys.map((size) {
                final isSelected = _selectedSize == size;
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
                    color: isSelected ? ehjezGreen : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Text(size,
                          style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black)),
                    ),
                  ),
                );
              }).toList(),
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('No sizes available for this court'),
          ),

        // Calendar — vacation days and non-working days greyed out
        TableCalendar(
          availableGestures: AvailableGestures.horizontalSwipe,
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(const Duration(days: 30)),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          // Block non-working weekdays AND vacation days
          enabledDayPredicate: _isDayEnabled,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              _selectedSlotTime = null;
            });
            widget.onSelectionReset?.call();
          },
          eventLoader: (day) =>
              _reservations[DateTime(day.year, day.month, day.day)] ?? [],
          calendarStyle: CalendarStyle(
            markersMaxCount: 0,
            selectedDecoration: const BoxDecoration(
                color: Color(0xFF068631), shape: BoxShape.circle),
            // Both closed weekdays and vacation days use the same muted style
            disabledTextStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          calendarBuilders: CalendarBuilders(
            disabledBuilder: (context, day, focusedDay) {
              if (_isVacationDay(day)) {
                return _buildClosedDayCell(day, isOutside: false);
              }
              return null;
            },
            outsideBuilder: (context, day, focusedDay) {
              if (_isVacationDay(day)) {
                return _buildClosedDayCell(day, isOutside: true);
              }
              return null;
            },
          ),
          availableCalendarFormats: const {CalendarFormat.month: 'Month'},
          calendarFormat: CalendarFormat.month,
          onFormatChanged: null,
        ),

        // Vacation day notice (shouldn't normally show since day is disabled,
        // but guards against edge cases like same-day vacation set after load)
        if (selectedDayIsVacation)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.beach_access,
                    color: Colors.orange.shade600, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This facility is closed on this date.',
                    style:
                        TextStyle(color: Colors.orange.shade800, fontSize: 13),
                  ),
                ),
              ],
            ),
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
                  onPressed: (i) {
                    setState(() {
                      _selectedDuration = i + 1;
                      _selectedSlotTime = null;
                    });
                    widget.onSelectionReset?.call();
                  },
                  borderRadius: BorderRadius.circular(8),
                  selectedColor: Colors.white,
                  color: Colors.black,
                  fillColor: ehjezGreen,
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

        // Time slots — hidden entirely if the day is a vacation day
        if (_selectedDay != null &&
            _selectedSize != null &&
            !selectedDayIsVacation) ...[
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
                if (!isAvailable) return;
                setState(() => _selectedSlotTime = time);
                widget.onTimeSlotSelected
                    ?.call(time, _selectedDuration, _selectedSize!);
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
                    Text(
                      '${_formatHour(time)} - ${_formatHour(endTime)}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
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
        ] else if (_selectedDay != null &&
            _selectedSize != null &&
            selectedDayIsVacation)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('No bookings available on this date.'),
          )
        else
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Select a day and size to view available slots'),
          ),
      ],
    );
  }
}
