//import 'package:ehjez/auth_checker.dart';
//import 'package:ehjez/screens/profile_screen.dart';
import 'package:ehjez/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar({super.key});

  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Ehjez',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
      actions: [
        IconButton(
          color: Colors.black,
          onPressed: () {
            //supabase.auth.signOut();
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
