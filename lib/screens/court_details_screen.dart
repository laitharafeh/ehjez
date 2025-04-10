// CourtDetailsScreen.dart
import 'package:ehjez/constants.dart';
import 'package:ehjez/widgets/image_slider.dart';
import 'package:ehjez/widgets/sports_court_calendar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CourtDetailsScreen extends StatefulWidget {
  final String id;
  final String name;
  final String category;
  final String location;
  final String phone;
  final String size;
  final String price;
  final String imageUrl;
  final String image2Url;
  final String image3Url;

  const CourtDetailsScreen({
    super.key,
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.phone,
    required this.size,
    required this.price,
    required this.imageUrl,
    required this.image2Url,
    required this.image3Url,
  });

  @override
  State<CourtDetailsScreen> createState() => _CourtDetailsScreenState();
}

class _CourtDetailsScreenState extends State<CourtDetailsScreen> {
  DateTime? _selectedTimeSlot;

  Future<void> _launchURL() async {
    final Uri uri = Uri.parse('https://maps.app.goo.gl/UTYee2MTPFi67wna9');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not launch";
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> imageUrls = [
      widget.imageUrl,
      widget.image2Url,
      widget.image3Url
    ].where((url) => url.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Slideshow
            ImageSlider(imageUrls: imageUrls),

            const SizedBox(height: 20),

            // Court Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _infoRow(
                              Icons.sports_soccer, "Category", widget.category),
                          _infoRow(
                              Icons.location_on, "Location", widget.location),
                          _infoRow(Icons.phone, "Phone", widget.phone),
                          _infoRow(Icons.attach_money, "Price", widget.price),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _launchURL,
                              icon: const Icon(Icons.map, color: Colors.white),
                              label: const Text(
                                "Open in Maps",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ehjezGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Calendar widget with a callback to update the selected time slot.
                  SportsCourtCalendar(
                    courtId: widget.id,
                    name: widget.name,
                    onTimeSlotSelected: (DateTime selectedSlot) {
                      setState(() {
                        _selectedTimeSlot = selectedSlot;
                      });
                    },
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar: appears when a time slot is selected.
      bottomNavigationBar: _selectedTimeSlot != null
          ? Container(
              padding: const EdgeInsets.fromLTRB(40, 20, 25, 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Price: ${widget.price} JDs",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Reserve Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ehjezGreen,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      // Implement reserve logic here.
                    },
                    child: const Text(
                      'Reserve',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF068631), size: 28),
          const SizedBox(width: 12),
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
