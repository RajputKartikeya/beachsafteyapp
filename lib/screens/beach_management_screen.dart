import 'package:flutter/material.dart';
import '../data/beach_data.dart';
import '../models/beach.dart';
import '../models/beach_update.dart';
import '../services/notification_service.dart';
import 'beach_feedback_screen.dart';
import 'enhanced_beach_detail_screen.dart';

class BeachManagementScreen extends StatefulWidget {
  const BeachManagementScreen({super.key});

  @override
  State<BeachManagementScreen> createState() => _BeachManagementScreenState();
}

class _BeachManagementScreenState extends State<BeachManagementScreen> {
  final NotificationService _notificationService = NotificationService();
  final List<Beach> _beaches = BeachData.beaches;
  List<Beach> _filteredBeaches = [];
  List<String> _subscribedBeachIds = [];
  bool _isLoading = true;
  bool _areNotificationsEnabled = false;
  final TextEditingController _searchController = TextEditingController();
  String _selectedRegion = 'All Regions';

  List<String> get _regions {
    final regionSet = <String>{'All Regions'};
    for (final beach in _beaches) {
      final location = beach.location;
      if (location.contains(',')) {
        final region = location.split(',').last.trim();
        regionSet.add(region);
      } else {
        regionSet.add(location);
      }
    }
    return regionSet.toList()..sort();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final subscribedBeachIds =
          await _notificationService.getSubscribedBeaches();
      final notificationsEnabled =
          await _notificationService.areNotificationsEnabled();

      setState(() {
        _subscribedBeachIds = subscribedBeachIds;
        _areNotificationsEnabled = notificationsEnabled;
        _filteredBeaches = List.from(_beaches);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
    }
  }

  void _toggleNotifications() async {
    try {
      final enabled = await _notificationService.toggleNotifications();

      setState(() {
        _areNotificationsEnabled = enabled;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled ? 'Notifications enabled' : 'Notifications disabled',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error toggling notifications: $e')),
      );
    }
  }

  Future<void> _toggleBeachSubscription(Beach beach) async {
    final isSubscribed = _subscribedBeachIds.contains(beach.id);

    try {
      if (isSubscribed) {
        await _notificationService.unsubscribeFromBeach(beach.id);
        setState(() {
          _subscribedBeachIds.remove(beach.id);
        });
      } else {
        await _notificationService.subscribeToBeach(beach.id);
        setState(() {
          _subscribedBeachIds.add(beach.id);
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSubscribed
                ? 'Unsubscribed from ${beach.name}'
                : 'Subscribed to ${beach.name}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating subscription: $e')),
      );
    }
  }

  void _filterBeaches(String query) {
    setState(() {
      if (query.isEmpty && _selectedRegion == 'All Regions') {
        _filteredBeaches = List.from(_beaches);
      } else {
        _filteredBeaches = _beaches.where((beach) {
          final nameMatches = query.isEmpty ||
              beach.name.toLowerCase().contains(query.toLowerCase());
          final regionMatches = _selectedRegion == 'All Regions' ||
              beach.location.contains(_selectedRegion);
          return nameMatches && regionMatches;
        }).toList();
      }
    });
  }

  void _filterByRegion(String? region) {
    if (region == null) return;

    setState(() {
      _selectedRegion = region;
      _filterBeaches(_searchController.text);
    });
  }

  void _navigateToBeachDetail(Beach beach) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedBeachDetailScreen(beachId: beach.id),
      ),
    );
  }

  void _navigateToBeachFeedback(Beach beach) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BeachFeedbackScreen(beachId: beach.id, beachName: beach.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beach Management'),
        actions: [
          // Notifications toggle
          IconButton(
            icon: Icon(
              _areNotificationsEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
            ),
            onPressed: _toggleNotifications,
            tooltip: _areNotificationsEnabled
                ? 'Disable Notifications'
                : 'Enable Notifications',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search and filter area
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Search bar
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search beaches...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _filterBeaches('');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: _filterBeaches,
                      ),
                      const SizedBox(height: 8),

                      // Region filter dropdown
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedRegion,
                            hint: const Text('Filter by region'),
                            isExpanded: true,
                            icon: const Icon(Icons.filter_list),
                            items: _regions.map((region) {
                              return DropdownMenuItem<String>(
                                value: region,
                                child: Text(region),
                              );
                            }).toList(),
                            onChanged: _filterByRegion,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Beach list header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Beaches (${_filteredBeaches.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Subscribed: ${_subscribedBeachIds.length}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Beach list
                Expanded(
                  child: _filteredBeaches.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.beach_access,
                                size: 64,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No beaches found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_searchController.text.isNotEmpty ||
                                  _selectedRegion != 'All Regions')
                                TextButton.icon(
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Clear filters'),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _selectedRegion = 'All Regions';
                                      _filteredBeaches = List.from(
                                        _beaches,
                                      );
                                    });
                                  },
                                ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView.builder(
                            itemCount: _filteredBeaches.length,
                            itemBuilder: (context, index) {
                              final beach = _filteredBeaches[index];
                              return _buildBeachCard(beach);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildBeachCard(Beach beach) {
    final isSubscribed = _subscribedBeachIds.contains(beach.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToBeachDetail(beach),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Beach name and subscription toggle
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          beach.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          beach.location,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Subscription toggle
                  IconButton(
                    icon: Icon(
                      isSubscribed
                          ? Icons.notifications_active
                          : Icons.notifications_none,
                      color: isSubscribed ? Colors.blue : Colors.grey,
                    ),
                    onPressed: () => _toggleBeachSubscription(beach),
                    tooltip:
                        isSubscribed ? 'Unsubscribe' : 'Subscribe for alerts',
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Beach info row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Safety status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: beach.isSafe ? Colors.green[100] : Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          beach.isSafe ? Icons.check_circle : Icons.warning,
                          color: beach.isSafe ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          beach.isSafe ? 'Safe' : 'Caution',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: beach.isSafe ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Temperature
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.thermostat_outlined,
                          color: Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${beach.temperature}°C',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Wave height
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.waves_outlined,
                          color: Colors.blue,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${beach.waveHeight} m',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => _navigateToBeachDetail(beach),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                    ),
                    child: const Text('View Details'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToBeachFeedback(beach),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Update'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
