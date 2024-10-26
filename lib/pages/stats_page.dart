import 'package:flutter/material.dart';
import 'package:activity_tracker/generated/l10n.dart';
import 'package:activity_tracker/services/stats_service.dart';
import 'package:flutter/services.dart';

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String _selectedTimePeriod = 'All Time';
  int _selectedTrainingType =
      2; // Set to "All" initially (2 corresponds to "All")
  Map<String, dynamic>? _trainingStats;
  DateTime _startDate = DateTime(2000);
  DateTime _endDate = DateTime.now();

  final List<String> _timePeriods = [
    'All Time',
    'Last Year',
    'Last Month',
    'Last Week'
  ];

  final List<Map<String, dynamic>> _trainingTypes = [
    {'icon': Icons.directions_run, 'label': 'Running'},
    {'icon': Icons.directions_bike, 'label': 'Cycling'},
    {'icon': Icons.insert_chart, 'label': 'All'}
  ];

  final PageController _pageController = PageController(
    viewportFraction: 0.3,
    initialPage: 485, // Start with "All" selected
  );

  @override
  void initState() {
    super.initState();

    // Fetch initial stats
    _fetchTrainingStats();

    // // Center the "All" option in the carousel after the first frame
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _pageController.animateToPage(
    //     1002, // Center the "All" option
    //     duration: Duration(milliseconds: 200),
    //     curve: Curves.easeInOut,
    //   );
    // });
  }

  Future<void> _fetchTrainingStats() async {
    DateTime now = DateTime.now();
    switch (_selectedTimePeriod) {
      case 'Last Year':
        _startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      case 'Last Month':
        _startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'Last Week':
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
          // Top blue region
          Container(
            height: 85,
            color: Color(0xFF3477A7),
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).myTrainingStats,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<String>(
                  dropdownColor: Color(0xFF3477A7),
                  value: _selectedTimePeriod,
                  items: _timePeriods
                      .map((timePeriod) => DropdownMenuItem(
                            value: timePeriod,
                            child: Text(
                              timePeriod,
                              style: TextStyle(color: Colors.white),
                            ),
                          ))
                      .toList(),
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
          // Carousel selector
          SizedBox(
            height: 120,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _trainingTypes.length * 1000,
              onPageChanged: (index) {
                setState(() {
                  _selectedTrainingType = index % _trainingTypes.length;
                  _fetchTrainingStats();
                });
              },
              itemBuilder: (context, index) {
                final item = _trainingTypes[index % _trainingTypes.length];
                bool isSelected =
                    index % _trainingTypes.length == _selectedTrainingType;

                return Center(
                  child: Opacity(
                    opacity: isSelected ? 1.0 : 0.4,
                    child: Transform.scale(
                      scale: isSelected ? 1.3 : 1.0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0), // Adjust padding
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item['icon'],
                              size: 50,
                              color: Color(0xFF3EC3FF),
                            ),
                            if (isSelected)
                              Text(
                                item['label'],
                                style: TextStyle(
                                  color: Color(0xFF3EC3FF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          // Training stats display
          _trainingStats == null
              ? Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsRow(S.of(context).numberOfTrainings,
                          _trainingStats!['numberOfTrainings'].toString()),
                      _buildStatsRow(S.of(context).totalTimeSpent,
                          _trainingStats!['totalTimeSpent'].toString()),
                      _buildStatsRow(S.of(context).totalDistanceCovered,
                          _trainingStats!['totalDistanceCovered'].toString()),
                      _buildStatsRow(S.of(context).totalCaloriesBurned,
                          _trainingStats!['totalCaloriesBurned'].toString()),
                      _buildStatsRow(S.of(context).topSpeed,
                          _trainingStats!['topSpeed'].toString()),
                      _buildStatsRow(S.of(context).longestSession,
                          _trainingStats!['longestSession'].toString()),
                      _buildStatsRow(S.of(context).longestRouteCovered,
                          _trainingStats!['longestRouteCovered'].toString()),
                      _buildStatsRow(S.of(context).avgTimeBetweenSessions,
                          _trainingStats!['avgTimeBetweenSessions'].toString()),
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
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: Color(0xFF3477A7))),
        ],
      ),
    );
  }
}
