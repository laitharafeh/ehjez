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
        .select('date, start_time, duration, courts(name, category)')
        .eq('user_id', _userId)
        .order('date', ascending: false);

    final data = response as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
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

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final court = booking['courts'] as Map<String, dynamic>?;
              final courtName = court?['name'] ?? 'Unknown Court';
              final category =
                  (court?['category'] as String?)?.toLowerCase() ?? '';
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
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: Theme.of(context).cardColor,
                leading: Icon(getIcon(), size: 32),
                title: Text(
                  courtName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                    'Date: $dateStr\nStart: $startTime, Duration: $duration hours'),
              );
            },
          );
        },
      ),
    );
  }
}
