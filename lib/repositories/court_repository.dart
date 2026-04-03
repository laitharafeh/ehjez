import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/court.dart';
import '../models/court_size_price.dart';

class CourtRepository {
  final SupabaseClient _supabase;

  CourtRepository(this._supabase);

  Future<List<Court>> fetchFeaturedCourts({int limit = 10}) async {
    final response = await _supabase
        .from('courts')
        .select()
        .eq('featured', true)
        .limit(limit);
    return (response as List).map((m) => Court.fromMap(m)).toList();
  }

  Future<List<Court>> fetchCourtsByCategory(String category,
      {int limit = 10}) async {
    final response = await _supabase
        .from('courts')
        .select()
        .eq('category', category)
        .limit(limit);
    return (response as List).map((m) => Court.fromMap(m)).toList();
  }

  Future<List<Court>> searchCourts({
    String category = 'All',
    String query = '',
    int page = 0,
    int pageSize = 10,
  }) async {
    var q = _supabase.from('courts').select();
    if (category != 'All') q = q.eq('category', category);
    if (query.isNotEmpty) q = q.ilike('name', '%$query%');
    final response =
        await q.range(page * pageSize, (page + 1) * pageSize - 1);
    return (response as List).map((m) => Court.fromMap(m)).toList();
  }

  Future<List<CourtSizePrice>> fetchCourtSizePrices(String courtId) async {
    final response = await _supabase
        .from('courts_size_price')
        .select()
        .eq('court_id', courtId);
    return (response as List).map((m) => CourtSizePrice.fromMap(m)).toList();
  }

  Future<CourtSizePrice> fetchSizePriceForSize(
      String courtId, String size) async {
    final response = await _supabase
        .from('courts_size_price')
        .select()
        .eq('court_id', courtId)
        .eq('size', size)
        .single();
    return CourtSizePrice.fromMap(response);
  }

  Future<Court> fetchCourtById(String courtId) async {
    final response = await _supabase
        .from('courts')
        .select()
        .eq('id', courtId)
        .single();
    return Court.fromMap(response);
  }

  /// Returns a set of dates (normalised to midnight) that are vacation/closed
  /// days for the given court, from today onward.
  Future<Set<DateTime>> fetchVacationDays(String courtId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final response = await _supabase
        .from('court_vacation_days')
        .select('vacation_date')
        .eq('court_id', courtId)
        .gte('vacation_date', today);

    return (response as List)
        .map((r) {
          final d = DateTime.parse(r['vacation_date'] as String);
          return DateTime(d.year, d.month, d.day);
        })
        .toSet();
  }
}
