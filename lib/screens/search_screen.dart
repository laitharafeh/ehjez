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
  late Future<List<Map<String, dynamic>>> _courtsFuture;
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

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _courtsFuture =
        fetchCourts(category: _selectedCategory); // Fetch with initial category
  }

  Future<List<Map<String, dynamic>>> fetchCourts({
    String? category,
    String? searchQuery,
  }) async {
    try {
      var query = supabase.from('courts').select();
      if (category != null && category != "All") {
        query = query.eq('category', category);
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('name', '%$searchQuery%');
      }
      final List<Map<String, dynamic>> response = await query;
      return response;
    } catch (error) {
      debugPrint("Error fetching courts: $error");
      rethrow; // Propagate error to FutureBuilder
    }
  }

  void onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _courtsFuture =
          fetchCourts(category: _selectedCategory, searchQuery: _searchQuery);
    });
  }

  void _filterSearchResults(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query.toLowerCase();
        _courtsFuture =
            fetchCourts(category: _selectedCategory, searchQuery: _searchQuery);
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
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _courtsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text("Failed to load courts"));
                } else {
                  List<Map<String, dynamic>> courts = snapshot.data ?? [];
                  if (courts.isEmpty) {
                    return const Center(child: Text("No courts found"));
                  }
                  return ListView.builder(
                    itemCount: courts.length,
                    itemBuilder: (context, index) {
                      final court = courts[index];
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
                          price: court['price'] ?? "N/A",
                          imageUrl: court['image_url'] ?? "",
                        ),
                      );
                    },
                  );
                }
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
    super.dispose();
  }
}
