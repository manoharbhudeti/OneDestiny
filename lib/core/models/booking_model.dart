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

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['eventDate']?.toString();
    String formattedDate = 'Pending date';
    if (rawDate != null) {
      try {
        final parsed = DateTime.parse(rawDate);
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        formattedDate = '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
      } catch (_) {
        formattedDate = rawDate;
      }
    }

    final totalAmount = (json['amount'] as num?)?.toDouble() ??
        (json['agreedAmount'] as num?)?.toDouble() ??
        0.0;
    final formattedAmount = totalAmount > 0 ? '₹${totalAmount.toInt()}' : 'Quote pending';

    final coverImg = json['vendorCoverPhotoUrl']?.toString() ??
        json['vendorCoverImageUrl']?.toString() ??
        json['imageUrl']?.toString() ??
        '';

    final statusStr = json['statusName']?.toString() ??
        json['status']?.toString() ??
        'PENDING';

    return BookingModel(
      id: json['id']?.toString() ?? '',
      vendorId: json['vendorProfileId']?.toString() ?? json['vendorId']?.toString() ?? '',
      title: json['vendorBusinessName']?.toString() ?? json['title']?.toString() ?? '',
      category: json['vendorCategoryName']?.toString() ??
          json['categoryName']?.toString() ??
          json['category']?.toString() ??
          'Wedding Service',
      dateLabel: formattedDate,
      location: json['venue']?.toString() ??
          json['eventLocation']?.toString() ??
          json['location']?.toString() ??
          'Location pending',
      amount: formattedAmount,
      status: statusStr.toUpperCase(),
      imageUrl: coverImg.isNotEmpty
          ? coverImg
          : 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=400&q=80',
    );
  }

  BookingModel copyWith({
    String? id,
    String? vendorId,
    String? title,
    String? category,
    String? dateLabel,
    String? location,
    String? amount,
    String? status,
    String? imageUrl,
  }) {
    return BookingModel(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      title: title ?? this.title,
      category: category ?? this.category,
      dateLabel: dateLabel ?? this.dateLabel,
      location: location ?? this.location,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
