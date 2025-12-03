import 'package:flutter/material.dart';
import 'package:tracker/domain/entities/activity_log.dart';
import 'package:tracker/domain/repositories/activity_repository.dart';

class ActivityProvider extends ChangeNotifier {
  final ActivityRepository repository;

  ActivityProvider({required this.repository});

  List<ActivityLog> _activities = [];
  List<ActivityLog> get activities => _activities;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchActivities() async {
    _isLoading = true;
    notifyListeners();
    try {
      _activities = await repository.getActivities();
    } catch (e) {
      // Handle error
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addActivity(ActivityLog activity) async {
    await repository.addActivity(activity);
    await fetchActivities();
  }

  Future<void> deleteActivity(String id) async {
    await repository.deleteActivity(id);
    await fetchActivities();
  }

  Future<void> searchActivities(String query) async {
    _isLoading = true;
    notifyListeners();
    try {
      _activities = await repository.searchActivities(query);
    } catch (e) {
      // Handle error
    }
    _isLoading = false;
    notifyListeners();
  }
}
