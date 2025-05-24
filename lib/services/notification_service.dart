import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/beach.dart';
import '../models/beach_update.dart';

class NotificationService {
  static const String _subscribedBeachesKey = 'subscribed_beaches';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  // Singleton instance
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  // Stream controller for notifications
  final _notificationController = StreamController<BeachAlert>.broadcast();
  Stream<BeachAlert> get notificationStream => _notificationController.stream;

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? false;
  }

  // Toggle notifications
  Future<bool> toggleNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final currentState = prefs.getBool(_notificationsEnabledKey) ?? false;
    await prefs.setBool(_notificationsEnabledKey, !currentState);
    return !currentState;
  }

  // Get list of subscribed beach IDs
  Future<List<String>> getSubscribedBeaches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_subscribedBeachesKey) ?? [];
  }

  // Subscribe to a beach for notifications
  Future<void> subscribeToBeach(String beachId) async {
    final prefs = await SharedPreferences.getInstance();
    final subscribedBeaches = prefs.getStringList(_subscribedBeachesKey) ?? [];

    if (!subscribedBeaches.contains(beachId)) {
      subscribedBeaches.add(beachId);
      await prefs.setStringList(_subscribedBeachesKey, subscribedBeaches);
    }
  }

  // Unsubscribe from a beach
  Future<void> unsubscribeFromBeach(String beachId) async {
    final prefs = await SharedPreferences.getInstance();
    final subscribedBeaches = prefs.getStringList(_subscribedBeachesKey) ?? [];

    if (subscribedBeaches.contains(beachId)) {
      subscribedBeaches.remove(beachId);
      await prefs.setStringList(_subscribedBeachesKey, subscribedBeaches);
    }
  }

  // Check if subscribed to a specific beach
  Future<bool> isSubscribedToBeach(String beachId) async {
    final subscribedBeaches = await getSubscribedBeaches();
    return subscribedBeaches.contains(beachId);
  }

  // Send a notification about a beach update
  void sendBeachUpdateNotification(BeachUpdate update, Beach beach) {
    if (_notificationController.isClosed) return;

    final alert = BeachAlert(
      id: DateTime.now().toString(),
      title: 'Update for ${beach.name}',
      message: update.description,
      beach: beach,
      isSafe: update.isSafe,
      timestamp: update.timestamp,
      type: AlertType.update,
    );

    _notificationController.add(alert);
  }

  // Send a notification about a safety change
  void sendSafetyChangeNotification(Beach beach, bool wasSafeBefore) {
    if (_notificationController.isClosed) return;

    final alert = BeachAlert(
      id: DateTime.now().toString(),
      title: 'Safety Alert for ${beach.name}',
      message:
          beach.isSafe
              ? 'The beach is now considered safe for swimming.'
              : 'CAUTION: This beach is now marked as unsafe for swimming.',
      beach: beach,
      isSafe: beach.isSafe,
      timestamp: DateTime.now(),
      type: AlertType.safetyChange,
    );

    _notificationController.add(alert);
  }

  // Send a weather alert notification
  void sendWeatherAlertNotification(Beach beach, String alertMessage) {
    if (_notificationController.isClosed) return;

    final alert = BeachAlert(
      id: DateTime.now().toString(),
      title: 'Weather Alert for ${beach.name}',
      message: alertMessage,
      beach: beach,
      isSafe: beach.isSafe,
      timestamp: DateTime.now(),
      type: AlertType.weather,
    );

    _notificationController.add(alert);
  }

  // Store an alert in SharedPreferences
  Future<void> saveAlert(BeachAlert alert) async {
    final prefs = await SharedPreferences.getInstance();
    final alerts = await getStoredAlerts();

    // Add new alert at the beginning
    alerts.insert(0, alert);

    // Keep only the latest 50 alerts
    if (alerts.length > 50) {
      alerts.removeRange(50, alerts.length);
    }

    // Save the list
    final alertJsonList = alerts.map((a) => a.toJson()).toList();
    await prefs.setString('stored_alerts', alertJsonList.toString());
  }

  // Get stored alerts
  Future<List<BeachAlert>> getStoredAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    final alertsJson = prefs.getString('stored_alerts');

    if (alertsJson == null || alertsJson.isEmpty) {
      return [];
    }

    try {
      // Parse the JSON
      final alertsList = List<Map<String, dynamic>>.from(
        alertsJson as List<dynamic>,
      );

      // Convert to BeachAlert objects
      return alertsList.map((json) => BeachAlert.fromJson(json)).toList();
    } catch (e) {
      // If there's an error parsing, return empty list
      return [];
    }
  }

  // Clean up resources
  void dispose() {
    _notificationController.close();
  }
}

// Alert type enum
enum AlertType { update, safetyChange, weather }

// BeachAlert model
class BeachAlert {
  final String id;
  final String title;
  final String message;
  final Beach beach;
  final bool isSafe;
  final DateTime timestamp;
  final AlertType type;

  BeachAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.beach,
    required this.isSafe,
    required this.timestamp,
    required this.type,
  });

  factory BeachAlert.fromJson(Map<String, dynamic> json) {
    return BeachAlert(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      beach: Beach.fromJson(json['beach'] as Map<String, dynamic>),
      isSafe: json['isSafe'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: AlertType.values[json['type'] as int],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'beach': beach.toJson(), // This assumes Beach has a toJson method
      'isSafe': isSafe,
      'timestamp': timestamp.toIso8601String(),
      'type': type.index,
    };
  }
}

// Extension for color based on alert type
extension AlertTypeExtension on AlertType {
  Color get color {
    switch (this) {
      case AlertType.update:
        return Colors.blue;
      case AlertType.safetyChange:
        return Colors.orange;
      case AlertType.weather:
        return Colors.purple;
    }
  }

  IconData get icon {
    switch (this) {
      case AlertType.update:
        return Icons.info_outline;
      case AlertType.safetyChange:
        return Icons.warning_amber_outlined;
      case AlertType.weather:
        return Icons.cloud_outlined;
    }
  }
}
