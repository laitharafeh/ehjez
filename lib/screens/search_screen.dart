import 'dart:async';
import 'package:ehjez/models/court.dart';
import 'package:ehjez/providers/providers.dart';
import 'package:ehjez/screens/court_details_screen.dart';
import 'package:ehjez/widgets/category_button.dart';
import 'package:ehjez/widgets/court_list_tile.dart';
import 'package:ehjez/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchScreen extends ConsumerStatefulWidget {
  // No constructor arguments needed — category and query live in the provider.
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  final List<String> categories = [
    'All', 'Football', 'Padel', 'Basketball', 'Tennis', 'Badminton', 'Volleyball',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      ref.read(searchProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(searchProvider.notifier).setQuery(query.toLowerCase());
    });
  }

  void _onCategorySelected(String category) {
    ref.read(searchProvider.notifier).setCategory(category);
  }

  void _goToDetails(BuildContext context, Court court) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CourtDetailsScreen(court: court)),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    // Sync the text field if the category changed externally (e.g. home screen tap).
    // We only need to sync the search text — category is reflected in the buttons.

    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          CategoryButtons(
            categories: categories,
            selectedCategory: searchState.category,
            onCategorySelected: _onCategorySelected,
          ),
          const SizedBox(height: 3),
          Expanded(
            child: searchState.courts.isEmpty && !searchState.isLoading
                ? const Center(child: Text('No courts found'))
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: searchState.courts.length +
                        (searchState.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == searchState.courts.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final court = searchState.courts[index];
                      return GestureDetector(
                        onTap: () => _goToDetails(context, court),
                        child: CourtListTile(
                          name: court.name,
                          category: court.category,
                          location: court.location,
                          phone: court.phone,
                          size: '',
                          imageUrl: court.imageUrl,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
