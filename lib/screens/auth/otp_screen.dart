import 'package:ehjez/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OtpScreen extends StatelessWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  Future<void> buttonPress(String otp, BuildContext context) async {
    try {
      final supabase = Supabase.instance.client;

      // Verify the Otp
      //
      final AuthResponse res = await supabase.auth.verifyOTP(
        type: OtpType.sms,
        token: otp,
        phone: phoneNumber,
      );
      if (res.session != null) {
        // Check if session was created successfully
        //
        // Add details to database
        //
        final id = supabase.auth.currentUser?.id;
        final check =
            await supabase.from("users").select().eq('phone', phoneNumber);
        if (check.isEmpty) {
          await supabase.from('users').insert({'id': id, 'phone': phoneNumber});
          // ScaffoldMessenger.of(context)
          //     .showSnackBar(SnackBar(content: Text(check.toString()))); // For Debugging
        }
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const BottomNav()),
          (Route<dynamic> route) => false, // Removes all previous routes
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Error: Invalid Code')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController otpController = TextEditingController();

    return Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const SizedBox(height: 100),
        Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 8,
              child: Column(
                children: [
                  Text("Enter Code Sent to $phoneNumber via SMS",
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 30),
                  TextField(
                    controller: otpController,
                    decoration: const InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFF068631), width: 4)),
                      hintText: "Enter code",
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(5),
                        child: Icon(Icons.password),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      buttonPress(otpController.text, context);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(const Color(0xFF068631)),
                    ),
                    child: const Text("Confirm",
                        style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),
            const Spacer()
          ],
        )
      ]),
    );
  }
}
