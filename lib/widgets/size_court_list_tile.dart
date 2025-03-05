import 'package:flutter/material.dart';

class SizeCourtListTile extends StatelessWidget {
  final String name;
  final String category;
  final String location;
  final String imageUrl;

  const SizeCourtListTile({
    super.key,
    required this.name,
    required this.category,
    required this.location,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    Color categoryColor = const Color(0xFFC8E6C9);

    return SizedBox(
      height: 100,
      width: 300, // Ensure a fixed width
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            // Court Image
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: Image.network(
                  imageUrl,
                  height: 100,
                  width: 100, // Fixed width for image
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      width: 100,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.image, size: 50)),
                    );
                  },
                ),
              ),
            ),
            // Information Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(
                        label: Text(category),
                        backgroundColor: categoryColor,
                        labelStyle: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
