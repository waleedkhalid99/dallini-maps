import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng currentPos = const LatLng(33.3152, 44.3661);
  double heading = 0;
  final MapController mapController = MapController();

  Future<void> updateLocation() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) return;

    final Position pos = await Geolocator.getCurrentPosition();
    setState(() {
      currentPos = LatLng(pos.latitude, pos.longitude);
      heading = pos.heading;
    });
    mapController.move(currentPos, 16);
  }

  @override
  void initState() {
    super.initState();
    updateLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: currentPos,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.dallini.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: currentPos,
                    width: 50,
                    height: 50,
                    child: Transform.rotate(
                      angle: heading * 3.1415926535 / 180,
                      child: const Icon(
                        Icons.navigation,
                        color: Color(0xFF1A73E8),
                        size: 45,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
                ],
              ),
              child: const TextField(
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'ابحث عن مكان',
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: updateLocation,
        child: const Icon(Icons.my_location, color: Color(0xFF1A73E8)),
      ),
    );
  }
}
