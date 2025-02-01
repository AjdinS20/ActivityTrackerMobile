import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';
import 'training_service.dart';

class LocationService {
  final TrainingService _trainingService = TrainingService();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _useHighAccuracy = true;

  Future<void> initializeBackgroundService() async {
    final service = FlutterBackgroundService();
    final androidNotificationChannel = AndroidNotificationChannel(
      'location_channel', // ID must match the one in `AndroidNotificationDetails`
      'Location Tracking',
      description: 'Tracks location in the background',
      importance: Importance
          .max, // Ensure importance is set to max for foreground notifications
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
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
    WidgetsFlutterBinding.ensureInitialized();
    bool useHighAccuracyLocaiton = false;
    DartPluginRegistrant.ensureInitialized();

    // Initialize SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    // Initialize FlutterLocalNotificationsPlugin
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    await showForegroundNotification(flutterLocalNotificationsPlugin);
    final Battery battery = Battery();
    Timer.periodic(Duration(seconds: 10), (timer) async {
      final trainingId = prefs.getString('active_training_id');

      if (trainingId != null) {
        final batteryLevel = await battery.batteryLevel;
        final bool useHighAccuracy = batteryLevel > 50;
        print(useHighAccuracy.toString() + " " + batteryLevel.toString());
        useHighAccuracyLocaiton = !useHighAccuracyLocaiton;
        print(batteryLevel.toString());
        LocationAccuracy accuracy =
            useHighAccuracy ? LocationAccuracy.high : LocationAccuracy.lowest;
        Position position =
            await Geolocator.getCurrentPosition(desiredAccuracy: accuracy);

        await TrainingService().updateTraining(
          trainingId,
          position.latitude,
          position.longitude,
          DateTime.now(),
        );

        await _updateRouteInCache(position.latitude, position.longitude, prefs);

        service.invoke(
          'update',
          {
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
        );
      }
    });

    service.on('stop').listen((event) {
      service.stopSelf();
    });
  }

  // Function to display foreground notification
  static Future<void> showForegroundNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidDetails = AndroidNotificationDetails(
      'location_channel', // Channel ID
      'Location Tracking',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    var platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      888, // Notification ID
      'Training Active',
      'Tracking your route...',
      platformDetails,
    );
  }

  static Future<void> _updateRouteInCache(
      double latitude, double longitude, SharedPreferences prefs) async {
    String? routeJson = prefs.getString('route');
    List<Map<String, dynamic>> route = routeJson != null
        ? List<Map<String, dynamic>>.from(jsonDecode(routeJson))
        : [];

    // Add new point to the route
    route.add({'latitude': latitude, 'longitude': longitude});

    // Save the updated route back to cache
    await prefs.setString('route', jsonEncode(route));
    print('set the current route string to ' + route.toString());
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
  }

  Future<String?> getWifiBSSID() async {
    String? bssid = await WifiInfo().getWifiBSSID();
    return bssid;
  }
}
