import 'package:flutter/foundation.dart';

@immutable
class FaqItem {
  final String question;
  final String answer;
  final String category;

  const FaqItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}

@immutable
class PolicySection {
  final String title;
  final String content;
  final List<String> bulletPoints;

  const PolicySection({
    required this.title,
    required this.content,
    this.bulletPoints = const [],
  });
}

@immutable
class CancellationTier {
  final String timeframe;
  final String refundPercentage;
  final String description;

  const CancellationTier({
    required this.timeframe,
    required this.refundPercentage,
    required this.description,
  });
}
