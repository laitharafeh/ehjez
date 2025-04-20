import 'package:ehjez/screens/court_details_screen.dart';
import 'package:ehjez/widgets/coming_soon_button.dart';
import 'package:ehjez/widgets/custom_app_bar.dart';
import 'package:ehjez/widgets/featured_court_list_tile.dart';
import 'package:ehjez/widgets/home_category_buttons.dart';
import 'package:ehjez/widgets/home_text.dart';
import 'package:ehjez/widgets/size_court_list_tile.dart';
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
  List<Map<String, dynamic>> listOf6v6Courts = [];
  List<Map<String, dynamic>> listOf8v8Courts = [];
  List<Map<String, dynamic>> listOfPadelCourts = [];

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
          .eq('featured', true)
          .limit(5); // Limit to 5 featured courts

      final List<Map<String, dynamic>> response2 = await supabase
          .from('courts')
          .select()
          .eq('featured', true)
          .or('size1.eq.6v6,size2.eq.6v6,size3.eq.6v6')
          .limit(5); // Limit to 5 featured courts

      final List<Map<String, dynamic>> response3 = await supabase
          .from('courts')
          .select()
          .eq('featured', true)
          .or('category.eq.Padel')
          .limit(5); // Limit to 5 featured courts

      final List<Map<String, dynamic>> response4 = await supabase
          .from('courts')
          .select()
          .eq('featured', true)
          .or('size1.eq.8v8,size2.eq.8v8,size3.eq.8v8')
          .limit(5); // Limit to 5 featured courts

      if (!mounted) return;

      setState(() {
        featuredCourts = response;
        listOf6v6Courts = response2;
        listOfPadelCourts = response3;
        listOf8v8Courts = response4;
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
            const HomeText(text: "Categories"),
            const SizedBox(height: 12),
            // Horizontal scrollable category buttons
            HomeCategoryButtons(onGoToSearch: widget.onGoToSearch),
            const Divider(
              color: Colors.grey, // Line color
              thickness: 1, // Line thickness
              height: 20, // Space around the line
            ),
            const SizedBox(height: 15),
            const HomeText(text: "Featured"),
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
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CourtDetailsScreen(
                                  id: court['id'],
                                  name: court['name'] ?? "Unknown",
                                  category: court['category'] ?? "N/A",
                                  location:
                                      court['location'] ?? "Not specified",
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
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: FeaturedCourtListTile(
                                name: court['name'],
                                category: court['category'],
                                location: court['location'],
                                imageUrl: court['image_url']),
                          ),
                        );
                      },
                    ),
              //
              // needs seperation and fixing
              //
            ),
            const SizedBox(height: 15),
            const HomeText(text: "6 vs 6"),
            SizedBox(
              height: 141, // Adjust height for horizontal cards
              child: listOf6v6Courts.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: listOf6v6Courts.length,
                      itemBuilder: (context, index) {
                        final court = listOf6v6Courts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CourtDetailsScreen(
                                  id: court['id'],
                                  name: court['name'] ?? "Unknown",
                                  category: court['category'] ?? "N/A",
                                  location:
                                      court['location'] ?? "Not specified",
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
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: SizeCourtListTile(
                                name: court['name'],
                                category: court['category'],
                                location: court['location'],
                                imageUrl: court['image_url']),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 15),
            const HomeText(text: "Padel"),
            SizedBox(
              height: 141, // Adjust height for horizontal cards
              child: listOfPadelCourts.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: listOfPadelCourts.length,
                      itemBuilder: (context, index) {
                        final court = listOfPadelCourts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CourtDetailsScreen(
                                  id: court['id'],
                                  name: court['name'] ?? "Unknown",
                                  category: court['category'] ?? "N/A",
                                  location:
                                      court['location'] ?? "Not specified",
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
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: SizeCourtListTile(
                                name: court['name'],
                                category: court['category'],
                                location: court['location'],
                                imageUrl: court['image_url']),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 15),
            const HomeText(text: "8 vs 8"),
            SizedBox(
              height: 141, // Adjust height for horizontal cards
              child: listOf8v8Courts.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: listOf8v8Courts.length,
                      itemBuilder: (context, index) {
                        final court = listOf8v8Courts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CourtDetailsScreen(
                                  id: court['id'],
                                  name: court['name'] ?? "Unknown",
                                  category: court['category'] ?? "N/A",
                                  location:
                                      court['location'] ?? "Not specified",
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
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: SizeCourtListTile(
                                name: court['name'],
                                category: court['category'],
                                location: court['location'],
                                imageUrl: court['image_url']),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Tournaments",
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const ComingSoonButton(imagePath: "assets/trophy.png")
          ],
        ),
      ),
    );
  }
}
