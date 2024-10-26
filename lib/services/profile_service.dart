import 'package:dio/dio.dart';
import 'dio_service.dart';

class ProfileService {
  static Future<Map<String, dynamic>?> fetchUserProfile() async {
    final dio = DioService.getDio();
    try {
      Response response = await dio.get('/api/User/profile');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        print('Failed to load profile: ${response.statusMessage}');
        return null;
      }
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }
}
