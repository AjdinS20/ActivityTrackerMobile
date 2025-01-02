import 'dart:ui';
import 'package:activity_tracker/generated/l10n.dart';
import 'package:activity_tracker/pages/training_details_page.dart';
import 'package:flutter/material.dart';
import 'package:activity_tracker/models/training_detail_dto.dart';
import 'package:activity_tracker/services/training_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

class ActivitiesPage extends StatefulWidget {
  @override
  _ActivitiesPageState createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  final TrainingService _trainingService = TrainingService();

  final int _pageSize = 10;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  List<TrainingDetailDto> _allTrainings = [];
  List<TrainingDetailDto> _displayedTrainings = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initTrainings();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _initTrainings() async {
    List<TrainingDetailDto>? allTrainings =
        await _trainingService.getAllTrainings();
    if (allTrainings == null) {
      setState(() {
        _allTrainings = [];
        _displayedTrainings = [];
        _hasMore = false;
        _isLoading = false;
      });
      return;
    }

    // Sort newest first
    allTrainings.sort((a, b) => b.id.compareTo(a.id));

    setState(() {
      _allTrainings = allTrainings;
      _displayedTrainings = allTrainings.take(_pageSize).toList();
      _hasMore = _displayedTrainings.length < _allTrainings.length;
      _isLoading = false;
    });
  }

  void _onScroll() {
    if (!_isLoadingMore &&
        _hasMore &&
        _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
      _loadMoreTrainings();
    }
  }

  Future<void> _loadMoreTrainings() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() {
      _isLoadingMore = true;
    });

    final startIndex = _displayedTrainings.length;
    final nextBatch = _allTrainings.skip(startIndex).take(_pageSize).toList();

    setState(() {
      _displayedTrainings.addAll(nextBatch);
      _hasMore = _displayedTrainings.length < _allTrainings.length;
      _isLoadingMore = false;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  String _formatDuration(Duration duration) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            S.of(context).welcomeBack,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
          ),
        ),
        SizedBox(height: 5),
        Center(
          child: Column(
            children: [
              Text(
                S.of(context).myActivities,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 4),
                height: 2,
                width: 120,
                color: Color(0xFF3477A7),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Expanded(
          child: Stack(
            children: [
              _buildListView(context),
              // Bottom blur overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.1,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.7),
                            Colors.white
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListView(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_displayedTrainings.isEmpty) {
      return Center(child: Text(S.of(context).no_trainings));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.1 + 20,
      ),
      itemCount: _displayedTrainings.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _displayedTrainings.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final training = _displayedTrainings[index];
        return _buildTrainingItem(context, training);
      },
    );
  }

  Widget _buildTrainingItem(BuildContext context, TrainingDetailDto training) {
    final height = MediaQuery.of(context).size.height * 0.30;

    // Calculate duration
    Duration trainingDuration = Duration.zero;
    if (training.points.isNotEmpty) {
      final firstPointTime = training.points.first.pointTime;
      final lastPointTime = training.points.last.pointTime;
      trainingDuration = lastPointTime.difference(firstPointTime);
    }
    String formattedDuration = _formatDuration(trainingDuration);

    // Icon based on type
    IconData typeIcon = Icons.directions_run;
    if (training.type == 1) {
      typeIcon = Icons.directions_bike;
    }

    List<LatLng> routePoints =
        training.points.map((p) => LatLng(p.latitude, p.longitude)).toList();

    // Bounds for route
    LatLngBounds? bounds;
    if (routePoints.isNotEmpty) {
      bounds = LatLngBounds();
      for (var p in routePoints) {
        bounds.extend(p);
      }
    }

    // Format the date as dd.MM.yyyy
    final formattedDate =
        DateFormat('dd.MM.yyyy').format(training.startTime.toLocal());

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Map ~60% of the item
          Expanded(
            flex: 4,
            child: ClipRRect(
              child: FlutterMap(
                options: MapOptions(
                  bounds: bounds,
                  boundsOptions: FitBoundsOptions(padding: EdgeInsets.all(30)),
                  zoom: 10,
                  center: bounds == null ? LatLng(44.1993, 17.9241) : null,
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
          ),
          // Bottom info section ~40%
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFF3477A7),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  // Column for Date/Type and Training time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: Date left, Type right
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            S.of(context).date + ": $formattedDate",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(S.of(context).type + ": ",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14)),
                              Icon(typeIcon,
                                  color: Color(0xFF3EC3FF), size: 24),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Training time below Date line
                      Text(
                        S.of(context).training_time + ": $formattedDuration",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),

                  // Three dots positioned at bottom-right
                  Positioned(
                    bottom: 8,
                    right: 15,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TrainingDetailsPage(training: training),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildDot(),
                              SizedBox(width: 4),
                              _buildDot(),
                              SizedBox(width: 4),
                              _buildDot(),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 2),
                            height: 2,
                            width: 30,
                            color: Colors.grey,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers(List<LatLng> routePoints) {
    // Blue color for location icons
    final markerColor = Color(0xFF3EC3FF);
    List<Marker> markers = [];

    if (routePoints.isNotEmpty) {
      // Add marker for the start point
      markers.add(
        Marker(
          width: 30,
          height: 30,
          point: routePoints.first,
          anchorPos: AnchorPos.align(
              AnchorAlign.top), // Aligns bottom center of marker
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
            anchorPos: AnchorPos.align(
                AnchorAlign.top), // Aligns bottom center of marker
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

  Widget _buildDot() {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}
