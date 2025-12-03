import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracker/data/datasources/activity_local_data_source_impl.dart';
import 'package:tracker/data/datasources/activity_remote_data_source_impl.dart';
import 'package:tracker/data/repositories/activity_repository_impl.dart';
import 'package:tracker/presentation/pages/home_page.dart';
import 'package:tracker/presentation/providers/activity_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(MyApp(sharedPreferences: sharedPreferences));
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  const MyApp({super.key, required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ActivityProvider(
            repository: ActivityRepositoryImpl(
              remoteDataSource: ActivityRemoteDataSourceImpl(client: http.Client()),
              localDataSource: ActivityLocalDataSourceImpl(sharedPreferences: sharedPreferences),
            ),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'SmartTracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),
      ),
    );
  }
}
