import 'package:activity_tracker/generated/l10n.dart';
import 'package:activity_tracker/models/training_detail_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TrainingDetailsPage extends StatelessWidget {
  final TrainingDetailDto training;

  TrainingDetailsPage({required this.training});

  String _formatDuration(Duration duration) {
    print(duration.toString());
    if (duration == Duration.zero) return "0m";
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return "${hours}h ${minutes}m";
    } else {
      return "${minutes}m";
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    // Prepare data
    final routePoints = training.points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    Duration trainingDuration = Duration.zero;
    if (training.points.isNotEmpty) {
      final firstPointTime = training.points.first.pointTime;
      final lastPointTime = training.points.last.pointTime;
      trainingDuration = lastPointTime.difference(firstPointTime);
    }
    String formattedDuration = _formatDuration(trainingDuration);
    // Determine bounds for the map
    LatLngBounds? bounds;
    if (routePoints.isNotEmpty) {
      bounds = LatLngBounds();
      for (var p in routePoints) {
        bounds.extend(p);
      }
    }

    return Scaffold(
      body: Column(
        children: [
          // Map section
          Container(
            height: height * 0.33,
            width: width,
            child: FlutterMap(
              options: MapOptions(
                bounds: bounds,
                boundsOptions: FitBoundsOptions(padding: EdgeInsets.all(30)),
                zoom: 10,
                interactiveFlags: InteractiveFlag.none,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                if (routePoints.length > 1)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        strokeWidth: 4.0,
                        color: Color(0xFF3477A7),
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: _buildMarkers(routePoints),
                ),
              ],
            ),
          ),
          // Blue bar with overview
          Container(
            height: height * 0.1,
            width: width,
            color: Color(0xFF3477A7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    S.of(context).training_overview,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Icon(
                    training.type == 1
                        ? Icons.directions_bike
                        : Icons.directions_run,
                    color: Color(0xFF3EC3FF),
                    size: 50,
                  ),
                ),
              ],
            ),
          ),
          // Details section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDetailRow(S.of(context).total_time, formattedDuration),
                  _buildDetailRow(
                      S.of(context).topSpeed, "${training.topSpeed} km/h"),
                  _buildDetailRow(S.of(context).average_speed,
                      "${training.averageSpeed.toStringAsFixed(1)} km/h"),
                  _buildDetailRow(S.of(context).distance_covered,
                      "${training.distanceCovered.toStringAsFixed(1)} km"),
                  _buildDetailRow(S.of(context).calories,
                      "${training.caloriesBurned.toStringAsFixed(0)} kcal"),
                ],
              ),
            ),
          ),
          // Back button
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                icon: Icon(Icons.chevron_left,
                    color: Color(0xFF3477A7), size: 64),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color.fromRGBO(62, 195, 225, 1)),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers(List<LatLng> routePoints) {
    final markerColor = Color(0xFF3EC3FF);
    List<Marker> markers = [];

    if (routePoints.isNotEmpty) {
      // Add marker for the start point
      markers.add(
        Marker(
          width: 30,
          height: 30,
          point: routePoints.first,
          anchorPos: AnchorPos.align(AnchorAlign.top),
          builder: (ctx) => Icon(
            Icons.location_on,
            color: markerColor,
            size: 30,
          ),
        ),
      );

      // Add marker for the end point (if there are multiple points)
      if (routePoints.length > 1) {
        markers.add(
          Marker(
            width: 30,
            height: 30,
            point: routePoints.last,
            anchorPos: AnchorPos.align(AnchorAlign.top),
            builder: (ctx) => Icon(
              Icons.location_on,
              color: markerColor,
              size: 30,
            ),
          ),
        );
      }
    }

    return markers;
  }
}
