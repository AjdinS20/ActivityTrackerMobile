import 'package:activity_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:activity_tracker/generated/l10n.dart';
import 'package:activity_tracker/services/profile_service.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _profileData;
  String _currentLanguage = 'en'; // Default to English

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _loadCurrentLanguage();
  }

  Future<void> _fetchUserProfile() async {
    final profileData = await ProfileService.fetchUserProfile();
    if (profileData != null) {
      setState(() {
        _profileData = profileData;
      });
    }
  }

  Future<void> _loadCurrentLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? localeString = prefs.getString('locale');
    if (localeString != null) {
      setState(() {
        _currentLanguage = localeString.split('_')[0];
      });
    }
  }

  Future<void> _setLanguage(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String localeString = language == 'bs' ? 'bs_BA' : 'en_US';

    await prefs.setString('locale', localeString);

    setState(() {
      _currentLanguage = language;
    });

    // Change locale immediately and ensure correct format
    Locale newLocale =
        Locale(language == 'bs' ? 'bs' : 'en', language == 'bs' ? 'BA' : 'US');
    ActivityTrackerApp.setLocale(context, newLocale);
  }

  Future<void> _handleLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color(0xFF3477A7),
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      body: _profileData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Top blue region
                  Container(
                    height: 85,
                    color: Color(0xFF3477A7),
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      S.of(context).myProfile,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Profile Information
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildProfileRow(
                            S.of(context).email, _profileData?['email'] ?? ''),
                        SizedBox(height: 20),
                        _buildProfileRow(
                          S.of(context).currentLanguage,
                          _buildLanguageDropdown(),
                          isDropdown: true,
                        ),
                        SizedBox(height: 20),
                        _buildProfileRow(S.of(context).weight_profile,
                            _profileData?['weight'].toString() ?? ''),
                        SizedBox(height: 20),
                        _buildProfileRow(S.of(context).height_profile,
                            _profileData?['height'].toString() ?? ''),
                        SizedBox(height: 20),
                        _buildProfileRow(S.of(context).yearOfBirth_profile,
                            _profileData?['yearOfBirth'].toString() ?? ''),
                        SizedBox(height: 20),
                        _buildProfileRow(
                            S.of(context).gender_profile,
                            (_profileData?['gender'] ?? true)
                                ? S.of(context).male
                                : S.of(context).female),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  // Logout button
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: OutlinedButton(
                      onPressed: _handleLogout,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFF3477A7)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text(
                        S.of(context).logout,
                        style: TextStyle(
                          color: Color(0xFF3477A7),
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Delete account button
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle delete account
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text(
                        S.of(context).deleteAccount,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Helper method to build profile rows
  Widget _buildProfileRow(String label, dynamic value,
      {bool isDropdown = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label != null ? label : "N/A",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          if (isDropdown)
            value
          else
            Expanded(
              child: Text(
                value.toString(),
                textAlign: TextAlign.right,
                style: TextStyle(color: Color(0xFF3477A7), fontSize: 18),
              ),
            ),
        ],
      ),
    );
  }

  // Helper method to build the language dropdown
  Widget _buildLanguageDropdown() {
    return DropdownButton<String>(
      value: _currentLanguage,
      items: [
        DropdownMenuItem(
          value: 'en',
          child: Text(S.of(context).english),
        ),
        DropdownMenuItem(
          value: 'bs',
          child: Text(S.of(context).bosnian),
        ),
      ],
      onChanged: (value) {
        if (value != null) _setLanguage(value);
      },
    );
  }
}
