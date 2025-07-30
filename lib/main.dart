import '../auth_checker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'keys.dart';

Future<void> main() async {
  await Supabase.initialize(
      url: 'https://vmwktzlripivknoqmwrc.supabase.co',
      anonKey: supabaseAnonKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthChecker(), // This will check session and navigate
    );
  }
}
