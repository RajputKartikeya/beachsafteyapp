import 'package:flutter/material.dart';
import '../models/beach.dart';
import '../widgets/beach_card.dart';
import '../services/beach_api_service.dart';
import '../services/firebase_database_service.dart';
import 'enhanced_beach_detail_screen.dart';

class BeachListScreen extends StatefulWidget {
  const BeachListScreen({super.key});

  @override
  State<BeachListScreen> createState() => _BeachListScreenState();
}

class _BeachListScreenState extends State<BeachListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseDatabaseService _firebaseService = FirebaseDatabaseService();
  List<Beach> _filteredBeaches = [];
  bool _isLoading = true;
  String _error = '';
  bool _useFirebase = true; // Set to true to use Firebase, false to use API

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _searchBeaches(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchBeaches(String query) {
    if (!_useFirebase) return; // Only filter if we're using Firebase

    if (query.isEmpty) {
      setState(() {
        _filteredBeaches = [];
      });
      return;
    }

    _firebaseService.searchBeaches(query).then((beaches) {
      setState(() {
        _filteredBeaches = beaches;
      });
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

  void _toggleDataSource() {
    setState(() {
      _useFirebase = !_useFirebase;
      _filteredBeaches = [];
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BeachSafe India'),
        actions: [
          // Toggle button to switch between Firebase and API
          IconButton(
            icon: Icon(_useFirebase ? Icons.cloud_done : Icons.cloud_off),
            onPressed: _toggleDataSource,
            tooltip: _useFirebase ? 'Using Firebase' : 'Using API',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search beaches...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _searchBeaches('');
                          },
                        )
                        : null,
              ),
            ),
          ),

          // Data source indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(
                  _useFirebase ? Icons.cloud_done : Icons.cloud_off,
                  size: 16,
                  color: _useFirebase ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  _useFirebase
                      ? 'Real-time data from Firebase'
                      : 'Data from API server',
                  style: TextStyle(
                    color: _useFirebase ? Colors.green : Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          // Beach list
          Expanded(
            child:
                _useFirebase ? _buildFirebaseBeachList() : _buildApiBeachList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFirebaseBeachList() {
    return StreamBuilder<List<Beach>>(
      stream: _firebaseService.getBeachesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final beaches = snapshot.data ?? [];
        final displayBeaches =
            _searchController.text.isNotEmpty ? _filteredBeaches : beaches;

        if (displayBeaches.isEmpty) {
          return const Center(child: Text('No beaches found'));
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Firebase automatically refreshes, but we'll add this for UX consistency
            setState(() {});
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: displayBeaches.length,
            itemBuilder: (context, index) {
              final beach = displayBeaches[index];
              return BeachCard(
                beach: beach,
                onTap: () => _navigateToBeachDetail(beach),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildApiBeachList() {
    return FutureBuilder<List<Beach>>(
      future: BeachApiService.getBeaches(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final beaches = snapshot.data ?? [];

        if (beaches.isEmpty) {
          return const Center(child: Text('No beaches found'));
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: beaches.length,
            itemBuilder: (context, index) {
              final beach = beaches[index];
              return BeachCard(
                beach: beach,
                onTap: () => _navigateToBeachDetail(beach),
              );
            },
          ),
        );
      },
    );
  }
}
