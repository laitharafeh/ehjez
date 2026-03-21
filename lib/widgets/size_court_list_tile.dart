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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
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
              child: Row(
                children: [

                  // ── Square image — bleeds to edge ───────────────────────
                  SizedBox(
                    width: 88,
                    height: 88,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.image,
                              size: 28, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),

                  // ── Info section ────────────────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          // Name
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 4),

                          // Location
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: 11, color: Colors.grey[500]),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  location,
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey[500]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // Category pill + availability dot
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _categoryBgColor(category),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: _categoryTextColor(category),
                                  ),
                                ),
                              ),

                              const Spacer(),

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
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
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
