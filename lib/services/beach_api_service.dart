import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/beach.dart';

class BeachApiService {
  // Base URLs for different environments
  static const String _emulatorUrl = 'http://10.0.2.2:3000/api';
  static const String _iosEmulatorUrl = 'http://localhost:3000/api';
  static const String _physicalDeviceUrl =
      'http://192.168.0.170:3000/api'; // Your network IP
  static const String _webUrl = 'http://localhost:3000/api';

  // Get the appropriate base URL based on the platform
  static String get baseUrl {
    if (kIsWeb) {
      return _webUrl;
    }

    if (Platform.isAndroid) {
      // Android emulator needs 10.0.2.2 instead of localhost
      bool isEmulator =
          true; // This is simplified, actual detection is more complex
      return isEmulator ? _emulatorUrl : _physicalDeviceUrl;
    }

    if (Platform.isIOS) {
      // iOS simulator can use localhost
      bool isSimulator =
          true; // This is simplified, actual detection is more complex
      return isSimulator ? _iosEmulatorUrl : _physicalDeviceUrl;
    }

    // Default fallback
    return _physicalDeviceUrl;
  }

  // Get all beaches from the API
  static Future<List<Beach>> getBeaches() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}/beaches'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Beach.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load beaches: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get a specific beach by ID
  static Future<Beach> getBeachById(String id) async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}/beaches/$id'));

      if (response.statusCode == 200) {
        return Beach.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load beach: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Search beaches by query
  static Future<List<Beach>> searchBeaches(String query) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}/beaches/search?query=$query'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Beach.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search beaches: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
