class BookingModel {
  final String id;
  final String vendorId;
  final String title;
  final String category;
  final String dateLabel;
  final String location;
  final String amount;
  final String status;
  final String imageUrl;

  const BookingModel({
    required this.id,
    required this.vendorId,
    required this.title,
    required this.category,
    required this.dateLabel,
    required this.location,
    required this.amount,
    required this.status,
    required this.imageUrl,
  });
}
