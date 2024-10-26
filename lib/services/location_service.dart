import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'training_service.dart';

class LocationService {
  final TrainingService _trainingService = TrainingService();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeBackgroundService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true, // Run as a foreground service
        notificationChannelId: 'location_channel',
        initialNotificationTitle: 'Training Service',
        initialNotificationContent: 'Tracking your training session',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    // Start the service
    service.startService();
  }

  @pragma('vm:entry-point') // Required for background service on Android
  static Future<void> onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized(); // Registers plugins

    // Show foreground notification
    await showForegroundNotification();

    // Timer to fetch location every 10 seconds
    Timer.periodic(Duration(seconds: 10), (timer) async {
      final prefs = await SharedPreferences.getInstance();
      final trainingId = prefs.getString('active_training_id');

      if (trainingId != null) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // Update backend with the location
        await TrainingService().updateTraining(
          trainingId,
          position.latitude,
          position.longitude,
          DateTime.now(),
        );

        // Update route in cache
        _updateRouteInCache(position.latitude, position.longitude);
      }
    });

    // Listen for stop event
    service.on('stop').listen((event) {
      service.stopSelf(); // Stops the service
    });
  }

  // Function to display foreground notification
  static Future<void> showForegroundNotification() async {
    var androidDetails = AndroidNotificationDetails(
      'location_channel', // Channel ID
      'Location Tracking',
      importance: Importance.low,
      priority: Priority.low,
      showWhen: false,
    );

    var platformDetails = NotificationDetails(android: androidDetails);

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.show(
      888, // Notification ID
      'Training Active',
      'Tracking your route...',
      platformDetails,
    );
  }

  static Future<void> _updateRouteInCache(
      double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    String? routeJson = prefs.getString('current_route');
    List<Map<String, dynamic>> route = routeJson != null
        ? List<Map<String, dynamic>>.from(jsonDecode(routeJson))
        : [];

    // Add new point to the route
    route.add({'latitude': latitude, 'longitude': longitude});

    // Save the updated route back to cache
    await prefs.setString('current_route', jsonEncode(route));
  }

  Future<void> stopBackgroundService() async {
    final service = FlutterBackgroundService();
    service.invoke('stop'); // Sends a stop command to the service
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  // Clear the route cache
  Future<void> clearRouteCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_route');
  }
}
