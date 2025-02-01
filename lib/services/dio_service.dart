import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl:
          'https://activitytrackerapp-gxhtegd4f6cggfhb.italynorth-01.azurewebsites.net',
      connectTimeout: Duration(milliseconds: 15000),
      receiveTimeout: Duration(milliseconds: 15000),
    ),
  )..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Ensure the Authorization token is set before every request
        await _setAuthorizationHeader(options);
        print('Request[${options.method}] => URL: ${options.uri}');
        print('Headers: ${options.headers}');
        print('Data: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('Response[${response.statusCode}] => Data: ${response.data}');
        return handler.next(response);
      },
      onError: (DioError e, handler) async {
        print('Error[${e.response?.statusCode}] => Message: ${e.message}');

        // Check if error is 401 (Unauthorized) or contains token expiration message
        if (e.response?.statusCode == 401 ||
            e.message?.toLowerCase().contains('token expired') == true) {
          // Clear stored token
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('token');

          // Navigate to login screen
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }

        return handler.next(e);
      },
    ));

  static Dio getDio() {
    return _dio;
  }

  static Future<void> _setAuthorizationHeader(RequestOptions options) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null &&
        token.isNotEmpty &&
        !options.path.contains('/login') &&
        !options.path.contains('/registration')) {
      options.headers['Authorization'] = 'Bearer $token';
      print('Token added to headers: $token');
    } else {
      options.headers.remove('Authorization');
      print('No Authorization header for ${options.path}');
    }
  }
}
