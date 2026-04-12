import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tournament.dart';

class TournamentRepository {
  final SupabaseClient _supabase;
  TournamentRepository(this._supabase);

  Future<List<Tournament>> fetchActiveTournaments() async {
    final response = await _supabase
        .from('tournaments')
        .select('*, courts(name, category), tournament_registrations(count)')
        .eq('is_active', true)
        .order('date', ascending: true);
    return (response as List).map((m) => Tournament.fromMap(m)).toList();
  }

  Future<bool> isRegistered(String tournamentId, String phone) async {
    final response = await _supabase
        .from('tournament_registrations')
        .select()
        .eq('tournament_id', tournamentId)
        .eq('phone', phone)
        .maybeSingle();
    return response != null;
  }

  Future<void> register({
    required String tournamentId,
    required String name,
    required String phone,
  }) async {
    await _supabase.from('tournament_registrations').insert({
      'tournament_id': tournamentId,
      'name': name,
      'phone': phone,
    });
  }
}
