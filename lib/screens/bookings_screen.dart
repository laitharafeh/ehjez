import 'package:ehjez/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final supabase = Supabase.instance.client;
  late final String _userId;
  late Future<List<Map<String, dynamic>>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    final user = supabase.auth.currentUser;
    _userId = user?.id ?? '';
    _bookingsFuture = _fetchBookings();
  }

  Future<List<Map<String, dynamic>>> _fetchBookings() async {
    if (_userId.isEmpty) return [];

    final response = await supabase
        .from('reservations')
        .select('id, date, start_time, duration, courts(name, category)')
        .eq('user_id', _userId)
        .order('date', ascending: false);

    final data = response as List<dynamic>;
    return data.cast<Map<String, dynamic>>().map((booking) {
      final date = booking['date'] as String;
      final startTime = booking['start_time'] as String;
      final startDateTime = _parseDateTime(date, startTime);
      return {...booking, 'startDateTime': startDateTime};
    }).toList();
  }

  DateTime _parseDateTime(String date, String time) {
    final dateParts = date.split('-');
    final timeParts = time.split(':');
    return DateTime(
      int.parse(dateParts[0]), // Year
      int.parse(dateParts[1]), // Month
      int.parse(dateParts[2]), // Day
      int.parse(timeParts[0]), // Hour
      int.parse(timeParts[1]), // Minute
    );
  }

  Future<void> _deleteBooking(int bookingId) async {
    try {
      await supabase.from('reservations').delete().eq('id', bookingId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking deleted successfully')),
      );
      setState(() {
        _bookingsFuture = _fetchBookings();
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting booking: $error')),
      );
    }
  }

  Widget _buildBookingTile(Map<String, dynamic> booking, bool isCurrent) {
    final court = booking['courts'] as Map<String, dynamic>?;
    final courtName = court?['name'] ?? 'Unknown Court';
    final category = (court?['category'] as String?)?.toLowerCase() ?? '';
    final dateStr = booking['date'] as String;
    final startTime = booking['start_time'] as String;
    final duration = booking['duration'].toString();

    IconData getIcon() {
      switch (category) {
        case 'padel':
          return Icons.sports_tennis;
        case 'soccer':
        case 'football':
          return Icons.sports_soccer;
        case 'volleyball':
          return Icons.sports_volleyball;
        case 'basketball':
          return Icons.sports_basketball;
        case 'badminton':
          return Icons.sports_tennis;
        default:
          return Icons.sports;
      }
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tileColor: Theme.of(context).cardColor,
      leading: Icon(getIcon(), size: 32),
      title: Text(
        courtName,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      subtitle:
          Text('Date: $dateStr\nStart: $startTime, Duration: $duration hours'),
      trailing: isCurrent
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: () {
                final bookingId = booking['id'] as int;
                _deleteBooking(bookingId);
              },
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final bookings = snapshot.data ?? [];
          if (bookings.isEmpty) {
            return const Center(child: Text('No bookings found.'));
          }

          final now = DateTime.now();
          final currentBookings = bookings
              .where((b) => b['startDateTime'].isAfter(now))
              .toList()
            ..sort((a, b) => a['startDateTime'].compareTo(b['startDateTime']));
          final previousBookings = bookings
              .where((b) => !b['startDateTime'].isAfter(now))
              .toList()
            ..sort((a, b) => b['startDateTime'].compareTo(a['startDateTime']));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Current Bookings Section
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Current Bookings',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              if (currentBookings.isEmpty)
                const ListTile(title: Text('No bookings'))
              else
                ...currentBookings.expand((booking) => [
                      _buildBookingTile(booking, true),
                      const Divider(),
                    ]),
              // Previous Bookings Section
              const Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Previous Bookings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              if (previousBookings.isEmpty)
                const ListTile(title: Text('No previous bookings'))
              else
                ...previousBookings.expand((booking) => [
                      _buildBookingTile(booking, false),
                      const Divider(),
                    ]),
            ],
          );
        },
      ),
    );
  }
}
