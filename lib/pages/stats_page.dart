import 'package:flutter/material.dart';
import 'package:activity_tracker/generated/l10n.dart';
import 'package:activity_tracker/services/stats_service.dart';
import 'package:flutter/services.dart';

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String _selectedTimePeriod = 'allTime';
  int _selectedTrainingType = 2;
  Map<String, dynamic>? _trainingStats;
  DateTime _startDate = DateTime(2000);
  DateTime _endDate = DateTime.now();

  final PageController _pageController = PageController(
    viewportFraction: 0.3,
    initialPage: 485,
  );

  @override
  void initState() {
    super.initState();
    _fetchTrainingStats();
  }

  String _formatValue(dynamic value, int precision) {
    if (value == null) return '0';
    if (value is num) {
      return value.abs().toStringAsFixed(precision);
    } else if (value is String) {
      // Attempt to parse the string as a number
      final parsed = value.split('.')[0]; //double.tryParse(value);
      print("VAlue is string: " + value + " " + parsed.toString());
      return parsed != null ? parsed : value;
    }
    return value.toString();
  }

  Future<void> _fetchTrainingStats() async {
    DateTime now = DateTime.now();
    switch (_selectedTimePeriod) {
      case 'lastYear':
        _startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      case 'lastMonth':
        _startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'lastWeek':
        _startDate = now.subtract(Duration(days: 7));
        break;
      default:
        _startDate = DateTime(2000);
    }

    _endDate = DateTime.now();
    final stats = await StatsService.fetchTrainingStats(
      _selectedTrainingType == 2 ? null : _selectedTrainingType,
      _startDate,
      _endDate,
    );

    if (stats != null) {
      setState(() {
        _trainingStats = stats;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color(0xFF3477A7),
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 85,
            color: Color(0xFF3477A7),
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    S.of(context).myTrainingStats,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownButton<String>(
                  dropdownColor: Color(0xFF3477A7),
                  value: _selectedTimePeriod,
                  items: [
                    {'key': 'allTime', 'label': S.of(context).allTime},
                    {'key': 'lastYear', 'label': S.of(context).lastYear},
                    {'key': 'lastMonth', 'label': S.of(context).lastMonth},
                    {'key': 'lastWeek', 'label': S.of(context).lastWeek},
                  ].map((timePeriod) {
                    return DropdownMenuItem(
                      value: timePeriod['key'],
                      child: Text(
                        timePeriod['label']!,
                        style: TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTimePeriod = value!;
                      _fetchTrainingStats();
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: PageView.builder(
              controller: _pageController,
              itemCount: 3 * 1000,
              onPageChanged: (index) {
                setState(() {
                  _selectedTrainingType = index % 3;
                  _fetchTrainingStats();
                });
              },
              itemBuilder: (context, index) {
                final labels = [
                  S.of(context).running,
                  S.of(context).cycling,
                  S.of(context).allTrainings
                ];
                final icons = [
                  Icons.directions_run,
                  Icons.directions_bike,
                  Icons.insert_chart
                ];
                bool isSelected = index % 3 == _selectedTrainingType;

                return Center(
                  child: Opacity(
                    opacity: isSelected ? 1.0 : 0.4,
                    child: Transform.scale(
                      scale: isSelected ? 1.3 : 1.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icons[index % 3],
                            size: 50,
                            color: Color(0xFF3EC3FF),
                          ),
                          if (isSelected)
                            Text(
                              labels[index % 3],
                              style: TextStyle(
                                color: Color(0xFF3EC3FF),
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          _trainingStats == null
              ? Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsRow(S.of(context).totalTimeSpent,
                          "${_formatValue(_trainingStats!['totalTimeSpent'], 2)} ${S.of(context).hours}"),
                      _buildStatsRow(S.of(context).totalDistanceCovered,
                          "${_formatValue(_trainingStats!['totalDistanceCovered'], 2)} ${S.of(context).km}"),
                      _buildStatsRow(S.of(context).totalCaloriesBurned,
                          "${_formatValue(_trainingStats!['totalCaloriesBurned'], 2)} ${S.of(context).kcal}"),
                      _buildStatsRow(S.of(context).topSpeed,
                          "${_formatValue(_trainingStats!['topSpeed'], 2)} ${S.of(context).kmPerHour}"),
                      _buildStatsRow(S.of(context).longestSession,
                          "${_formatValue(_trainingStats!['longestSession'], 2)} ${S.of(context).hours}"),
                      _buildStatsRow(S.of(context).longestRouteCovered,
                          "${_formatValue(_trainingStats!['longestRouteCovered'], 2)} ${S.of(context).km}"),
                      _buildStatsRow(S.of(context).avgTimeBetweenSessions,
                          "${_formatValue(_trainingStats!['avgTimeBetweenSessions'], 2)} ${S.of(context).days}"),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            value,
            style: TextStyle(color: Color(0xFF3477A7)),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
