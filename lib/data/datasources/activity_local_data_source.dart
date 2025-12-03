import 'package:tracker/data/models/activity_log_model.dart';

abstract class ActivityLocalDataSource {
  Future<List<ActivityLogModel>> getRecentActivities();
  Future<void> cacheRecentActivities(List<ActivityLogModel> activities);
}
