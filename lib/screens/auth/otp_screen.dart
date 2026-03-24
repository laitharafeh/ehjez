import 'package:ehjez/constants.dart';
import 'package:ehjez/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final supabase = Supabase.instance.client;

  // Tracks the OTP send status so the UI can reflect it
  _SendStatus _sendStatus = _SendStatus.sending;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    // Fire the OTP request as soon as the screen appears — no waiting on
    // the previous screen. User sees this screen instantly.
    _sendOtp();
  }

  Future<void> _sendOtp() async {
    try {
      await supabase.auth.signInWithOtp(phone: widget.phoneNumber.trim());
      if (!mounted) return;
      setState(() => _sendStatus = _SendStatus.sent);
    } catch (e) {
      if (!mounted) return;
      setState(() => _sendStatus = _SendStatus.failed);
    }
  }

  Future<void> _verifyOtp(String otp) async {
    if (_isVerifying) return;
    setState(() => _isVerifying = true);

    try {
      final AuthResponse res = await supabase.auth.verifyOTP(
        type: OtpType.sms,
        token: otp,
        phone: widget.phoneNumber,
      );

      if (res.session != null) {
        final id = supabase.auth.currentUser?.id;
        final check = await supabase
            .from('users')
            .select()
            .eq('phone', widget.phoneNumber);
        if (check.isEmpty) {
          await supabase
              .from('users')
              .insert({'id': id, 'phone': widget.phoneNumber});
        }
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const BottomNav()),
          (_) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isVerifying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid code — please try again')),
      );
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  // Formats 96279XXXXXXX → +962 79 XXX XXXX for display
  String get _displayPhone {
    final raw = widget.phoneNumber;
    if (raw.startsWith('962') && raw.length == 12) {
      return '+962 ${raw.substring(3, 5)} ${raw.substring(5, 8)} ${raw.substring(8)}';
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F5),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                      'Enter your code',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 4),

                    // ── Send status indicator ──────────────────────────────
                    Row(
                      children: [
                        if (_sendStatus == _SendStatus.sending) ...[
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Sending code to $_displayPhone…',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[500]),
                          ),
                        ] else if (_sendStatus == _SendStatus.sent) ...[
                          Icon(Icons.check_circle_outline,
                              size: 14, color: ehjezGreen),
                          const SizedBox(width: 6),
                          Text(
                            'Code sent to $_displayPhone',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[500]),
                          ),
                        ] else ...[
                          const Icon(Icons.error_outline,
                              size: 14, color: Colors.redAccent),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Failed to send code — tap resend',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[500]),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── OTP input ──────────────────────────────────────────
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 15, letterSpacing: 4),
                      decoration: InputDecoration(
                        hintText: '------',
                        hintStyle: TextStyle(
                            color: Colors.grey[400], letterSpacing: 4),
                        prefixIcon: Icon(
                          Icons.lock_outline,
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

                    // ── Confirm button ─────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isVerifying
                            ? null
                            : () => _verifyOtp(_otpController.text.trim()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ehjezGreen,
                          disabledBackgroundColor:
                              ehjezGreen.withOpacity(0.5),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isVerifying
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Confirm',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Resend ─────────────────────────────────────────────
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _sendStatus = _SendStatus.sending);
                          _sendOtp();
                        },
                        child: Text(
                          'Resend code',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

enum _SendStatus { sending, sent, failed }
