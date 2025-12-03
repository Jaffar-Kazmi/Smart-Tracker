import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tracker/data/models/activity_log_model.dart';
import 'activity_remote_data_source.dart';

class ActivityRemoteDataSourceImpl implements ActivityRemoteDataSource {
  final http.Client client;
  final String _baseUrl = 'https://api.smarttracker.com'; // Placeholder

  ActivityRemoteDataSourceImpl({required this.client});

  @override
  Future<void> addActivity(ActivityLogModel activity) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/activities'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(activity.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add activity');
    }
  }

  @override
  Future<List<ActivityLogModel>> getActivities() async {
    final response = await client.get(Uri.parse('$_baseUrl/activities'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ActivityLogModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get activities');
    }
  }

  @override
  Future<void> deleteActivity(String id) async {
    final response = await client.delete(Uri.parse('$_baseUrl/activities/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete activity');
    }
  }

  @override
  Future<List<ActivityLogModel>> searchActivities(String query) async {
    final response = await client.get(Uri.parse('$_baseUrl/activities?q=$query'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ActivityLogModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search activities');
    }
  }
}
