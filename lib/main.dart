import '../auth_checker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
      url: 'https://vmwktzlripivknoqmwrc.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZtd2t0emxyaXBpdmtub3Ftd3JjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzcwNjU1ODMsImV4cCI6MjA1MjY0MTU4M30.s6b2Bp8aQodNZZVXqP4QMVHxxJdlA1bkSUn21PGS8Po');
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
