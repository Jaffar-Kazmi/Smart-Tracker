import 'package:tracker/data/models/activity_log_model.dart';

abstract class ActivityRemoteDataSource {
  Future<void> addActivity(ActivityLogModel activity);
  Future<List<ActivityLogModel>> getActivities();
  Future<void> deleteActivity(String id);
  Future<List<ActivityLogModel>> searchActivities(String query);
}
