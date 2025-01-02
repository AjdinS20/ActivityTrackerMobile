class TrainingDetailDto {
  final int id;
  final DateTime startTime;
  final DateTime? endTime;
  final int type;
  final double totalTime;
  final double topSpeed;
  final double averageSpeed;
  final double distanceCovered;
  final double caloriesBurned;
  final List<TrainingPointDto> points;

  TrainingDetailDto({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.type,
    required this.totalTime,
    required this.topSpeed,
    required this.averageSpeed,
    required this.distanceCovered,
    required this.caloriesBurned,
    required this.points,
  });

  factory TrainingDetailDto.fromJson(Map<String, dynamic> json) {
    var pointsList = json['points'] as List;
    List<TrainingPointDto> points =
        pointsList.map((point) => TrainingPointDto.fromJson(point)).toList();

    return TrainingDetailDto(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      type: json['type'],
      totalTime: (json['totalTime'] == null)
          ? 0.0
          : (json['totalTime'] as num).toDouble(),
      topSpeed: (json['topSpeed'] == null)
          ? 0.0
          : (json['topSpeed'] as num).toDouble(),
      averageSpeed: (json['averageSpeed'] == null)
          ? 0.0
          : (json['averageSpeed'] as num).toDouble(),
      distanceCovered: (json['distanceCovered'] == null)
          ? 0.0
          : (json['distanceCovered'] as num).toDouble(),
      caloriesBurned: (json['caloriesBurned'] == null)
          ? 0.0
          : (json['caloriesBurned'] as num).toDouble(),
      points: points,
    );
  }
}

class TrainingPointDto {
  final double latitude;
  final double longitude;
  final DateTime pointTime;

  TrainingPointDto({
    required this.latitude,
    required this.longitude,
    required this.pointTime,
  });

  factory TrainingPointDto.fromJson(Map<String, dynamic> json) {
    return TrainingPointDto(
      latitude: (json['latitude'] as num).toDouble(), // Convert to double
      longitude: (json['longitude'] as num).toDouble(), // Convert to double
      pointTime: DateTime.parse(json['pointTime']),
    );
  }
}
