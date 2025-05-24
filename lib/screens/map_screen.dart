import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/beach_data.dart';
import '../models/beach.dart';
import 'enhanced_beach_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with AutomaticKeepAliveClientMixin {
  late GoogleMapController _mapController;
  final Map<String, Marker> _markers = {};
  final List<Beach> _beaches = BeachData.beaches;
  Beach? _selectedBeach;
  bool _isLoading = true;
  MapType _currentMapType = MapType.normal;

  // Initial camera position - centered on India
  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(20.5937, 78.9629), // Center of India
    zoom: 4.5,
  );

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  void _createMarkers() {
    for (final beach in _beaches) {
      final marker = Marker(
        markerId: MarkerId(beach.id),
        position: LatLng(beach.latitude, beach.longitude),
        infoWindow: InfoWindow(
          title: beach.name,
          snippet: '${beach.location} • ${beach.isSafe ? "Safe" : "Caution"}',
        ),
        onTap: () {
          _selectBeach(beach);
        },
        icon: BitmapDescriptor.defaultMarkerWithHue(
          beach.isSafe ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
        ),
      );

      _markers[beach.id] = marker;
    }
  }

  void _selectBeach(Beach beach) {
    setState(() {
      _selectedBeach = beach;
    });

    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(beach.latitude, beach.longitude),
          zoom: 12,
        ),
      ),
    );
  }

  void _navigateToBeachDetail(String beachId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedBeachDetailScreen(beachId: beachId),
      ),
    );
  }

  void _changeMapType() {
    setState(() {
      _currentMapType =
          _currentMapType == MapType.normal
              ? MapType.satellite
              : _currentMapType == MapType.satellite
              ? MapType.hybrid
              : MapType.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        // Map
        GoogleMap(
          initialCameraPosition: _initialCameraPosition,
          markers: _markers.values.toSet(),
          mapType: _currentMapType,
          onMapCreated: (controller) {
            setState(() {
              _mapController = controller;
              _isLoading = false;
            });
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),

        // Loading indicator
        if (_isLoading) const Center(child: CircularProgressIndicator()),

        // Map controls
        Positioned(
          right: 16,
          top: 16,
          child: Column(
            children: [
              // Map type toggle
              FloatingActionButton.small(
                heroTag: 'mapTypeButton',
                onPressed: _changeMapType,
                backgroundColor: Colors.white,
                child: Icon(
                  _currentMapType == MapType.normal
                      ? Icons.satellite_alt
                      : _currentMapType == MapType.satellite
                      ? Icons.map_outlined
                      : Icons.map,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              // My location button
              FloatingActionButton.small(
                heroTag: 'locationButton',
                onPressed: () {
                  // Request current location
                },
                backgroundColor: Colors.white,
                child: const Icon(Icons.my_location, color: Colors.blue),
              ),
              const SizedBox(height: 8),
              // Reset view button
              FloatingActionButton.small(
                heroTag: 'resetViewButton',
                onPressed: () {
                  _mapController.animateCamera(
                    CameraUpdate.newCameraPosition(_initialCameraPosition),
                  );
                  setState(() {
                    _selectedBeach = null;
                  });
                },
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.center_focus_strong,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),

        // Beach info card - appears when a beach is selected
        if (_selectedBeach != null)
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Safety indicator
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedBeach!.isSafe ? Colors.green : Colors.red,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _selectedBeach!.isSafe
                            ? 'SAFE FOR SWIMMING'
                            : 'UNSAFE - SWIM WITH CAUTION',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Beach details
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Beach name and location
                        Text(
                          _selectedBeach!.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _selectedBeach!.location,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Beach stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStat(
                              Icons.thermostat_outlined,
                              '${_selectedBeach!.temperature}°C',
                            ),
                            _buildStat(
                              Icons.waves_outlined,
                              '${_selectedBeach!.waveHeight} m',
                            ),
                            _buildStat(
                              Icons.water_outlined,
                              _selectedBeach!.oceanCurrents,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        // View details button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                () =>
                                    _navigateToBeachDetail(_selectedBeach!.id),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('View Details'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Filter button - could expand to show filtering options
        Positioned(
          left: 16,
          top: 16,
          child: FloatingActionButton.small(
            heroTag: 'filterButton',
            onPressed: () {
              // Show filtering options
              _showFilterDialog();
            },
            backgroundColor: Colors.white,
            child: const Icon(Icons.filter_list, color: Colors.blue),
          ),
        ),
      ],
    );
  }

  Widget _buildStat(IconData icon, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Beaches',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Show only:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Safe Beaches'),
                      selected: true,
                      onSelected: (selected) {},
                    ),
                    FilterChip(
                      label: const Text('Unsafe Beaches'),
                      selected: true,
                      onSelected: (selected) {},
                    ),
                    FilterChip(
                      label: const Text('Mild Currents'),
                      selected: false,
                      onSelected: (selected) {},
                    ),
                    FilterChip(
                      label: const Text('Low Waves'),
                      selected: false,
                      onSelected: (selected) {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }
}
