import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reservation.dart';

class ReservationRepository {
  final SupabaseClient _supabase;

  ReservationRepository(this._supabase);

  Future<List<Reservation>> fetchUserReservations(String userId) async {
    final response = await _supabase
        .from('reservations')
        .select(
            'id, user_id, court_id, date, start_time, duration, size, price, commission, courts(name, category)')
        .eq('user_id', userId)
        .order('date', ascending: false);
    return (response as List).map((m) => Reservation.fromMap(m)).toList();
  }

  Future<bool> hasActiveBooking(String userId) async {
    final reservations = await fetchUserReservations(userId);
    return reservations.any((r) => r.isCurrent);
  }

  Future<List<Map<String, dynamic>>> fetchReservationsForCourt({
    required String courtId,
    required String size,
    required String fromDate,
  }) async {
    final response = await _supabase
        .from('reservations')
        .select('start_time, duration, user_id, size, date')
        .eq('court_id', courtId)
        .eq('size', size)
        .gte('date', fromDate)
        .order('start_time', ascending: true);
    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<void> createReservation({
    required String userId,
    required String phone,
    required String courtId,
    required String date,
    required String startTime,
    required int duration,
    required String size,
    required int price,
    int? promoCodeId,
  }) async {
    await _supabase.from('reservations').insert({
      'user_id': userId,
      'phone': phone,
      'court_id': courtId,
      'date': date,
      'start_time': startTime,
      'duration': duration,
      'size': size,
      'price': price,
      if (promoCodeId != null) 'promo_code_id': promoCodeId,
      // commission is calculated server-side via DB trigger
    });
  }

  /// Validates a promo code for a given court.
  /// Returns the promo row if valid, null otherwise.
  Future<Map<String, dynamic>?> validatePromoCode(
      String courtId, String code) async {
    final response = await _supabase
        .from('promo_codes')
        .select()
        .eq('court_id', courtId)
        .eq('code', code.toUpperCase().trim())
        .eq('is_active', true)
        .maybeSingle();

    if (response == null) return null;

    final validFrom = response['valid_from'] as String?;
    if (validFrom != null &&
        DateTime.now().isBefore(DateTime.parse(validFrom))) return null;

    final validUntil = response['valid_until'] as String?;
    if (validUntil != null &&
        DateTime.now().isAfter(DateTime.parse(validUntil))) return null;

    final maxUses = response['max_uses'] as int?;
    final usesCount = response['uses_count'] as int? ?? 0;
    if (maxUses != null && usesCount >= maxUses) return null;

    return response;
  }

  int applyPromoDiscount(int price, Map<String, dynamic> promo) {
    final type = promo['type'] as String;
    final value = (promo['value'] as num).toDouble();
    if (type == 'percent') {
      return (price * (1 - value / 100)).round();
    } else {
      return (price - value).round().clamp(0, price);
    }
  }

  Future<void> deleteReservation(int reservationId, String userId) async {
    await _supabase
        .from('reservations')
        .delete()
        .eq('id', reservationId)
        .eq('user_id', userId);
  }

  /// Checks whether a given time slot is available for booking.
  /// Returns true if there is room for at least one more booking.
  Future<bool> checkSlotAvailability({
    required String courtId,
    required DateTime selectedTime,
    required int duration,
    required String size,
  }) async {
    try {
      final date = selectedTime.toIso8601String().split('T')[0];

      final sizeResponse = await _supabase
          .from('courts_size_price')
          .select('number_of_fields')
          .eq('court_id', courtId)
          .eq('size', size)
          .maybeSingle();

      if (sizeResponse == null) return false;
      final numberOfFields = sizeResponse['number_of_fields'] as int?;
      if (numberOfFields == null || numberOfFields <= 0) return false;

      final rawReservations = await _supabase
          .from('reservations')
          .select('start_time, duration')
          .eq('court_id', courtId)
          .eq('date', date)
          .eq('size', size);

      final reservations = (rawReservations as List).map((r) {
        final parts = (r['start_time'] as String).split(':');
        final h = int.tryParse(parts.isNotEmpty ? parts[0] : '0') ?? 0;
        final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
        return {
          'start_time': DateTime(
              selectedTime.year, selectedTime.month, selectedTime.day, h, m),
          'duration': r['duration'],
        };
      }).toList();

      final slotStart = selectedTime;
      final slotEnd = slotStart.add(Duration(hours: duration));
      final maxConcurrency =
          _getMaxConcurrency(slotStart, slotEnd, reservations);

      return maxConcurrency < numberOfFields;
    } catch (e) {
      debugPrint('Error checking slot availability: $e');
      return false;
    }
  }

  /// Shared concurrency calculation — used by both the availability check
  /// and the calendar widget. No more duplicate code.
  int getMaxConcurrency(
    DateTime slotStart,
    DateTime slotEnd,
    List<Map<String, dynamic>> reservations,
  ) =>
      _getMaxConcurrency(slotStart, slotEnd, reservations);

  int _getMaxConcurrency(
    DateTime slotStart,
    DateTime slotEnd,
    List<Map<String, dynamic>> reservations,
  ) {
    final overlapping = reservations.where((r) {
      final rStart = r['start_time'] as DateTime;
      final rEnd = rStart.add(Duration(hours: r['duration'] as int));
      return rStart.isBefore(slotEnd) && rEnd.isAfter(slotStart);
    }).toList();

    final events = <Map<String, dynamic>>[];
    for (final r in overlapping) {
      final rStart = r['start_time'] as DateTime;
      final rEnd = rStart.add(Duration(hours: r['duration'] as int));
      events.add({
        'time': rStart.isAfter(slotStart) ? rStart : slotStart,
        'type': 'start',
      });
      events.add({
        'time': rEnd.isBefore(slotEnd) ? rEnd : slotEnd,
        'type': 'end',
      });
    }

    events.sort((a, b) {
      final cmp = (a['time'] as DateTime).compareTo(b['time'] as DateTime);
      if (cmp == 0) {
        if (a['type'] == 'end' && b['type'] == 'start') return -1;
        if (a['type'] == 'start' && b['type'] == 'end') return 1;
      }
      return cmp;
    });

    int counter = 0, maxCounter = 0;
    for (final event in events) {
      if (event['type'] == 'start') {
        counter++;
        if (counter > maxCounter) maxCounter = counter;
      } else {
        counter--;
      }
    }
    return maxCounter;
  }
}
