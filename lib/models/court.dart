class Court {
  final String id;
  final String name;
  final String category;
  final String location;
  final String phone;
  final String imageUrl;
  final String image2Url;
  final String image3Url;
  final bool featured;
  final String? startTime;
  final String? endTime;
  // Working days as a list of DateTime.weekday integers (1=Mon … 7=Sun).
  // Defaults to all 7 days so existing courts are unaffected.
  final List<int> workingDays;

  const Court({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.phone,
    this.imageUrl = '',
    this.image2Url = '',
    this.image3Url = '',
    this.featured = false,
    this.startTime,
    this.endTime,
    this.workingDays = const [1, 2, 3, 4, 5, 6, 7],
  });

  factory Court.fromMap(Map<String, dynamic> map) {
    // Supabase returns integer arrays as List<dynamic> — cast safely.
    final rawDays = map['working_days'];
    final workingDays = rawDays != null
        ? (rawDays as List<dynamic>).map((d) => d as int).toList()
        : [1, 2, 3, 4, 5, 6, 7];

    return Court(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      category: map['category'] as String? ?? '',
      location: map['location'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? '',
      image2Url: map['image2_url'] as String? ?? '',
      image3Url: map['image3_url'] as String? ?? '',
      featured: map['featured'] as bool? ?? false,
      startTime: map['start_time'] as String?,
      endTime: map['end_time'] as String?,
      workingDays: workingDays,
    );
  }

  List<String> get imageUrls =>
      [imageUrl, image2Url, image3Url].where((u) => u.isNotEmpty).toList();
}
