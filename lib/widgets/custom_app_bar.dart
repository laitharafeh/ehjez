//import 'package:ehjez/auth_checker.dart';
//import 'package:ehjez/screens/profile_screen.dart';
import 'package:ehjez/constants.dart';
import 'package:ehjez/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar({super.key});

  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        'ehjez',
        style: GoogleFonts.grandstander(
            textStyle: Theme.of(context).textTheme.displayLarge,
            fontSize: 48,
            fontWeight: FontWeight.bold,
            //fontStyle: FontStyle.italic,
            color: ehjezGreen),
      ),
      // title: const Image(
      //   image: AssetImage("assets/ehjez_appbar.png"),
      // ),
      actions: [
        IconButton(
          color: Colors.black,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(),
              ),
            );
          },
          icon: const Icon(Icons.person),
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
