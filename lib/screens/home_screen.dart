import 'package:ehjez/widgets/custom_app_bar.dart';
//import 'package:ehjez/widgets/custom_square_button.dart';
import 'package:ehjez/widgets/featured_court_list_tile.dart';
import 'package:ehjez/widgets/home_category_buttons.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  final Function onGoToSearch;

  const HomeScreen({super.key, required this.onGoToSearch});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> featuredCourts = [];

  @override
  void initState() {
    super.initState();
    fetchFeaturedCourts();
  }

  Future<void> fetchFeaturedCourts() async {
    try {
      final List<Map<String, dynamic>> response = await supabase
          .from('courts')
          .select()
          .limit(5); // Limit to 5 featured courts
      if (!mounted) return;

      setState(() {
        featuredCourts = response;
      });
    } catch (error) {
      debugPrint("Error fetching courts: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Logo and branding
            const SizedBox(height: 40),
            // "Categories" title aligned to left
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Categories",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Horizontal scrollable category buttons
            HomeCategoryButtons(onGoToSearch: widget.onGoToSearch),
            const Divider(
              color: Colors.grey, // Line color
              thickness: 1, // Line thickness
              height: 20, // Space around the line
            ),
            const SizedBox(height: 15),
            // "Featured" title aligned to left
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Featured",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            // Horizontal scroll of featured courts
            SizedBox(
              height: 220, // Adjust height for horizontal cards
              child: featuredCourts.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: featuredCourts.length,
                      itemBuilder: (context, index) {
                        final court = featuredCourts[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: SizedBox(
                            width: 250, // Set fixed width for horizontal cards
                            child: FeaturedCourtListTile(
                              name: court['name'] ?? "Unknown",
                              category: court['category'] ?? "N/A",
                              location: court['location'] ?? "Not specified",
                              imageUrl: court['image_url'] ?? "",
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
