import 'package:activity_tracker/models/training_detail_dto.dart';
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
        final trainingId = response.data.toString();
        await _saveTrainingId(trainingId.toString());
        return trainingId;
      }
    } catch (e) {
      print('Error starting training: $e');
    }
    return null;
  }

  Future<TrainingDetailDto?> getTrainingDetail(String trainingId) async {
    try {
      final response = await _dio.get('/api/Training/$trainingId');

      if (response.statusCode == 200) {
        final data = response.data;
        return TrainingDetailDto.fromJson(data);
      } else {
        print(
            'Failed to load training details. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching training details: $e');
      return null;
    }
  }

  Future<List<TrainingDetailDto>?> getAllTrainings() async {
    try {
      final response = await _dio.get('/api/Training');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        List<TrainingDetailDto> trainings =
            data.map((item) => TrainingDetailDto.fromJson(item)).toList();
        return trainings;
      } else {
        print('Failed to load trainings. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching trainings: $e');
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
