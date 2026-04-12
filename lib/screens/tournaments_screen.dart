import 'package:ehjez/constants.dart';
import 'package:ehjez/models/tournament.dart';
import 'package:ehjez/providers/providers.dart';
import 'package:ehjez/screens/tournament_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TournamentsScreen extends ConsumerWidget {
  const TournamentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentsAsync = ref.watch(activeTournamentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tournaments',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: tournamentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading tournaments: $e')),
        data: (tournaments) {
          if (tournaments.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/trophy.png', width: 80, opacity: const AlwaysStoppedAnimation(0.3)),
                  const SizedBox(height: 16),
                  const Text(
                    'No tournaments right now',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Check back soon',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(activeTournamentsProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: tournaments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) =>
                  _TournamentCard(tournament: tournaments[i]),
            ),
          );
        },
      ),
    );
  }
}

// ── Tournament card ───────────────────────────────────────────────────────────

class _TournamentCard extends StatelessWidget {
  final Tournament tournament;
  const _TournamentCard({required this.tournament});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TournamentDetailScreen(tournament: tournament),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title row ───────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ehjezGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset('assets/trophy.png', width: 22, height: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tournament.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _SportBadge(sport: tournament.courtCategory),
                ],
              ),

              const SizedBox(height: 12),

              // ── Court ───────────────────────────────────────────────────
              _InfoRow(
                icon: Icons.location_on_outlined,
                text: tournament.courtName,
              ),

              const SizedBox(height: 6),

              // ── Date + time ─────────────────────────────────────────────
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                text: tournament.time != null
                    ? '${tournament.formattedDate}  •  ${tournament.time}'
                    : tournament.formattedDate,
              ),

              const SizedBox(height: 12),

              // ── Entry fee + prize + spots ────────────────────────────────
              Row(
                children: [
                  _Chip(
                    label: tournament.entryFeeLabel,
                    color: tournament.entryFee == 0
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF8E1),
                    textColor: tournament.entryFee == 0
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFF57F17),
                  ),
                  if (tournament.prize != null) ...[
                    const SizedBox(width: 8),
                    _Chip(
                      label: '🏆 ${tournament.prize}',
                      color: const Color(0xFFFFF3E0),
                      textColor: const Color(0xFFE65100),
                    ),
                  ],
                  const Spacer(),
                  if (tournament.maxParticipants != null)
                    Text(
                      tournament.isFull
                          ? 'Full'
                          : '${tournament.spotsLeft} spots left',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: tournament.isFull ? Colors.red : Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Small reusable widgets ────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.grey[500]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  const _Chip(
      {required this.label, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style:
            TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
      ),
    );
  }
}

class _SportBadge extends StatelessWidget {
  final String sport;
  const _SportBadge({required this.sport});

  static const _colors = {
    'Football': Color(0xFFE8F5E9),
    'Padel': Color(0xFFE3F2FD),
    'Tennis': Color(0xFFFFF8E1),
    'Badminton': Color(0xFFFCE4EC),
    'Basketball': Color(0xFFFBE9E7),
    'Volleyball': Color(0xFFEDE7F6),
  };

  static const _textColors = {
    'Football': Color(0xFF2E7D32),
    'Padel': Color(0xFF1565C0),
    'Tennis': Color(0xFFF57F17),
    'Badminton': Color(0xFFC62828),
    'Basketball': Color(0xFFBF360C),
    'Volleyball': Color(0xFF4527A0),
  };

  @override
  Widget build(BuildContext context) {
    final bg = _colors[sport] ?? const Color(0xFFF5F5F5);
    final fg = _textColors[sport] ?? Colors.black87;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        sport,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
