import 'dart:async';

import 'package:activity_tracker/models/training_detail_dto.dart';
import 'package:activity_tracker/services/location_service.dart';
import 'package:activity_tracker/services/training_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:activity_tracker/generated/l10n.dart'; // For localization

class NewTrainingPage extends StatefulWidget {
  @override
  _NewTrainingPageState createState() => _NewTrainingPageState();
}

class _NewTrainingPageState extends State<NewTrainingPage>
    with WidgetsBindingObserver {
  final MapController _mapController = MapController();
  Future<LatLng>? _currentPosition;
  List<LatLng> _route = [];
  bool _isRunning = true; // true for running, false for biking
  bool _isTracking = false;

  final TrainingService _trainingService = TrainingService();
  final LocationService _locationService = LocationService();
  StreamSubscription<Map<String, dynamic>?>? _serviceSubscription;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _loadRoute(); // Load the route from cache on startup
    _checkIfTracking();
    WidgetsBinding.instance
        .addObserver(this); // Add observer for app lifecycle changes
    _initializeCurrentLocation();
    _startListeningToService();
  }

  Future<void> _checkIfTracking() async {
    final prefs = await SharedPreferences.getInstance();
    final trainingId = prefs.getString('active_training_id');
    if (trainingId != null) {
      setState(() {
        _isTracking = true;
      });
      // Optionally, load the route from cache
      await _loadRoute();
    } else {
      setState(() {
        _isTracking = false;
        prefs.remove('route');
      });
    }
  }

  void _startListeningToService() {
    final service = FlutterBackgroundService();

    _serviceSubscription = service.on('update').listen((event) {
      if (event != null) {
        double latitude = event['latitude'];
        double longitude = event['longitude'];

        setState(() {
          _route.add(LatLng(latitude, longitude));
          _mapController.move(LatLng(latitude, longitude), _mapController.zoom);
        });
      }
    });
  }

  void _initializeCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    LatLng currentPosition = LatLng(position.latitude, position.longitude);
    setState(() {
      _currentPosition =
          Future.value(LatLng(position.latitude, position.longitude));
    });
  }

// Fetch current location using Geolocator

  @override
  void dispose() {
    _serviceSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Handle app lifecycle events to stop the training and service on close
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      _finishTrainingOnClose();
    }
  }

  // Request location permissions
  Future<void> _requestPermissions() async {
    PermissionStatus status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      status = await Permission.locationWhenInUse.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Location permission is required to use this feature.'),
        ));
      }
    }
    PermissionStatus statusAlways = await Permission.locationAlways.status;
    if (!status.isGranted) {
      status = await Permission.locationAlways.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Background location permission is required to use this feature.'),
        ));
      }
    }
  }

  Future<bool> _showExitWarningDialog() async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(S.of(context).warning),
              content: Text(S.of(context).exitTrainingWarning),
              actions: [
                TextButton(
                  child: Text(S.of(context).cancel),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text(S.of(context).exit),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false; // Return false if dialog is dismissed
  }

  Future<void> _loadRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final trainingId = prefs.getString('active_training_id');

    if (trainingId != null) {
      TrainingDetailDto? trainingDetail =
          await _trainingService.getTrainingDetail(trainingId);

      if (trainingDetail != null) {
        setState(() {
          _route = trainingDetail.points
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
        });
      }
    }
  }

  Future<void> _startTraining() async {
    // 0 for running, 1 for biking
    final trainingType = _isRunning ? 0 : 1;

    // Start the training session
    final trainingId = await _trainingService.startTraining(trainingType);

    if (trainingId != null) {
      setState(() {
        _isTracking = true;
      });

      // Start background location tracking if running
      if (trainingType == 0) {
        await _locationService.initializeBackgroundService();
      }
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to start training session.'),
      ));
    }
  }

  Future<void> _stopTraining() async {
    final trainingId = await _trainingService.getTrainingId();

    if (trainingId != null) {
      // Finish the training session
      await _trainingService.finishTraining(trainingId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('active_training_id');

      setState(() {
        _isTracking = false;
      });

      // Stop background location tracking
      _locationService.stopBackgroundService();
      Navigator.pop(context);
    }
  }

  Future<void> _stopTrainingWithoutNavigate() async {
    final trainingId = await _trainingService.getTrainingId();

    if (trainingId != null) {
      // Finish the training session
      await _trainingService.finishTraining(trainingId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('active_training_id');

      setState(() {
        _isTracking = false;
      });

      // Stop background location tracking
      _locationService.stopBackgroundService();
    }
  }

  Future<void> _finishTrainingOnClose() async {
    if (_isTracking) {
      final trainingId = await _trainingService.getTrainingId();
      if (trainingId != null) {
        await _trainingService.finishTraining(trainingId);
        await _locationService.stopBackgroundService();
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('active_training_id');
      }
    }
  }

  Widget _buildSlider() {
    return Positioned(
      top: 80, // Adjust this value for positioning
      right: 20,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isRunning = !_isRunning;
          });
        },
        child: Container(
          width: 120,
          height: 60,
          decoration: BoxDecoration(
            color: Color(0xFF3477A7),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 15,
                top: 15,
                child: Icon(
                  Icons.directions_run,
                  color: _isRunning ? Color(0xFF3EC3FF) : Colors.white,
                  size: 32,
                ),
              ),
              Positioned(
                right: 15,
                top: 15,
                child: Icon(
                  Icons.directions_bike,
                  color: !_isRunning ? Color(0xFF3EC3FF) : Colors.white,
                  size: 32,
                ),
              ),
              AnimatedPositioned(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                left: _isRunning ? 0 : 60,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      _isRunning ? Icons.directions_run : Icons.directions_bike,
                      color: Color(0xFF3477A7),
                      size: 32,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartStopButton() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Center(
        child: OutlinedButton(
          onPressed: _isTracking ? _stopTraining : _startTraining,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Color(0xFF3477A7)),
            backgroundColor: Colors.white,
            minimumSize: Size(150, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            _isTracking ? S.of(context).stop : S.of(context).start,
            style: TextStyle(
              color: Color(0xFF3477A7),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Use FutureBuilder to react to location changes
  Widget _buildMap() {
    return FutureBuilder<LatLng?>(
      future:
          _currentPosition, // The async function to fetch the current position
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While waiting for the current location, show a loader
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // If there's an error fetching the location
          return Center(
            child: Text('Error loading location: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          // If no data is returned (e.g., location permission denied)
          return Center(child: Text('No location data available'));
        } else {
          // If the location is fetched successfully
          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: snapshot.data,
              zoom: 16.0,
              interactiveFlags: InteractiveFlag.all,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
                errorTileCallback: (tile, error) {
                  print('Error loading tile: $tile');
                },
              ),
              if (_route.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _route, // Render route from cache
                      strokeWidth: 4.0,
                      color: Color(0xFF3477A7),
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: snapshot.data!,
                    width: 40, // Match the size of the icon
                    height: 40,
                    anchorPos: AnchorPos.align(
                        AnchorAlign.top), // Centered anchor position
                    builder: (ctx) => Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: !_isTracking,
        onPopInvoked: (didPop) async {
          if (didPop) {
            return;
          }

          final shouldExit = await _showExitWarningDialog();
          if (shouldExit) {
            await _stopTrainingWithoutNavigate();
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              _buildMap(),
              _buildSlider(),
              _buildStartStopButton(),
            ],
          ),
        ));
  }
}
