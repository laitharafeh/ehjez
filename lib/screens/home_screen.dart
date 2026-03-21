import 'package:ehjez/models/court.dart';
import 'package:ehjez/providers/providers.dart';
import 'package:ehjez/screens/court_details_screen.dart';
import 'package:ehjez/widgets/coming_soon_button.dart';
import 'package:ehjez/widgets/custom_app_bar.dart';
import 'package:ehjez/widgets/featured_court_list_tile.dart';
import 'package:ehjez/widgets/home_text.dart';
import 'package:ehjez/widgets/size_court_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  final void Function(String category) onGoToSearch;

  const HomeScreen({super.key, required this.onGoToSearch});

  void _goToDetails(BuildContext context, Court court) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CourtDetailsScreen(court: court)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured = ref.watch(featuredCourtsProvider);
    final football = ref.watch(footballCourtsProvider);
    final padel = ref.watch(padelCourtsProvider);

    // Time-based greeting — computed once at build time
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting + Search bar ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Find a court',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Tapping navigates to the Search tab — no keyboard opens here.
                  // AbsorbPointer blocks actual text input so it stays a nav shortcut.
                  GestureDetector(
                    onTap: () => onGoToSearch('All'),
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search courts, locations...',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 15,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[500],
                            size: 22,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Category circles ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: Text(
                'Categories',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            _CategoryStrip(onGoToSearch: onGoToSearch),

            const Divider(color: Colors.grey, thickness: 0.5, height: 24),

            // ── Featured ──────────────────────────────────────────────────
            const HomeText(text: 'Featured', icon: Icons.star_rounded),
            SizedBox(
              height: 174,
              child: featured.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) =>
                    const Center(child: Text('Could not load courts')),
                data: (courts) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: courts.length,
                  itemBuilder: (context, i) {
                    final court = courts[i];
                    return GestureDetector(
                      onTap: () => _goToDetails(context, court),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: FeaturedCourtListTile(
                          name: court.name,
                          category: court.category,
                          location: court.location,
                          imageUrl: court.imageUrl,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ── Football ──────────────────────────────────────────────────
            const HomeText(text: 'Football', icon: Icons.sports_soccer),
            SizedBox(
              height: 106,
              child: football.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) =>
                    const Center(child: Text('Could not load courts')),
                data: (courts) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: courts.length,
                  itemBuilder: (context, i) {
                    final court = courts[i];
                    return GestureDetector(
                      onTap: () => _goToDetails(context, court),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: SizeCourtListTile(
                          name: court.name,
                          category: court.category,
                          location: court.location,
                          imageUrl: court.imageUrl,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ── Padel ─────────────────────────────────────────────────────
            const HomeText(text: 'Padel', icon: Icons.sports_tennis),
            SizedBox(
              height: 106,
              child: padel.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) =>
                    const Center(child: Text('Could not load courts')),
                data: (courts) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: courts.length,
                  itemBuilder: (context, i) {
                    final court = courts[i];
                    return GestureDetector(
                      onTap: () => _goToDetails(context, court),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: SizeCourtListTile(
                          name: court.name,
                          category: court.category,
                          location: court.location,
                          imageUrl: court.imageUrl,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Tournaments ───────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Tournaments',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
            ),
            const ComingSoonButton(imagePath: 'assets/trophy.png'),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

// ── Category strip ────────────────────────────────────────────────────────────
//
// Replaces HomeCategoryButtons. Each sport gets a circle with its own
// accent color — no more square containers with photo-realistic emoji.
// Self-contained here; no need for a separate file.

class _CategoryStrip extends StatelessWidget {
  final void Function(String category) onGoToSearch;

  const _CategoryStrip({required this.onGoToSearch});

  static const _categories = [
    _CategoryItem(
      label: 'Football',
      assetPath: 'assets/football_cat.png',
      color: Color(0xFFE8F5E9), // soft green
    ),
    _CategoryItem(
      label: 'Padel',
      assetPath: 'assets/padel_cut.PNG',
      color: Color(0xFFE3F2FD), // soft blue
    ),
    _CategoryItem(
      label: 'Tennis',
      assetPath: 'assets/tennis_ball.png',
      color: Color(0xFFFFF8E1), // soft amber
    ),
    _CategoryItem(
      label: 'Badminton',
      assetPath: 'assets/badminton_ball.png',
      color: Color(0xFFFCE4EC), // soft pink
    ),
    _CategoryItem(
      label: 'Basketball',
      assetPath: 'assets/basketball.png',
      color: Color(0xFFFBE9E7), // soft coral
    ),
    _CategoryItem(
      label: 'Volleyball',
      assetPath: 'assets/volleyball.png',
      color: Color(0xFFEDE7F6), // soft purple
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, i) {
          final cat = _categories[i];
          return GestureDetector(
            onTap: () => onGoToSearch(cat.label),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: cat.color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      cat.assetPath,
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  cat.label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CategoryItem {
  final String label;
  final String assetPath;
  final Color color;

  const _CategoryItem({
    required this.label,
    required this.assetPath,
    required this.color,
  });
}
