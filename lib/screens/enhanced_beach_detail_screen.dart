import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/beach.dart';
import '../services/firebase_database_service.dart';
import '../services/beach_api_service.dart';
import 'beach_feedback_screen.dart';

class EnhancedBeachDetailScreen extends StatefulWidget {
  final String beachId;

  const EnhancedBeachDetailScreen({super.key, required this.beachId});

  @override
  State<EnhancedBeachDetailScreen> createState() =>
      _EnhancedBeachDetailScreenState();
}

class _EnhancedBeachDetailScreenState extends State<EnhancedBeachDetailScreen> {
  Beach? beach;
  final Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  bool _isMapExpanded = false;
  bool _isLoading = true;
  String _error = '';
  final FirebaseDatabaseService _firebaseService = FirebaseDatabaseService();
  bool _useFirebase = true; // Set to true to use Firebase, false to use API

  @override
  void initState() {
    super.initState();
    _loadBeachData();
  }

  Future<void> _loadBeachData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      if (_useFirebase) {
        // Using Firebase - no need to do anything as StreamBuilder will handle it
        setState(() {
          _isLoading = false;
        });
      } else {
        // Using API
        final loadedBeach = await BeachApiService.getBeachById(widget.beachId);
        setState(() {
          beach = loadedBeach;
          _isLoading = false;
          _createMarker();
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error loading beach data: $e';
      });
    }
  }

  void _createMarker() {
    if (beach == null) return;

    _markers.add(
      Marker(
        markerId: MarkerId(beach!.id),
        position: LatLng(beach!.latitude, beach!.longitude),
        infoWindow: InfoWindow(title: beach!.name, snippet: beach!.location),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          beach!.isSafe ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
        ),
      ),
    );
  }

  void _toggleDataSource() {
    setState(() {
      _useFirebase = !_useFirebase;
      _markers.clear();
      _loadBeachData();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Beach Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Beach Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadBeachData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_useFirebase) {
      return StreamBuilder<Beach?>(
        stream: _firebaseService.getBeachByIdStream(widget.beachId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(title: const Text('Beach Details')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Beach Details')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadBeachData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final firebaseBeach = snapshot.data;
          if (firebaseBeach == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Beach Details')),
              body: const Center(child: Text('Beach not found')),
            );
          }

          // Update markers if needed
          _markers.clear();
          _markers.add(
            Marker(
              markerId: MarkerId(firebaseBeach.id),
              position: LatLng(firebaseBeach.latitude, firebaseBeach.longitude),
              infoWindow: InfoWindow(
                title: firebaseBeach.name,
                snippet: firebaseBeach.location,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                firebaseBeach.isSafe
                    ? BitmapDescriptor.hueGreen
                    : BitmapDescriptor.hueRed,
              ),
            ),
          );

          return _buildBeachDetailContent(firebaseBeach);
        },
      );
    } else {
      // Non-Firebase version (using API data)
      if (beach == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Beach Details')),
          body: const Center(child: Text('Beach not found')),
        );
      }
      return _buildBeachDetailContent(beach!);
    }
  }

  Widget _buildBeachDetailContent(Beach beach) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Sliver app bar with beach name and location
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            actions: [
              // Toggle button to switch between Firebase and API
              IconButton(
                icon: Icon(_useFirebase ? Icons.cloud_done : Icons.cloud_off),
                onPressed: _toggleDataSource,
                tooltip: _useFirebase ? 'Using Firebase' : 'Using API',
              ),
              IconButton(
                icon: const Icon(Icons.feedback_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => BeachFeedbackScreen(
                            beachId: beach.id,
                            beachName: beach.name,
                          ),
                    ),
                  );
                },
                tooltip: 'Submit Feedback',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(beach.name),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image with gradient overlay
                  ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3),
                      BlendMode.darken,
                    ),
                    child: Image.network(
                      'https://source.unsplash.com/featured/?beach,${beach.name.split(" ").first}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.blue.shade200,
                          child: Center(
                            child: Icon(
                              Icons.beach_access,
                              size: 80,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Location text overlay
                  Positioned(
                    left: 16,
                    bottom: 50,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            beach.location,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Data source indicator
                  if (_useFirebase)
                    Positioned(
                      right: 16,
                      bottom: 50,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.sync, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text('Live', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Main content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Safety indicator
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: beach.isSafe ? Colors.green : Colors.red,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        beach.isSafe ? Icons.check_circle : Icons.warning,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        beach.isSafe
                            ? 'SAFE FOR SWIMMING'
                            : 'UNSAFE - SWIM WITH CAUTION',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // Beach stats
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current conditions section
                      Row(
                        children: [
                          const Text(
                            'Current Conditions',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (_useFirebase)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.cloud_done,
                                    size: 14,
                                    color: Colors.blue.shade800,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Real-time data',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Stats cards
                      GridView.count(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildStatsCard(
                            'Temperature',
                            '${beach.temperature}°C',
                            Icons.thermostat_outlined,
                            Colors.orange,
                          ),
                          _buildStatsCard(
                            'Wave Height',
                            '${beach.waveHeight} m',
                            Icons.waves_outlined,
                            Colors.blue,
                          ),
                          _buildStatsCard(
                            'Currents',
                            beach.oceanCurrents,
                            Icons.arrow_forward,
                            Colors.purple,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Description section
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        beach.description,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),

                      const SizedBox(height: 24),

                      // Map section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Location',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            icon: Icon(
                              _isMapExpanded
                                  ? Icons.fullscreen_exit
                                  : Icons.fullscreen,
                            ),
                            label: Text(_isMapExpanded ? 'Collapse' : 'Expand'),
                            onPressed: () {
                              setState(() {
                                _isMapExpanded = !_isMapExpanded;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Map container
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: _isMapExpanded ? 400 : 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(beach.latitude, beach.longitude),
                              zoom: 13,
                            ),
                            markers: _markers,
                            onMapCreated: (controller) {
                              _mapController = controller;
                            },
                            mapType: MapType.normal,
                            zoomControlsEnabled: false,
                            myLocationButtonEnabled: false,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      // Map controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Zoom in button
                          _buildMapControlButton(Icons.add, () {
                            _mapController?.animateCamera(
                              CameraUpdate.zoomIn(),
                            );
                          }),
                          const SizedBox(width: 8),
                          // Reset view button
                          _buildMapControlButton(Icons.center_focus_strong, () {
                            _mapController?.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: LatLng(
                                    beach.latitude,
                                    beach.longitude,
                                  ),
                                  zoom: 13,
                                ),
                              ),
                            );
                          }),
                          const SizedBox(width: 8),
                          // Zoom out button
                          _buildMapControlButton(Icons.remove, () {
                            _mapController?.animateCamera(
                              CameraUpdate.zoomOut(),
                            );
                          }),
                        ],
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapControlButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: Colors.blue,
        tooltip:
            icon == Icons.add
                ? 'Zoom In'
                : icon == Icons.remove
                ? 'Zoom Out'
                : 'Center Map',
      ),
    );
  }
}
