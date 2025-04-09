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
            const SizedBox(width: 15),
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
                assetPath: 'assets/tennis_ball.png'),
            const SizedBox(width: 10),
            CustomSquareButton(
                onTap: () {
                  onGoToSearch("Badminton");
                },
                text: "Badminton",
                assetPath: 'assets/badminton_ball.png'),
            const SizedBox(width: 10),
            CustomSquareButton(
                onTap: () {
                  onGoToSearch("Basketball");
                },
                text: "Basketball",
                assetPath: 'assets/basketball.png'),
            const SizedBox(width: 10),
            CustomSquareButton(
                onTap: () {
                  onGoToSearch("Volleyball");
                },
                text: "Volleyball",
                assetPath: 'assets/volleyball.png'),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
