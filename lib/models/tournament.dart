class Tournament {
  final String id;
  final String courtId;
  final String courtName;
  final String courtCategory;
  final String title;
  final String? description;
  final String date;
  final String? time;
  final int? maxParticipants;
  final int entryFee;
  final String? prize;
  final bool isActive;
  final int registrationCount;

  const Tournament({
    required this.id,
    required this.courtId,
    required this.courtName,
    required this.courtCategory,
    required this.title,
    this.description,
    required this.date,
    this.time,
    this.maxParticipants,
    required this.entryFee,
    this.prize,
    required this.isActive,
    required this.registrationCount,
  });

  factory Tournament.fromMap(Map<String, dynamic> map) {
    final court = map['courts'] as Map<String, dynamic>?;
    final regList = map['tournament_registrations'] as List?;
    final regCount = (regList != null && regList.isNotEmpty)
        ? (regList.first['count'] as int? ?? 0)
        : 0;

    return Tournament(
      id: map['id'] as String,
      courtId: map['court_id'] as String,
      courtName: court?['name'] as String? ?? '',
      courtCategory: court?['category'] as String? ?? '',
      title: map['title'] as String,
      description: map['description'] as String?,
      date: map['date'] as String,
      time: map['time'] as String?,
      maxParticipants: map['max_participants'] as int?,
      entryFee: map['entry_fee'] as int? ?? 0,
      prize: map['prize'] as String?,
      isActive: map['is_active'] as bool? ?? true,
      registrationCount: regCount,
    );
  }

  bool get isFull =>
      maxParticipants != null && registrationCount >= maxParticipants!;

  int? get spotsLeft =>
      maxParticipants != null ? maxParticipants! - registrationCount : null;

  String get entryFeeLabel => entryFee == 0 ? 'Free' : '$entryFee JD';

  /// Formats "2026-04-15" → "15/04/2026"
  String get formattedDate {
    final parts = date.split('-');
    if (parts.length != 3) return date;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }
}
