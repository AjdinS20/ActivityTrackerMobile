import 'package:activity_tracker/pages/new_training_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'activities_page.dart';
import 'stats_page.dart';
import 'profile_page.dart';
import 'package:activity_tracker/generated/l10n.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ActivitiesPage(),
    StatsPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color(0xFF3477A7),
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).padding.top + 30,
            color: Color(0xFF3477A7),
          ),
          Expanded(
            child: _pages[_currentIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Color(0xFF3477A7),
        selectedItemColor: Color(0xFF3EC3FF),
        unselectedItemColor: Colors.white,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 32,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                await _checkAndRequestLocationPermission();
              },
              icon: Icon(Icons.add, color: Colors.white),
              label: Text(
                S.of(context).startNew,
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Color(0xFF3477A7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    35), // Adjust the radius to make it rounder
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> _checkAndRequestLocationPermission() async {
    await Permission.locationWhenInUse.request();

    PermissionStatus status = await Permission.locationWhenInUse.status;

    // If permission is granted, navigate to NewTrainingPage
    if (status.isGranted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NewTrainingPage()),
      );
    } else {
      // If permission is denied, show a message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(S.of(context).start),
      ));
    }
  }

  Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }
}
