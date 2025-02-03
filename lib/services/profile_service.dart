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

  static Future<Map<String, dynamic>?> deleteUserProfile() async {
    final dio = DioService.getDio();
    try {
      Response response = await dio.post('/api/User/delete');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        print('Failed to delete profile: ${response.statusMessage}');
        return null;
      }
    } catch (e) {
      print('Error deleting profile: $e');
      return null;
    }
  }
}
