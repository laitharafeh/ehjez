import 'package:ehjez/constants.dart';
import 'package:ehjez/screens/auth/login_check_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});
  final supabase = Supabase.instance.client;

  void _logout(BuildContext context) async {
    await supabase.auth.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginCheckScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F5),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [

            const SizedBox(height: 32),

            // ── Logo ──────────────────────────────────────────────────────
            Text(
              'ehjez',
              style: GoogleFonts.grandstander(
                fontSize: 52,
                fontWeight: FontWeight.bold,
                color: ehjezGreen,
              ),
            ),

            const SizedBox(height: 36),

            if (user != null) ...[
              // ── Logged in: phone + support + logout ─────────────────────

              _SectionCard(
                children: [
                  _InfoTile(
                    icon: Icons.phone,
                    iconColor: ehjezGreen,
                    label: 'Phone',
                    value: _formatPhone(user.phone),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _SectionLabel(label: 'Support'),
              const SizedBox(height: 8),
              _SectionCard(
                children: [
                  _InfoTile(
                    icon: Icons.email_outlined,
                    iconColor: Colors.grey[600]!,
                    label: 'Contact us',
                    value: 'support@ehjez.jo',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _SectionLabel(label: 'Account'),
              const SizedBox(height: 8),
              _SectionCard(
                children: [
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.logout,
                          color: Color(0xFFC62828), size: 18),
                    ),
                    title: const Text(
                      'Log out',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFC62828),
                      ),
                    ),
                    onTap: () => _logout(context),
                  ),
                ],
              ),

            ] else ...[
              // ── Guest: prompt + sign in button ──────────────────────────

              _SectionCard(
                children: [
                  _InfoTile(
                    icon: Icons.person_outline,
                    iconColor: Colors.grey[500]!,
                    label: 'Status',
                    value: 'Not signed in',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _SectionLabel(label: 'Support'),
              const SizedBox(height: 8),
              _SectionCard(
                children: [
                  _InfoTile(
                    icon: Icons.email_outlined,
                    iconColor: Colors.grey[600]!,
                    label: 'Contact us',
                    value: 'support@ehjez.jo',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _SectionLabel(label: 'Account'),
              const SizedBox(height: 8),
              _SectionCard(
                children: [
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.login,
                          color: Color(0xFF2E7D32), size: 18),
                    ),
                    title: const Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => LoginCheckScreen()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Format phone from 96279XXXXXXX → +962 79 XXX XXXX
  String _formatPhone(String? raw) {
    if (raw == null || raw.isEmpty) return 'N/A';
    if (raw.startsWith('962') && raw.length == 12) {
      return '+962 ${raw.substring(3, 5)} ${raw.substring(5, 8)} ${raw.substring(8)}';
    }
    return raw;
  }
}

// ── Reusable section card ─────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDE9E4), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB0A090).withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

// ── Info row ──────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[500],
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
