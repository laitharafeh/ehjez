import 'package:flutter/material.dart';

class FeaturedCourtListTile extends StatelessWidget {
  final String name;
  final String category;
  final String location;
  final String imageUrl;

  const FeaturedCourtListTile({
    super.key,
    required this.name,
    required this.category,
    required this.location,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    Color categoryColor = const Color(0xFFC8E6C9);
    // if (category == "Football") {
    //   categoryColor = Colors.lightGreen[100];
    // } else if (category == "Padel") {
    //   categoryColor = Colors.lightBlue[100];
    // } else {
    //   categoryColor = Colors.grey; // Default color for other categories
    // }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
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
              height: 120,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
