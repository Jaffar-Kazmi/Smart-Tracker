import 'package:flutter/foundation.dart';

@immutable
class ActivityLog {
  final String? id;
  final double latitude;
  final double longitude;
  final String imagePath;
  final DateTime timestamp;

  const ActivityLog({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.imagePath,
    required this.timestamp,
  });
}
