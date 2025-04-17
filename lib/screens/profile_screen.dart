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
      appBar: AppBar(title: const Text("Profile")),
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
                    const ListTile(
                      leading: Icon(Icons.person),
                      title: Text("Name"),
                    ),
                    ListTile(
                      leading: Icon(Icons.phone),
                      title: Text(user?.phone ?? 'N/A'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Need Help?\nContact Us!",
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16),
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.email),
                      title: Text("Email"),
                    ),
                    ListTile(
                      leading: Icon(Icons.phone),
                      title: Text(user?.phone ?? 'N/A'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text("Log Out"),
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
