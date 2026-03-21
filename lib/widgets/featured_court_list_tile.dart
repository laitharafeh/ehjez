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

  Color _categoryColor(String cat) {
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
    return SizedBox(
      width: 210,
      child: Padding(
        // Padding outside so the shadow isn't clipped by the SizedBox
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 5),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB0A090).withOpacity(0.18),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFEDE9E4),
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Image with gradient overlay ─────────────────────────
                  SizedBox(
                    height: 118,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.image,
                                  size: 36, color: Colors.grey),
                            ),
                          ),
                        ),

                        // Gradient so name is always readable over any photo
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black54],
                              stops: [0.45, 1.0],
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
                              color: _categoryColor(category),
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

                        // Court name — bottom left, over the gradient
                        Positioned(
                          left: 10,
                          right: 10,
                          bottom: 8,
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
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

                  // ── Info bar ────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 12, color: Colors.redAccent),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            location,
                            style:
                                TextStyle(fontSize: 11, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Availability placeholder
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2E7D32),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Available',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
