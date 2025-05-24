import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../models/beach.dart';

class FirebaseDatabaseService {
  final DatabaseReference _beachesRef = FirebaseDatabase.instance.ref(
    'beaches',
  );

  // Get a stream of all beaches
  Stream<List<Beach>> getBeachesStream() {
    return _beachesRef.onValue.map((event) {
      final dynamic data = event.snapshot.value;
      if (data == null) {
        return <Beach>[];
      }

      final List<Beach> beaches = [];

      // Handle data returned as a List
      if (data is List) {
        for (int i = 0; i < data.length; i++) {
          if (data[i] != null && data[i] is Map<dynamic, dynamic>) {
            final Map<String, dynamic> beachData = {};
            data[i].forEach((k, v) => beachData[k.toString()] = v);
            try {
              beaches.add(Beach.fromJson(beachData));
            } catch (e) {
              print('Error parsing beach data (list): $e');
            }
          }
        }
      }
      // Handle data returned as a Map
      else if (data is Map) {
        data.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            final Map<String, dynamic> beachData = {};
            value.forEach((k, v) => beachData[k.toString()] = v);
            try {
              beaches.add(Beach.fromJson(beachData));
            } catch (e) {
              print('Error parsing beach data (map): $e');
            }
          }
        });
      }

      return beaches;
    });
  }

  // Get a specific beach by ID as a stream
  Stream<Beach?> getBeachByIdStream(String id) {
    // First try to query by the 'id' field
    return _beachesRef
        .orderByChild('id')
        .equalTo(id)
        .onValue
        .map((event) {
          final dynamic data = event.snapshot.value;
          if (data == null) {
            print('Beach with ID $id not found using orderByChild');
            return null;
          }

          try {
            // Handle data returned as a Map (most common case)
            if (data is Map) {
              if (data.isEmpty) return null;

              // Get the first (and only) value in the result map
              final beachData = data.values.first as Map<dynamic, dynamic>;

              // Convert to proper format for Beach.fromJson
              final Map<String, dynamic> formattedData = {};
              beachData.forEach((k, v) => formattedData[k.toString()] = v);

              return Beach.fromJson(formattedData);
            }
            // Handle data returned as a List (less common)
            else if (data is List) {
              // Find the beach with the matching ID in the list
              for (int i = 0; i < data.length; i++) {
                if (data[i] != null &&
                    data[i] is Map<dynamic, dynamic> &&
                    data[i]['id'] == id) {
                  final Map<String, dynamic> formattedData = {};
                  data[i].forEach((k, v) => formattedData[k.toString()] = v);
                  return Beach.fromJson(formattedData);
                }
              }
            }
            return null;
          } catch (e) {
            print('Error parsing beach data by ID: $e');
            return null;
          }
        })
        .handleError((error) {
          print('Error getting beach by ID: $error');
          return null;
        });
  }

  // Get all beaches once (not as a stream)
  Future<List<Beach>> getBeaches() async {
    final snapshot = await _beachesRef.get();
    final dynamic data = snapshot.value;

    if (data == null) {
      return <Beach>[];
    }

    final List<Beach> beaches = [];

    // Handle data returned as a List
    if (data is List) {
      for (int i = 0; i < data.length; i++) {
        if (data[i] != null && data[i] is Map<dynamic, dynamic>) {
          final Map<String, dynamic> beachData = {};
          data[i].forEach((k, v) => beachData[k.toString()] = v);
          try {
            beaches.add(Beach.fromJson(beachData));
          } catch (e) {
            print('Error parsing beach data (list): $e');
          }
        }
      }
    }
    // Handle data returned as a Map
    else if (data is Map) {
      data.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          final Map<String, dynamic> beachData = {};
          value.forEach((k, v) => beachData[k.toString()] = v);
          try {
            beaches.add(Beach.fromJson(beachData));
          } catch (e) {
            print('Error parsing beach data (map): $e');
          }
        }
      });
    }

    return beaches;
  }

  // Get a specific beach by ID
  Future<Beach?> getBeachById(String id) async {
    try {
      // Try fetching by query first
      final snapshot = await _beachesRef.orderByChild('id').equalTo(id).get();
      final dynamic data = snapshot.value;

      if (data == null) {
        print('Beach with ID $id not found');
        return null;
      }

      // Handle data returned as a Map
      if (data is Map) {
        if (data.isEmpty) return null;

        // Get the first (and only) value in the result map
        final beachData = data.values.first as Map<dynamic, dynamic>;

        // Convert to proper format for Beach.fromJson
        final Map<String, dynamic> formattedData = {};
        beachData.forEach((k, v) => formattedData[k.toString()] = v);

        return Beach.fromJson(formattedData);
      }
      // Handle data returned as a List
      else if (data is List) {
        // Find the beach with the matching ID in the list
        for (int i = 0; i < data.length; i++) {
          if (data[i] != null &&
              data[i] is Map<dynamic, dynamic> &&
              data[i]['id'] == id) {
            final Map<String, dynamic> formattedData = {};
            data[i].forEach((k, v) => formattedData[k.toString()] = v);
            return Beach.fromJson(formattedData);
          }
        }
      }

      return null;
    } catch (e) {
      print('Error getting beach by ID: $e');
      return null;
    }
  }

  // Search beaches by name or location
  Future<List<Beach>> searchBeaches(String query) async {
    // Get all beaches and filter locally
    final allBeaches = await getBeaches();

    return allBeaches
        .where(
          (beach) =>
              beach.name.toLowerCase().contains(query.toLowerCase()) ||
              beach.location.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}
