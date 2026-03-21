class CourtSizePrice {
  final String courtId;
  final String size;
  final int? price1;
  final int? price2;
  final int numberOfFields;

  const CourtSizePrice({
    required this.courtId,
    required this.size,
    this.price1,
    this.price2,
    required this.numberOfFields,
  });

  factory CourtSizePrice.fromMap(Map<String, dynamic> map) {
    return CourtSizePrice(
      courtId: map['court_id'] as String? ?? '',
      size: map['size'] as String,
      price1: map['price1'] as int?,
      price2: map['price2'] as int?,
      numberOfFields: map['number_of_fields'] as int? ?? 0,
    );
  }
}
