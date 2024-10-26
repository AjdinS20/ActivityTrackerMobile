import 'package:dio/dio.dart';
import 'dio_service.dart'; // Import the DioService
import 'package:shared_preferences/shared_preferences.dart';

class TrainingService {
  final Dio _dio = DioService.getDio();

  // Start a new training session
  Future<String?> startTraining(int type) async {
    try {
      final response = await _dio.post(
        '/api/Training',
        data: {'type': type},
      );

      if (response.statusCode == 200) {
        final trainingId = response.data['id'];
        await _saveTrainingId(trainingId);
        return trainingId;
      }
    } catch (e) {
      print('Error starting training: $e');
    }
    return null;
  }

  // Save training ID to cache
  Future<void> _saveTrainingId(String trainingId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_training_id', trainingId);
  }

  // Get training ID from cache
  Future<String?> getTrainingId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('active_training_id');
  }

  // Update training with new location data
  Future<void> updateTraining(String trainingId, double latitude,
      double longitude, DateTime pointTime) async {
    try {
      await _dio.put(
        '/api/Training/$trainingId/update',
        data: {
          'Latitude': latitude,
          'Longitude': longitude,
          'PointTime': pointTime.toIso8601String(),
        },
      );
      print('Training updated: $trainingId');
    } catch (e) {
      print('Error updating training: $e');
    }
  }

  // Finish the training session
  Future<void> finishTraining(String trainingId) async {
    try {
      final response = await _dio.put('/api/Training/$trainingId/finish');

      if (response.statusCode == 200) {
        await _clearTrainingId();
        print('Training finished: $trainingId');
      }
    } catch (e) {
      print('Error finishing training: $e');
    }
  }

  // Clear training ID from cache
  Future<void> _clearTrainingId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('active_training_id');
  }
}
