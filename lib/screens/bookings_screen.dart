import 'package:ehjez/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingsScreen extends StatelessWidget {
  BookingsScreen({super.key});
  late final String error;
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body:
          const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(
          children: [
            Spacer(),
            Text("Bookings Screen", style: TextStyle(fontSize: 20)),
            Spacer(),
          ],
        )
      ]),
    );
  }
}
