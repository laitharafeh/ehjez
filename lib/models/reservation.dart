class Reservation {
  final int id;
  final String userId;
  final String courtId;
  final String? courtName;
  final String? courtCategory;
  final String date;
  final String startTime;
  final int duration;
  final String size;
  final int price;
  final double commission;

  const Reservation({
    required this.id,
    required this.userId,
    required this.courtId,
    this.courtName,
    this.courtCategory,
    required this.date,
    required this.startTime,
    required this.duration,
    required this.size,
    required this.price,
    required this.commission,
  });

  factory Reservation.fromMap(Map<String, dynamic> map) {
    final court = map['courts'] as Map<String, dynamic>?;
    return Reservation(
      id: map['id'] as int,
      userId: map['user_id'] as String,
      courtId: map['court_id'] as String,
      courtName: court?['name'] as String?,
      courtCategory: court?['category'] as String?,
      date: map['date'] as String,
      startTime: map['start_time'] as String,
      duration: map['duration'] as int,
      size: map['size'] as String? ?? '',
      price: map['price'] as int? ?? 0,
      commission: (map['commission'] as num?)?.toDouble() ?? 0.0,
    );
  }

  DateTime get startDateTime {
    final d = date.split('-');
    final t = startTime.split(':');
    return DateTime(
      int.parse(d[0]), int.parse(d[1]), int.parse(d[2]),
      int.parse(t[0]), int.parse(t[1]),
    );
  }

  bool get isCurrent => startDateTime.isAfter(DateTime.now());
}
