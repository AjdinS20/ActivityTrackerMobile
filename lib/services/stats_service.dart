import 'package:dio/dio.dart';
import 'package:activity_tracker/services/dio_service.dart';

class StatsService {
  static Future<Map<String, dynamic>?> fetchTrainingStats(
      int? trainingType, DateTime startDate, DateTime endDate) async {
    final dio = DioService.getDio();

    try {
      Response response = await dio.get(
        '/api/Training/stats',
        queryParameters: {
          'type': trainingType, // Null for all trainings
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );
      return response.data;
    } catch (e) {
      print('Error fetching stats: $e');
      return null;
    }
  }
}
