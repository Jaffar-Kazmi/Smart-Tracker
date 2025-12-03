import 'package:tracker/data/datasources/activity_local_data_source.dart';
import 'package:tracker/data/datasources/activity_remote_data_source.dart';
import 'package:tracker/data/models/activity_log_model.dart';
import 'package:tracker/domain/entities/activity_log.dart';
import 'package:tracker/domain/repositories/activity_repository.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityRemoteDataSource remoteDataSource;
  final ActivityLocalDataSource localDataSource;

  ActivityRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<void> addActivity(ActivityLog activity) async {
    final activityModel = ActivityLogModel(
      latitude: activity.latitude,
      longitude: activity.longitude,
      imagePath: activity.imagePath,
      timestamp: activity.timestamp,
    );
    await remoteDataSource.addActivity(activityModel);
  }

  @override
  Future<List<ActivityLog>> getActivities() async {
    try {
      final remoteActivities = await remoteDataSource.getActivities();
      await localDataSource.cacheRecentActivities(remoteActivities.take(5).toList());
      return remoteActivities;
    } catch (e) {
      final localActivities = await localDataSource.getRecentActivities();
      return localActivities;
    }
  }

  @override
  Future<void> deleteActivity(String id) async {
    await remoteDataSource.deleteActivity(id);
  }

  @override
  Future<List<ActivityLog>> searchActivities(String query) async {
    return await remoteDataSource.searchActivities(query);
  }
}
