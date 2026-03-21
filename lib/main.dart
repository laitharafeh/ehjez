import 'package:ehjez/auth_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'keys.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://bjijwzpkctdodimnlhxk.supabase.co',
    anonKey: supabaseAnonKey,
  );
  runApp(
    // ProviderScope is required — it's the container for all Riverpod state.
    // Wrap the entire app so every widget can access providers.
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFAF8F5),
      ),
      home: const AuthChecker(),
    );
  }
}
