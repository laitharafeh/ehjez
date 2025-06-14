import 'package:flutter/material.dart';

class CourtListTile extends StatelessWidget {
  final String name;
  final String category;
  final String location;
  final String phone;
  final String size;
  final String imageUrl;

  const CourtListTile({
    super.key,
    required this.name,
    required this.category,
    required this.location,
    required this.phone,
    required this.size,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    Color categoryColor = const Color(0xFFC8E6C9);

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
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 160,
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Chip(
                      label: Text(category),
                      backgroundColor: categoryColor,
                      labelStyle: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),

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
                // Row(
                //   children: [
                //     const Icon(Icons.phone, color: Colors.green, size: 20),
                //     const SizedBox(width: 6),
                //     Text(
                //       phone,
                //       style:
                //           const TextStyle(fontSize: 11, color: Colors.black87),
                //     ),
                //   ],
                // ),
                const SizedBox(height: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
