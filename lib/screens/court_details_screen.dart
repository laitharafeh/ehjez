//import 'package:ehjez/widgets/custom_app_bar.dart';
import 'package:ehjez/widgets/image_slider.dart';
import 'package:ehjez/widgets/sports_court_calendar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CourtDetailsScreen extends StatelessWidget {
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
    List<String> imageUrls = [imageUrl, image2Url, image3Url]
        .where((url) => url.isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(
          title: Text(name),
          titleTextStyle: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
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
                  //_infoRow(Icons.sports, "Name", name),
                  _infoRow(Icons.sports_soccer, "Category", category),
                  _infoRow(Icons.location_on, "Location", location),
                  _infoRow(Icons.phone, "Phone", phone),
                  _infoRow(Icons.aspect_ratio, "Size", size),
                  _infoRow(Icons.attach_money, "Price", price),
                  ElevatedButton(
                    onPressed: _launchURL,
                    child: const Text(
                      "Location",
                      style: TextStyle(color: Color(0xFF068631)),
                    ),
                  ),
                  //const SizedBox(height: 10),
                  SportsCourtCalendar(
                    courtId: id,
                    name: name,
                  ),
                  const SizedBox(height: 50)
                ],
              ),
            ),
          ],
        ),
      ),
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
