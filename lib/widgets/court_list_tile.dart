import 'package:flutter/material.dart';

class CourtListTile extends StatelessWidget {
  final String name;
  final String category;
  final String location;
  final String phone;
  final String size;
  final String price;
  final String imageUrl;

  const CourtListTile({
    super.key,
    required this.name,
    required this.category,
    required this.location,
    required this.phone,
    required this.size,
    required this.price,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    Color categoryColor = const Color(0xFFC8E6C9);
    // if (category == "Football") {
    //   categoryColor = const Color(0xFFDCEDC8); // light green
    // } else if (category == "Padel") {
    //   categoryColor = const Color(0xFFB3E5FC); // light blue
    //   //categoryColor = const Color(0xFFFFF9C4); // Volley
    // } else {
    //   categoryColor =
    //       const Color(0xFF9E9E9E); // Default color for other categories
    // }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Court Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.image, size: 50)),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Court Name & Category Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Chip(
                      label: Text(category),
                      backgroundColor: categoryColor,
                      labelStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.redAccent, size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Phone
                Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.green, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      phone,
                      style:
                          const TextStyle(fontSize: 11, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
