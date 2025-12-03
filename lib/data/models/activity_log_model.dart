import 'package:tracker/domain/entities/activity_log.dart';

class ActivityLogModel extends ActivityLog {
  const ActivityLogModel({
    super.id,
    required super.latitude,
    required super.longitude,
    required super.imagePath,
    required super.timestamp,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      id: json['id'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      imagePath: json['imagePath'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'imagePath': imagePath,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
