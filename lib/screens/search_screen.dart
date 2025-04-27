import 'dart:async';
import 'package:ehjez/screens/court_details_screen.dart';
import 'package:ehjez/widgets/category_button.dart';
import 'package:ehjez/widgets/court_list_tile.dart';
import 'package:ehjez/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchScreen extends StatefulWidget {
  final String selectedCategory;

  const SearchScreen({super.key, required this.selectedCategory});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  final List<String> categories = [
    "All",
    "Football",
    "Padel",
    "Basketball",
    "Tennis",
    "Badminton",
    "Volleyball"
  ];

  late String _selectedCategory;
  String _searchQuery = "";
  final List<Map<String, dynamic>> _courts = []; // List to store courts
  bool _isLoading = false; // Loading state
  bool _hasMore = true; // Whether more data is available
  int _page = 0; // Current page
  final int _pageSize = 10; // Number of items per page

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;

    // Smooth initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCourts(); // Initial fetch after UI builds
    });

    // Scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading &&
          _hasMore) {
        _fetchCourts();
      }
    });
  }

  /// Fetches courts with pagination
  Future<void> _fetchCourts({bool reset = false}) async {
    if (_isLoading) return; // Prevent multiple fetches
    setState(() => _isLoading = true);

    if (reset) {
      _courts.clear(); // Clear list on reset
      _page = 0;
      _hasMore = true;
    }

    try {
      var query = supabase.from('courts').select();
      if (_selectedCategory != "All") {
        query = query.eq('category', _selectedCategory);
      }
      if (_searchQuery.isNotEmpty) {
        query = query.ilike('name', '%$_searchQuery%');
      }

      // Fetch a range of courts based on the current page
      final response =
          await query.range(_page * _pageSize, (_page + 1) * _pageSize - 1);

      setState(() {
        _courts.addAll(response); // Append new courts
        _page++; // Increment page
        if (response.length < _pageSize) {
          _hasMore = false; // No more data to fetch
        }
      });
    } catch (error) {
      debugPrint("Error fetching courts: $error");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Handles category selection
  void onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _fetchCourts(reset: true); // Reset and fetch
    });
  }

  /// Filters search results with debounce
  void _filterSearchResults(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query.toLowerCase();
        _fetchCourts(reset: true); // Reset and fetch
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterSearchResults,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                hintText: "Search...",
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
            selectedCategory: _selectedCategory,
            onCategorySelected: onCategorySelected,
          ),
          const SizedBox(height: 3),
          Expanded(
            child: _courts.isEmpty && !_isLoading
                ? const Center(child: Text("No courts found"))
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _courts.length +
                        (_hasMore ? 1 : 0), // Add 1 for loading indicator
                    itemBuilder: (context, index) {
                      if (index == _courts.length) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final court = _courts[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourtDetailsScreen(
                                id: court['id'],
                                name: court['name'] ?? "Unknown",
                                category: court['category'] ?? "N/A",
                                location: court['location'] ?? "Not specified",
                                phone: court['phone'] ?? "No contact",
                                size: court['size'] ?? "N/A",
                                price: court['price'] ?? "N/A",
                                price2: court['price2'] ?? 0,
                                imageUrl: court['image_url'] ?? "",
                                image2Url: court['image2_url'] ?? "",
                                image3Url: court['image3_url'] ?? "",
                              ),
                            ),
                          );
                        },
                        child: CourtListTile(
                          name: court['name'] ?? "Unknown",
                          category: court['category'] ?? "N/A",
                          location: court['location'] ?? "Not specified",
                          phone: court['phone'] ?? "No contact",
                          size: court['size'] ?? "N/A",
                          imageUrl: court['image_url'] ?? "",
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }
}
