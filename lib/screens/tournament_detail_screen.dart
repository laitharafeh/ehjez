import 'package:ehjez/constants.dart';
import 'package:ehjez/models/tournament.dart';
import 'package:ehjez/providers/providers.dart';
import 'package:ehjez/screens/auth/login_check_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TournamentDetailScreen extends ConsumerStatefulWidget {
  final Tournament tournament;
  const TournamentDetailScreen({super.key, required this.tournament});

  @override
  ConsumerState<TournamentDetailScreen> createState() =>
      _TournamentDetailScreenState();
}

class _TournamentDetailScreenState
    extends ConsumerState<TournamentDetailScreen> {
  bool _isRegistered = false;
  bool _isCheckingRegistration = true;

  @override
  void initState() {
    super.initState();
    _checkRegistration();
  }

  Future<void> _checkRegistration() async {
    final phone =
        Supabase.instance.client.auth.currentUser?.phone;
    if (phone == null) {
      setState(() => _isCheckingRegistration = false);
      return;
    }
    try {
      final registered = await ref
          .read(tournamentRepositoryProvider)
          .isRegistered(widget.tournament.id, phone);
      if (mounted) setState(() => _isRegistered = registered);
    } finally {
      if (mounted) setState(() => _isCheckingRegistration = false);
    }
  }

  Future<void> _showRegisterSheet() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => LoginCheckScreen()));
      return;
    }

    if (widget.tournament.isFull) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This tournament is full.')),
      );
      return;
    }

    final rawPhone =
        Supabase.instance.client.auth.currentUser?.phone ?? '';
    final displayPhone = _formatPhone(rawPhone);
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Register for tournament',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                widget.tournament.title,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Full name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                readOnly: true,
                initialValue: displayPhone,
                decoration: InputDecoration(
                  labelText: 'Phone number',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                  suffixIcon:
                      const Icon(Icons.lock_outline, size: 18, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ehjezGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.pop(sheetCtx);
                    await _submitRegistration(
                      name: nameController.text.trim(),
                      phone: rawPhone,
                    );
                  },
                  child: const Text(
                    'Confirm registration',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitRegistration(
      {required String name, required String phone}) async {
    try {
      await ref.read(tournamentRepositoryProvider).register(
            tournamentId: widget.tournament.id,
            name: name,
            phone: phone,
          );
      if (!mounted) return;
      setState(() => _isRegistered = true);
      ref.invalidate(activeTournamentsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registered successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      final isDuplicate = e.toString().contains('duplicate') ||
          e.toString().contains('unique');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isDuplicate
              ? 'You are already registered for this tournament.'
              : 'Registration failed. Please try again.'),
        ),
      );
    }
  }

  String _formatPhone(String raw) {
    if (raw.startsWith('962') && raw.length == 12) {
      return '+962 ${raw.substring(3, 5)} ${raw.substring(5, 8)} ${raw.substring(8)}';
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tournament;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header banner ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ehjezGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/trophy.png',
                          width: 32, height: 32,
                          color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          t.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.courtName,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Details card ───────────────────────────────────────────────
            _DetailCard(
              children: [
                _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value: t.formattedDate),
                if (t.time != null)
                  _DetailRow(
                      icon: Icons.access_time_outlined,
                      label: 'Time',
                      value: t.time!),
                _DetailRow(
                    icon: Icons.sports_outlined,
                    label: 'Sport',
                    value: t.courtCategory),
                _DetailRow(
                    icon: Icons.attach_money_outlined,
                    label: 'Entry fee',
                    value: t.entryFeeLabel),
                if (t.prize != null)
                  _DetailRow(
                      icon: Icons.emoji_events_outlined,
                      label: 'Prize',
                      value: t.prize!),
                if (t.maxParticipants != null)
                  _DetailRow(
                    icon: Icons.people_outline,
                    label: 'Spots',
                    value: t.isFull
                        ? 'Full (${t.maxParticipants} / ${t.maxParticipants})'
                        : '${t.registrationCount} / ${t.maxParticipants} registered',
                  ),
              ],
            ),

            // ── Description ────────────────────────────────────────────────
            if (t.description != null && t.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'About',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                t.description!,
                style:
                    TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
              ),
            ],

            const SizedBox(height: 32),

            // ── Register button ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: _isCheckingRegistration
                  ? const Center(child: CircularProgressIndicator())
                  : _isRegistered
                      ? Container(
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle,
                                  color: Color(0xFF2E7D32)),
                              SizedBox(width: 8),
                              Text(
                                'Registered',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                t.isFull ? Colors.grey : ehjezGreen,
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: t.isFull ? null : _showRegisterSheet,
                          child: Text(
                            t.isFull ? 'Tournament Full' : 'Register Now',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white),
                          ),
                        ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Reusable detail widgets ───────────────────────────────────────────────────

class _DetailCard extends StatelessWidget {
  final List<Widget> children;
  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children
            .expand((w) => [
                  w,
                  if (w != children.last)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ])
            .toList(),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: ehjezGreen),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
