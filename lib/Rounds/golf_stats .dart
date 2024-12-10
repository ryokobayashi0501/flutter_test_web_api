import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_web_api/Models/Enums/BallDirection.dart';

class GolfStats extends StatelessWidget {
  final List<Map<String, dynamic>> shotData;
  final List<Map<String, dynamic>> roundHoleData;

  const GolfStats({
    Key? key,
    required this.shotData,
    required this.roundHoleData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Handle the case where no data is available
    if (shotData.isEmpty || roundHoleData.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Golf Stats'),
        ),
        body: const Center(
          child: Text("No data available for this round."),
        ),
      );
    }

    // 1. Total Score calculation
    int totalScore = roundHoleData.fold<int>(
      0,
      (sum, hole) => sum + ((hole['stroke'] ?? 0) as int),
    );


    // 2. Fairway Hit percentage calculation
    int totalFairways = roundHoleData.length;

    // fairwaysHitを計算（fairwayHitがtrue、またはone onを考慮）
    int fairwaysHit = roundHoleData.where((hole) {
      if (hole['fairwayHit'] == true) {
        return true;
      }
      // "one on"を考慮（par4またはpar5かつグリーンオンの場合）
      if (hole['fairwayHit'] == null && 
          hole['par'] != null && 
          hole['par'] >= 4 && 
          hole['greenInRegulation'] == true) {
        return true;
      }
      return false;
    }).length;

    // フェアウェイ率を計算
    double fairwayHitRate = totalFairways > 0 ? (fairwaysHit / totalFairways) * 100 : 0.0;


    // 3. Greens in Regulation percentage calculation
    int totalGreens = roundHoleData.length;
    int greensInRegulation = roundHoleData.where((hole) => hole['greenInRegulation'] == true).length;
    double greenInRegulationRate =
        totalGreens > 0 ? (greensInRegulation / totalGreens) * 100 : 0.0;

    // 4. Shot directions distribution
    // Shot directions distribution
    // Shot directions distribution
    Map<String, int> shotDirections = {
      'Straight': 0,
      'Left': 0,
      'Right': 0,
    };

    for (var shot in shotData) {
      String? directionString = shot['ballDirection'] as String?;
      if (directionString != null) {
        // Convert string to BallDirection enum
        BallDirection? direction = BallDirection.values.firstWhere(
          (e) => e.toString().split('.').last == directionString,
          orElse: () => BallDirection.Fairway, // Handle invalid values gracefully
        );

        if (direction != null) {
          if ([
            BallDirection.RightRough,
            BallDirection.RightTrees,
            BallDirection.WaterHazardRight,
            BallDirection.SandBunkerRight,
            BallDirection.RightOB,
          ].contains(direction)) {
            shotDirections['Right'] = (shotDirections['Right'] ?? 0) + 1;
          } else if ([
            BallDirection.LeftRough,
            BallDirection.LeftTrees,
            BallDirection.LeftOB,
            BallDirection.WaterHazardLeft,
            BallDirection.SandBunkerLeft,
          ].contains(direction)) {
            shotDirections['Left'] = (shotDirections['Left'] ?? 0) + 1;
          } else if ([
            BallDirection.Fairway,
            BallDirection.Green,
            BallDirection.Fringe,
          ].contains(direction)) {
            shotDirections['Straight'] = (shotDirections['Straight'] ?? 0) + 1;
          } else {
            print("Warning: Unhandled direction: $direction"); // デバッグ用
          }
        }
      }
    }



    // Prepare pie chart data
    List<PieChartSectionData> pieChartSections = [
      PieChartSectionData(
        value: shotDirections['Straight']?.toDouble() ?? 0,
        title: 'Straight',
        color: Colors.green,
      ),
      PieChartSectionData(
        value: shotDirections['Left']?.toDouble() ?? 0,
        title: 'Left',
        color: Colors.red,
      ),
      PieChartSectionData(
        value: shotDirections['Right']?.toDouble() ?? 0,
        title: 'Right',
        color: Colors.blue,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Golf Stats'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Total Score
            _buildStatRow('Total Score', totalScore.toString()),

            // Fairway Hit Percentage
            _buildStatRow('Fairway Hit %', '${fairwayHitRate.toStringAsFixed(1)}%'),

            // Green in Regulation Percentage
            _buildStatRow('Green in Regulation %', '${greenInRegulationRate.toStringAsFixed(1)}%'),

            const SizedBox(height: 20),

            // Pie Chart Section
            const Text(
              'Shot Directions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: pieChartSections,
                  centerSpaceRadius: 40,
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for displaying statistics rows
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
