import 'package:ehjez/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});
  final supabase = Supabase.instance.client;

  void _logout(BuildContext context) async {
    await supabase.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Info Card

            const SizedBox(height: 30),

            // Action Buttons Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.phone),
                      title: Text(user?.phone ?? 'N/A'),
                      onTap: () => _logout(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Log Out'),
                      onTap: () => _logout(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
