import 'package:activity_tracker/models/login_model.dart';
import 'package:flutter/material.dart';

import 'dio_service.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Login method
  static Future<Map<String, dynamic>?> login(
      LoginModel loginModel, BuildContext context) async {
    final dio = DioService.getDio();
    try {
      final queryParams = {
        'Email': loginModel.email,
        'Password': loginModel.password,
      };

      Response response = await dio.post(
        '/login',
        queryParameters: queryParams,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        await _saveLoginData(response.data['token'],
            response.data['refreshToken'], response.data['userRole']);
        return response.data;
      } else {
        _showLoginFailedSnackbar(context);
        return null;
      }
    } on DioException catch (e) {
      if (e.response != null) {
        _showLoginFailedSnackbar(context);
      }
      return null;
    } catch (e) {
      _showLoginFailedSnackbar(context);
      return null;
    }
  }

  static void _showLoginFailedSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login failed. Please check your credentials.')),
    );
  }

  // Registration method
  static Future<bool> register(
      Map<String, dynamic> registrationData, BuildContext context) async {
    final dio = DioService.getDio();
    try {
      Response response = await dio.post(
        '/registration',
        queryParameters: registrationData,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        print('Registration successful.');
        return true;
      } else {
        _showRegistrationFailedSnackbar(context);
        return false;
      }
    } on DioException catch (e) {
      if (e.response != null) {
        _showRegistrationFailedSnackbar(context);
      } else {
        print('Registration error: $e');
      }
      return false;
    } catch (e) {
      print('Unexpected error: $e');
      return false;
    }
  }

  static void _showRegistrationFailedSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Registration failed. Please check your details and try again.')),
    );
  }

  // Method to save login data to cache
  static Future<void> _saveLoginData(
      String token, String refreshToken, String userRole) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('refreshToken', refreshToken);
    await prefs.setString('userRole', userRole);
    print('Login data saved to cache.');
  }
}
