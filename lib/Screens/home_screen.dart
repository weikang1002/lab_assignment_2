import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/location_service.dart';
import '../../services/participation_service.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  final String title;
  const HomeScreen({super.key, required this.title});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String fairName = "Education & Job Fair 2026";
  final LatLng fairLocation = const LatLng(1.5336, 103.6819); 
  final double fairRadius = 150.0;
  final int fairPoints = 100;

  LatLng? userLocation;
  String address = "Fetching location...";
  int totalPoints = 0;
  bool isAtFair = false;
  
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    try {
      Position pos = await _locationService.getCurrentLocation();
      String addr = await _locationService.getAddressFromCoordinates(pos.latitude, pos.longitude);
      int points = await ParticipationService.getTotalPoints();

      double distance = Geolocator.distanceBetween(
        pos.latitude, pos.longitude, fairLocation.latitude, fairLocation.longitude
      );

      setState(() {
        userLocation = LatLng(pos.latitude, pos.longitude);
        address = addr;
        totalPoints = points;
        isAtFair = distance <= fairRadius;
      });
      
      _mapController.move(userLocation!, 16.0);
    } catch (e) {
      setState(() => address = "Location Error: Check GPS");
    }
  }

  Future<void> _joinFair() async {
    if (isAtFair) {
      // Passes 3 arguments: fairName, fairPoints, and address
      await ParticipationService.recordParticipation(fairName, fairPoints, address);
      
      _refreshData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Success! Earned $fairPoints points.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: fairLocation, initialZoom: 16.0),
            children: [
              TileLayer(urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"),
              CircleLayer(circles: [
                CircleMarker(
                  point: fairLocation,
                  radius: fairRadius,
                  useRadiusInMeter: true,
                  color: Colors.indigo.withValues(alpha: 0.2),
                  borderColor: Colors.indigo,
                  borderStrokeWidth: 2,
                ),
              ]),
              MarkerLayer(markers: [
                if (userLocation != null)
                  Marker(point: userLocation!, child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40)),
                Marker(point: fairLocation, child: const Icon(Icons.school, color: Colors.red, size: 40)),
              ]),
            ],
          ),
          _buildControlPanel(),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Positioned(
      bottom: 20, left: 15, right: 15,
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min,
            children: [
              Text(fairName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text("Address: $address", textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const Divider(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(children: [
                    const Text("Status", style: TextStyle(fontSize: 12)),
                    Chip(label: Text(isAtFair ? "At Fair" : "Not At Fair"), backgroundColor: isAtFair ? Colors.green[100] : Colors.red[100]),
                  ]),
                  Column(children: [
                    const Text("Total Points", style: TextStyle(fontSize: 12)),
                    Text("$totalPoints", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo)),
                  ]),
                ],
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: isAtFair ? _joinFair : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 45)),
                child: const Text("JOIN FAIR"),
              ),
              TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const HistoryScreen())), child: const Text("View Participation History")),
            ],
          ),
        ),
      ),
    );
  }
}