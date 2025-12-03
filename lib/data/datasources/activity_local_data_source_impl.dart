import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracker/data/models/activity_log_model.dart';
import 'activity_local_data_source.dart';

const CACHED_RECENT_ACTIVITIES = 'CACHED_RECENT_ACTIVITIES';

class ActivityLocalDataSourceImpl implements ActivityLocalDataSource {
  final SharedPreferences sharedPreferences;

  ActivityLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<ActivityLogModel>> getRecentActivities() {
    final jsonString = sharedPreferences.getString(CACHED_RECENT_ACTIVITIES);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return Future.value(
        jsonList.map((json) => ActivityLogModel.fromJson(json)).toList(),
      );
    } else {
      return Future.value([]);
    }
  }

  @override
  Future<void> cacheRecentActivities(List<ActivityLogModel> activities) {
    final jsonList = activities.map((activity) => activity.toJson()).toList();
    return sharedPreferences.setString(
      CACHED_RECENT_ACTIVITIES,
      json.encode(jsonList),
    );
  }
}
