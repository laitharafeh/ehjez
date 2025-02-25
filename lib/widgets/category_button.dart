import 'package:flutter/material.dart';

class CategoryButtons extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryButtons({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: ElevatedButton(
                onPressed: () => onCategorySelected(category),
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedCategory == category
                      ? const Color(0xFF068631)
                      : Colors.grey[300],
                  foregroundColor: selectedCategory == category
                      ? Colors.white
                      : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(category),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
