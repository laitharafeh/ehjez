import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/court.dart';
import '../models/court_size_price.dart';
import '../models/reservation.dart';
import '../repositories/court_repository.dart';
import '../repositories/reservation_repository.dart';

// ─── Infrastructure ──────────────────────────────────────────────────────────

final supabaseProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

final courtRepositoryProvider = Provider<CourtRepository>(
  (ref) => CourtRepository(ref.watch(supabaseProvider)),
);

final reservationRepositoryProvider = Provider<ReservationRepository>(
  (ref) => ReservationRepository(ref.watch(supabaseProvider)),
);

// ─── Auth ─────────────────────────────────────────────────────────────────────

final currentUserIdProvider = Provider<String?>(
  (_) => Supabase.instance.client.auth.currentUser?.id,
);

// ─── Courts (cached) ──────────────────────────────────────────────────────────
//
// These are FutureProviders — Riverpod caches the result automatically.
// The data is only re-fetched when the provider is invalidated.

final featuredCourtsProvider = FutureProvider<List<Court>>(
  (ref) => ref.watch(courtRepositoryProvider).fetchFeaturedCourts(),
);

final footballCourtsProvider = FutureProvider<List<Court>>(
  (ref) =>
      ref.watch(courtRepositoryProvider).fetchCourtsByCategory('Football'),
);

final padelCourtsProvider = FutureProvider<List<Court>>(
  (ref) => ref.watch(courtRepositoryProvider).fetchCourtsByCategory('Padel'),
);

/// Per-court sizes and prices — keyed by courtId. Cached per court.
final courtSizePricesProvider =
    FutureProvider.family<List<CourtSizePrice>, String>(
  (ref, courtId) =>
      ref.watch(courtRepositoryProvider).fetchCourtSizePrices(courtId),
);

// ─── Search ───────────────────────────────────────────────────────────────────

class SearchState {
  final String category;
  final String query;
  final List<Court> courts;
  final bool isLoading;
  final bool hasMore;
  final int page;

  const SearchState({
    this.category = 'All',
    this.query = '',
    this.courts = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.page = 0,
  });

  SearchState copyWith({
    String? category,
    String? query,
    List<Court>? courts,
    bool? isLoading,
    bool? hasMore,
    int? page,
  }) {
    return SearchState(
      category: category ?? this.category,
      query: query ?? this.query,
      courts: courts ?? this.courts,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  static const _pageSize = 10;

  @override
  SearchState build() {
    Future.microtask(() => fetchCourts());
    return const SearchState();
  }

  Future<void> fetchCourts({bool reset = false}) async {
    if (state.isLoading && !reset) return;

    final pageToFetch = reset ? 0 : state.page;
    final existingCourts = reset ? <Court>[] : state.courts;

    state = state.copyWith(
      courts: existingCourts,
      page: pageToFetch,
      hasMore: reset ? true : state.hasMore,
      isLoading: true,
    );

    try {
      final newCourts = await ref.read(courtRepositoryProvider).searchCourts(
            category: state.category,
            query: state.query,
            page: pageToFetch,
            pageSize: _pageSize,
          );

      state = state.copyWith(
        courts: [...existingCourts, ...newCourts],
        isLoading: false,
        hasMore: newCourts.length >= _pageSize,
        page: pageToFetch + 1,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Called when user taps a category — either from search bar or home screen.
  void setCategory(String category) {
    if (state.category == category) return;
    state = state.copyWith(category: category);
    fetchCourts(reset: true);
  }

  void setQuery(String query) {
    state = state.copyWith(query: query);
    fetchCourts(reset: true);
  }

  void loadMore() {
    if (!state.isLoading && state.hasMore) fetchCourts();
  }
}

final searchProvider =
    NotifierProvider<SearchNotifier, SearchState>(SearchNotifier.new);

// ─── Reservations ─────────────────────────────────────────────────────────────

final userReservationsProvider = FutureProvider<List<Reservation>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  return ref.watch(reservationRepositoryProvider).fetchUserReservations(userId);
});
