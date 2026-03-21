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

  Color _categoryBgColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'football':
        return const Color(0xFFE8F5E9);
      case 'padel':
        return const Color(0xFFE3F2FD);
      case 'tennis':
        return const Color(0xFFFFF8E1);
      case 'basketball':
        return const Color(0xFFFBE9E7);
      case 'badminton':
        return const Color(0xFFFCE4EC);
      case 'volleyball':
        return const Color(0xFFEDE7F6);
      default:
        return const Color(0xFFC8E6C9);
    }
  }

  Color _categoryTextColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'football':
        return const Color(0xFF2E7D32);
      case 'padel':
        return const Color(0xFF1565C0);
      case 'tennis':
        return const Color(0xFFF57F17);
      case 'basketball':
        return const Color(0xFFBF360C);
      case 'badminton':
        return const Color(0xFF880E4F);
      case 'volleyball':
        return const Color(0xFF4527A0);
      default:
        return const Color(0xFF068631);
    }
  }

  Color _categoryAccentColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'football':
        return const Color(0xFF2E7D32);
      case 'padel':
        return const Color(0xFF1565C0);
      case 'tennis':
        return const Color(0xFFF57F17);
      case 'basketball':
        return const Color(0xFFBF360C);
      case 'badminton':
        return const Color(0xFF880E4F);
      case 'volleyball':
        return const Color(0xFF4527A0);
      default:
        return const Color(0xFF068631);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDE9E4), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB0A090).withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Image with gradient — name overlaid ───────────────────────
            // Reduced from 160px → 110px. Name on image saves a full text
            // row, keeping the card compact enough to show 2–3 at once.
            SizedBox(
              height: 110,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),

                  // Gradient for text legibility
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                        stops: [0.4, 1.0],
                      ),
                    ),
                  ),

                  // Category badge — top right
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _categoryAccentColor(category),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Court name — bottom left
                  Positioned(
                    left: 12,
                    right: 80,
                    bottom: 9,
                    child: Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(blurRadius: 4, color: Colors.black45),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // ── Info row — location + category pill + availability ─────────
            // Everything in one compact row so the card stays short.
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
              child: Row(
                children: [

                  // Location
                  const Icon(Icons.location_on,
                      size: 13, color: Colors.redAccent),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      location,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Availability placeholder
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF068631),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Open',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
