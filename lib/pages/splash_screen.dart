import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Import Dio
import 'package:geolocator/geolocator.dart'; // Import Geolocator
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Dio _dio = Dio(); // Initialize Dio

  @override
  void initState() {
    super.initState();
    _getCountryFromIP().then((_) => _checkUserLoggedIn());
  }

  Future<void> _getCountryFromIP() async {
    try {
      final response = await _dio.get('http://ip-api.com/json');
      if (response.statusCode == 200) {
        final country = response.data['country'];
        _setLocaleBasedOnCountry(country);
        print(response.data);
      } else {
        print('Failed to get country from IP: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error in geolocation: $e');
    }
  }

  Future<void> _setLocaleBasedOnCountry(String country) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (country == 'Bosnia and Herzegovina') {
      // Set locale to Bosnian
      await prefs.setString('locale', 'bs_BA'); // Save to cache
    } else {
      // Set locale to English
      await prefs.setString('locale', 'en_US'); // Save to cache
    }
  }

  Future<void> _checkUserLoggedIn() async {
    // Example check: replace with actual Dio request
    bool isLoggedIn = false;
    // await _mockCheckUserLoggedIn();

    if (isLoggedIn) {
      await _getUserLocation();
      _navigateToHomeScreen();
    } else {
      print("CHECKING LOGIN");
      _navigateToLoginScreen();
    }
  }

  Future<bool> _mockCheckUserLoggedIn() async {
    // Simulate a network call to check if the user is logged in
    await Future.delayed(Duration(seconds: 10)); // Simulate delay
    return false; // Replace with actual login check logic
  }

  Future<void> _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print('User location: ${position.latitude}, ${position.longitude}');
  }

  void _navigateToHomeScreen() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _navigateToLoginScreen() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/background_image.png',
              fit: BoxFit.cover,
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0xFF3477A7),
                    Color(0xFF3477A7).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          // Centered logo
          Center(
            child: Image.asset(
              'assets/logo.png',
              width: 150,
              height: 150,
            ),
          ),
        ],
      ),
    );
  }
}
