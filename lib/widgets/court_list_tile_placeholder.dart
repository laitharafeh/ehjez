import 'package:flutter/material.dart';

class CourtListTilePlaceholder extends StatelessWidget {
  const CourtListTilePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // grey box for image
          Container(width: 64, height: 64, color: Colors.grey[300]),
          const SizedBox(width: 12),
          // grey bars for text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 16, color: Colors.grey[300]),
                const SizedBox(height: 8),
                Container(height: 14, width: 150, color: Colors.grey[300]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
