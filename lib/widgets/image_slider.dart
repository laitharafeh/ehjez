import 'package:flutter/material.dart';

class ImageSlider extends StatelessWidget {
  final List<String> imageUrls;
  const ImageSlider({super.key, required, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: PageView.builder(
          itemCount: imageUrls.isNotEmpty ? imageUrls.length : 1,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: imageUrls.isNotEmpty
                  ? Image.network(
                      imageUrls[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          "lib/assets/football2.jpg",
                          fit: BoxFit.cover,
                          width: double.infinity,
                        );
                      },
                    )
                  : Image.asset(
                      "lib/assets/football2.jpg",
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
            );
          },
        ),
      ),
    );
  }
}
