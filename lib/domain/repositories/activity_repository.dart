import 'package:tracker/domain/entities/activity_log.dart';

abstract class ActivityRepository {
  Future<void> addActivity(ActivityLog activity);
  Future<List<ActivityLog>> getActivities();
  Future<void> deleteActivity(String id);
  Future<List<ActivityLog>> searchActivities(String query);
}
