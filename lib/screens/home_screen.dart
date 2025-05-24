import 'package:flutter/material.dart';
import '../models/beach.dart';
import '../widgets/beach_card.dart';
import '../services/beach_api_service.dart';
import 'enhanced_beach_detail_screen.dart';
import 'package:beachsafteyapp/screens/beach_list_screen.dart';
import 'package:beachsafteyapp/screens/user_profile_screen.dart';
import 'package:beachsafteyapp/screens/beach_management_screen.dart';
import 'package:beachsafteyapp/screens/notifications_screen.dart';
import 'package:beachsafteyapp/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Beach> _beaches = [];
  List<Beach> _filteredBeaches = [];
  bool _isLoading = true;
  String _error = '';
  int _selectedIndex = 0;
  final NotificationService _notificationService = NotificationService();
  int _notificationCount = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadBeaches();
    _loadNotificationCount();
  }

  Future<void> _loadBeaches() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      // Try to fetch from API
      try {
        final beaches = await BeachApiService.getBeaches();
        setState(() {
          _beaches = beaches;
          _filteredBeaches = List.from(beaches);
          _isLoading = false;
        });
      } catch (e) {
        // If API fails, fall back to local data
        setState(() {
          _beaches = _getLocalBeaches();
          _filteredBeaches = List.from(_beaches);
          _isLoading = false;
          _error = 'Could not connect to server. Showing local data.';
        });

        // Show a snackbar with the error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Using local data: $e'),
              duration: const Duration(seconds: 3),
              action: SnackBarAction(label: 'Retry', onPressed: _loadBeaches),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error loading beaches: $e';
      });
    }
  }

  List<Beach> _getLocalBeaches() {
    // Return hardcoded beaches as fallback
    return [
      Beach(
        id: '1',
        name: 'Goa Beach',
        location: 'Goa',
        description: 'Beautiful beach with golden sand and clear waters.',
        latitude: 15.5007,
        longitude: 73.8356,
        isSafe: true,
        temperature: 28.0,
        waveHeight: 1.5,
        oceanCurrents: 'Moderate',
      ),
      Beach(
        id: '2',
        name: 'Kovalam Beach',
        location: 'Kerala',
        description: 'Scenic beach surrounded by coconut groves.',
        latitude: 8.3988,
        longitude: 76.9780,
        isSafe: true,
        temperature: 29.0,
        waveHeight: 1.2,
        oceanCurrents: 'Light',
      ),
      Beach(
        id: '3',
        name: 'Varkala Beach',
        location: 'Kerala',
        description: 'Cliff beach with natural springs and mineral water.',
        latitude: 8.7378,
        longitude: 76.7164,
        isSafe: true,
        temperature: 27.5,
        waveHeight: 1.8,
        oceanCurrents: 'Moderate',
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchBeaches(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredBeaches = List.from(_beaches);
      });
      return;
    }

    setState(() {
      _filteredBeaches =
          _beaches.where((beach) {
            final name = beach.name.toLowerCase();
            final location = beach.location.toLowerCase();
            final searchQuery = query.toLowerCase();
            return name.contains(searchQuery) || location.contains(searchQuery);
          }).toList();
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

  Future<void> _loadNotificationCount() async {
    final alerts = await _notificationService.getStoredAlerts();
    setState(() {
      _notificationCount = alerts.length;
    });
  }

  static final List<Widget> _screens = [
    const BeachListScreen(),
    const BeachManagementScreen(),
    const NotificationsScreen(),
    const UserProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 2) {
      // Reset notification count when notification screen is visited
      setState(() {
        _notificationCount = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: _screens.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.beach_access),
            label: 'Manage',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (_notificationCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        _notificationCount > 9
                            ? '9+'
                            : _notificationCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Alerts',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
