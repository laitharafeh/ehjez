import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ImageSlider extends StatefulWidget {
  final List<String> imageUrls;
  const ImageSlider({super.key, required this.imageUrls});

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 250,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: PageView.builder(
              controller: _pageController,
              itemCount:
                  widget.imageUrls.isNotEmpty ? widget.imageUrls.length : 1,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: widget.imageUrls.isNotEmpty
                      ? Image.network(
                          widget.imageUrls[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                                child: CircularProgressIndicator());
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
        ),

        // Page Indicator (Dots)
        if (widget.imageUrls.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: widget.imageUrls.length,
              effect: const ExpandingDotsEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: Colors.green, // Change to your theme color
                dotColor: Colors.grey,
              ),
            ),
          ),
      ],
    );
  }
}
