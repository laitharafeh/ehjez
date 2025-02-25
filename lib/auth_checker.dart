import 'package:ehjez/widgets/bottom_nav.dart';
import '../screens/auth/login_check_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  late final Stream<AuthState> _authStream;

  @override
  void initState() {
    super.initState();
    _authStream = Supabase.instance.client.auth.onAuthStateChange;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _authStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: Text("Please wait")),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
                child:
                    Text("Error retrieving session. Please check connection.")),
          );
        }

        final session = Supabase.instance.client.auth.currentSession;
        return session != null ? const BottomNav() : LoginCheckScreen();
      },
    );
  }
}
