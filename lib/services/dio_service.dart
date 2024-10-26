import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl:
          'https://activitytrackerapp-gxhtegd4f6cggfhb.italynorth-01.azurewebsites.net',
      connectTimeout: Duration(milliseconds: 6000),
      receiveTimeout: Duration(milliseconds: 6000),
    ),
  )..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Ensure the Authorization token is set before every request
        await _setAuthorizationHeader(options);
        print('Request[${options.method}] => URL: ${options.uri}');
        print('Headers: ${options.headers}');
        print('Data: ${options.data}');
        return handler.next(options); // Continue
      },
      onResponse: (response, handler) {
        print('Response[${response.statusCode}] => Data: ${response.data}');
        return handler.next(response); // Continue
      },
      onError: (DioError e, handler) {
        print('Error[${e.response?.statusCode}] => Message: ${e.message}');
        return handler.next(e); // Continue
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
