import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker/domain/entities/activity_log.dart';
import 'package:tracker/presentation/pages/camera_page.dart';
import 'package:tracker/presentation/providers/activity_provider.dart';
import 'package:tracker/services/location_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = LocationService();
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    Future.microtask(() =>
        Provider.of<ActivityProvider>(context, listen: false).fetchActivities());
  }

  Future<void> _getUserLocation() async {
    try {
      final Position position = await _locationService.getCurrentLocation();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: _currentLocation!,
            infoWindow: const InfoWindow(title: 'Your Location'),
          ),
        );
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 15),
      );
    } catch (e) {
      // Handle location errors, e.g., show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  Future<void> _addActivity() async {
    final String? imagePath = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraPage()),
    );

    if (imagePath != null && _currentLocation != null) {
      final newActivity = ActivityLog(
        latitude: _currentLocation!.latitude,
        longitude: _currentLocation!.longitude,
        imagePath: imagePath,
        timestamp: DateTime.now(),
      );
      await Provider.of<ActivityProvider>(context, listen: false)
          .addActivity(newActivity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartTracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getUserLocation,
          )
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            child: _currentLocation == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentLocation!,
                      zoom: 15,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                    markers: _markers,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Activities',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    Provider.of<ActivityProvider>(context, listen: false)
                        .searchActivities(_searchController.text);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<ActivityProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.activities.isEmpty) {
                  return const Center(child: Text('No activities yet.'));
                }
                return ListView.builder(
                  itemCount: provider.activities.length,
                  itemBuilder: (context, index) {
                    final activity = provider.activities[index];
                    return ListTile(
                      title: Text(
                          'Lat: ${activity.latitude}, Lng: ${activity.longitude}'),
                      subtitle: Text(activity.timestamp.toString()),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          if (activity.id != null) {
                            Provider.of<ActivityProvider>(context, listen: false)
                                .deleteActivity(activity.id!);
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addActivity,
        child: const Icon(Icons.add),
      ),
    );
  }
}
