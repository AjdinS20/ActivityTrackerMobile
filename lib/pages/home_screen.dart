import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:activity_tracker/generated/l10n.dart';
import 'package:activity_tracker/pages/activities_page.dart';
import 'package:activity_tracker/pages/stats_page.dart';
import 'package:activity_tracker/pages/profile_page.dart';
import 'package:activity_tracker/pages/new_training_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isTrainingActive = false;

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
    _checkActiveTraining();
  }

  Future<void> _checkActiveTraining() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isTrainingActive = prefs.getString('active_training_id') != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top padding and possibly top bar color
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
                _isTrainingActive
                    ? S.of(context).continueButton
                    : S.of(context).startNew,
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Color(0xFF3477A7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> _checkAndRequestLocationPermission() async {
    await Permission.locationWhenInUse.request();
    PermissionStatus status = await Permission.locationWhenInUse.status;

    if (status.isGranted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NewTrainingPage()),
      ).then((value) => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(S.of(context).start),
      ));
    }
  }
}
