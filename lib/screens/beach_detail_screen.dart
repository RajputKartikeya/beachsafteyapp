import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/beach_data.dart';
import '../models/beach.dart';

class BeachDetailScreen extends StatefulWidget {
  final String beachId;

  const BeachDetailScreen({super.key, required this.beachId});

  @override
  State<BeachDetailScreen> createState() => _BeachDetailScreenState();
}

class _BeachDetailScreenState extends State<BeachDetailScreen> {
  late Beach beach;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    beach = BeachData.getBeachById(widget.beachId);
    _createMarker();
  }

  void _createMarker() {
    _markers.add(
      Marker(
        markerId: MarkerId(beach.id),
        position: LatLng(beach.latitude, beach.longitude),
        infoWindow: InfoWindow(title: beach.name, snippet: beach.location),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          beach.isSafe ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(beach.name), backgroundColor: Colors.blue),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Safety indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: beach.isSafe ? Colors.green : Colors.red,
              child: Center(
                child: Text(
                  beach.isSafe
                      ? 'SAFE FOR SWIMMING'
                      : 'UNSAFE - SWIM WITH CAUTION',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            // Beach details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    beach.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    beach.location,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  // Weather and ocean conditions
                  const Text(
                    'Current Conditions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Information cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoCard(
                        'Temperature',
                        '${beach.temperature}°C',
                        Icons.thermostat,
                      ),
                      _buildInfoCard(
                        'Wave Height',
                        '${beach.waveHeight} m',
                        Icons.waves,
                      ),
                      _buildInfoCard(
                        'Currents',
                        beach.oceanCurrents,
                        Icons.water,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(beach.description, style: const TextStyle(fontSize: 16)),

                  const SizedBox(height: 24),
                  const Text(
                    'Location',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Map view
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(beach.latitude, beach.longitude),
                          zoom: 12,
                        ),
                        markers: _markers,
                        mapType: MapType.normal,
                        myLocationEnabled: false,
                        zoomControlsEnabled: false,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
