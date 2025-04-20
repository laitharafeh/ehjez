import 'package:ehjez/constants.dart';
import 'package:flutter/material.dart';

class HomeText extends StatelessWidget {
  final String text;
  final IconData icon;
  const HomeText({super.key, required this.text, required this.icon});

  @override
  Widget build(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Icon(
              icon,
              color: ehjezGreen,
            )
          ],
        ),
      ),
    );
  }
}
