import 'package:ehjez/auth_checker.dart';
import 'package:ehjez/firebase_options.dart';
import 'package:ehjez/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'keys.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase must be initialized before Supabase and before runApp.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: 'https://bjijwzpkctdodimnlhxk.supabase.co',
    anonKey: supabaseAnonKey,
  );

  // Set up notification channels, permissions and foreground handlers.
  await NotificationService.initialize();

  runApp(
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
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAF8F5),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const AuthChecker(),
    );
  }
}
