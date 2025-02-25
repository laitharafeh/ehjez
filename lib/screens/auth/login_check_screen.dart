import 'package:ehjez/screens/auth/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginCheckScreen extends StatelessWidget {
  LoginCheckScreen({super.key});
  final TextEditingController phonecontroller = TextEditingController();
  //
  // Function to check if valid number
  //
  bool isValidJordanianNumber(String phonenumber) {
    final RegExp jordanianNumberPattern = RegExp(r'^(?:962|0)7[789]\d{7}$');

    return jordanianNumberPattern.hasMatch(phonenumber);
  }
  //
  //
  //
  //

  Future<String> buttonPress(String number, BuildContext context) async {
    //
    // Adjust the number to 962XXXXXXXXX format
    String phoneNumber = number;
    if (RegExp(r'^0').hasMatch(number)) {
      phoneNumber = number.replaceFirstMapped(RegExp(r'^0'), (match) => '962');
    }
    if (RegExp(r'^7').hasMatch(number)) {
      phoneNumber = '962$number'; // Add "962" to the beginning
    }
    //
    // Sign in/up
    try {
      // Initialize instance
      final supabase = Supabase.instance.client;
      await supabase.auth.signInWithOtp(
        phone: phoneNumber.trim(),
      );
    } catch (e) {
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(SnackBar(content: Text(e.toString())));
    }
    return phoneNumber;
  }

  void goToOtpScreen(BuildContext context, String phone) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => OtpScreen(
                  phoneNumber: phone,
                )));
  }

  @override
  Widget build(BuildContext context) {
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
                  const Text("Welcome", style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 50),
                  TextField(
                    controller: phonecontroller,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFF068631), width: 4)),
                      hintText: "Phone Number",
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(5),
                        child: Icon(Icons.phone_iphone_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () async {
                      if (isValidJordanianNumber(phonecontroller.text)) {
                        String finalNumber =
                            await buttonPress(phonecontroller.text, context);
                        goToOtpScreen(context, finalNumber);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid')));
                      }
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
