import 'package:ehjez/widgets/custom_square_button.dart';
import 'package:flutter/material.dart';

class HomeCategoryButtons extends StatelessWidget {
  final Function onGoToSearch;

  const HomeCategoryButtons({super.key, required this.onGoToSearch});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const SizedBox(width: 8),
            CustomSquareButton(
              onTap: () {
                onGoToSearch(
                    "Football"); // This triggers the callback passed from BottomNav
              },
              text: "Football",
              assetPath: 'assets/football_cat.png',
            ),
            const SizedBox(width: 10),
            CustomSquareButton(
                onTap: () {
                  onGoToSearch("Padel");
                },
                text: "Padel",
                assetPath: 'assets/padel_cut.PNG'),
            const SizedBox(width: 10),
            CustomSquareButton(
                onTap: () {
                  onGoToSearch("Tennis");
                },
                text: "Tennis",
                assetPath: 'assets/padel_cut.PNG'),
            const SizedBox(width: 10),
            CustomSquareButton(
                onTap: () {
                  onGoToSearch("Badminton");
                },
                text: "Badminton",
                assetPath: 'assets/padel_cut.PNG'),
            const SizedBox(width: 10),
            CustomSquareButton(
                onTap: () {
                  onGoToSearch("Basketball");
                },
                text: "Basketball",
                assetPath: 'assets/padel_cut.PNG'),
            const SizedBox(width: 10),
            CustomSquareButton(
                onTap: () {
                  onGoToSearch("Volleyball");
                },
                text: "Volleyball",
                assetPath: 'assets/padel_cut.PNG'),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
