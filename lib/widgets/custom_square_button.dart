import 'package:flutter/material.dart';

class CustomSquareButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final Color color;
  final double size;
  final String assetPath;

  const CustomSquareButton(
      {super.key,
      required this.onTap,
      required this.text,
      //this.color = const Color(0xFFDCEDC8),
      this.color = const Color(0xFFC8E6C9),
      this.size = 62.0,
      required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(15), // Rounded edges
              ),
              alignment: Alignment.center,
              child: Image(image: AssetImage(assetPath))),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          )
        ],
      ),
    );
  }
}
