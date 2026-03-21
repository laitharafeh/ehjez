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
//
// StreamProvider listens to Supabase's auth state stream.
// Any time the user logs in, logs out, or taps "Later", this emits a new
// value — and every provider watching it (userReservationsProvider etc.)
// automatically re-evaluates. This is why bookings disappear on logout.

final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

/// Derives the current user ID from the live auth stream.
/// Returns null when logged out — StreamProvider ensures this is reactive.
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenData((state) => state.session?.user.id).value;
});

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

  // ── Per-category cache ────────────────────────────────────────────────────
  // Keyed by category name (e.g. 'All', 'Football', 'Padel').
  // Only populated when there is no active text search query — search results
  // are dynamic so we never cache those.
  final Map<String, List<Court>> _courtCache = {};
  final Map<String, int> _pageCache = {};
  final Map<String, bool> _hasMoreCache = {};

  bool get _isTextSearch => state.query.isNotEmpty;

  @override
  SearchState build() {
    Future.microtask(() => fetchCourts());
    return const SearchState();
  }

  Future<void> fetchCourts({bool reset = false}) async {
    if (state.isLoading && !reset) return;

    final category = state.category;

    // ── Cache hit: restore instantly, no network call ─────────────────────
    // Only applies when there is no active text search.
    if (reset && !_isTextSearch && _courtCache.containsKey(category)) {
      state = state.copyWith(
        courts: _courtCache[category]!,
        page: _pageCache[category]!,
        hasMore: _hasMoreCache[category]!,
        isLoading: false,
      );
      return;
    }

    // ── Cache miss or text search: fetch from API ─────────────────────────
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

      final allCourts = [...existingCourts, ...newCourts];
      final nextPage = pageToFetch + 1;
      final hasMore = newCourts.length >= _pageSize;

      state = state.copyWith(
        courts: allCourts,
        isLoading: false,
        hasMore: hasMore,
        page: nextPage,
      );

      // Store in cache — but only for pure category browsing, not text search.
      // This means switching Football → Padel → Football costs zero extra calls.
      if (!_isTextSearch) {
        _courtCache[category] = allCourts;
        _pageCache[category] = nextPage;
        _hasMoreCache[category] = hasMore;
      }
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

  /// Call this if you ever need to force a fresh fetch —
  /// e.g. after a new court is added by admin.
  void invalidateCache() {
    _courtCache.clear();
    _pageCache.clear();
    _hasMoreCache.clear();
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
