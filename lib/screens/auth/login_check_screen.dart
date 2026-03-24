import 'package:ehjez/constants.dart';
import 'package:ehjez/screens/auth/otp_screen.dart';
import 'package:ehjez/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginCheckScreen extends StatelessWidget {
  LoginCheckScreen({super.key});
  final TextEditingController phonecontroller = TextEditingController();

  bool isValidJordanianNumber(String phonenumber) {
    final RegExp jordanianNumberPattern = RegExp(r'^(?:962|0)7[789]\d{7}$');
    return jordanianNumberPattern.hasMatch(phonenumber);
  }

  // Formats the number to 962XXXXXXXXX — pure string logic, no async needed.
  String _formatNumber(String number) {
    if (RegExp(r'^0').hasMatch(number)) {
      return number.replaceFirstMapped(RegExp(r'^0'), (_) => '962');
    }
    if (RegExp(r'^7').hasMatch(number)) {
      return '962$number';
    }
    return number;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              const Spacer(flex: 2),

              // ── Logo ────────────────────────────────────────────────────
              Text(
                'ehjez',
                style: GoogleFonts.grandstander(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: ehjezGreen,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Book your court in seconds',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),

              const Spacer(flex: 2),

              // ── Card ─────────────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFFEDE9E4), width: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB0A090).withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      'Sign in',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Enter your Jordanian phone number',
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),

                    const SizedBox(height: 24),

                    // ── Phone input ────────────────────────────────────────
                    TextField(
                      controller: phonecontroller,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: '07X XXX XXXX',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(
                          Icons.phone_iphone_outlined,
                          color: Colors.grey[500],
                          size: 20,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: ehjezGreen, width: 1.5),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Send code button ───────────────────────────────────
                    // Synchronous — just validates, formats, and navigates.
                    // The actual OTP request fires from OtpScreen.initState.
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (isValidJordanianNumber(phonecontroller.text)) {
                            final formatted =
                                _formatNumber(phonecontroller.text);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    OtpScreen(phoneNumber: formatted),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please enter a valid Jordanian number'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ehjezGreen,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Send code',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // ── Later link ───────────────────────────────────────────────
              GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const BottomNav()),
                    (_) => false,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Later',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.grey[400],
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
