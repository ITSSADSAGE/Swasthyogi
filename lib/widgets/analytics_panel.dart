import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme.dart';
import '../analytics_screen.dart';

class AnalyticsPanel extends StatelessWidget {
  final String language;

  const AnalyticsPanel({
    super.key,
    required this.language,
  });

  bool get isHindi => language == "हिंदी" || language == "Hindi";
  bool get isMarathi => language == "मराठी" || language == "Marathi";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.analytics_outlined, color: AppTheme.primaryGreen, size: 20),
                const SizedBox(width: 8),
                Text(
                  isMarathi ? "माझे विश्लेषण" : (isHindi ? "विश्लेषण" : "My Analytics"),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AnalyticsScreen(language: language))),
              child: Text(isMarathi ? "तपशील >" : (isHindi ? "विवरण >" : "Details >"), style: const TextStyle(color: AppTheme.primaryGreen)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Wellness Overview", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              SizedBox(
                height: 120,
                child: _buildWellnessChart(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWellnessChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [FlSpot(0, 3), FlSpot(1, 4), FlSpot(2, 3.5), FlSpot(3, 5), FlSpot(4, 4.5), FlSpot(5, 6)],
            isCurved: true,
            color: AppTheme.medicalBlue,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: AppTheme.primaryGreen.withOpacity(0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyChart() {
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: Colors.red, width: 12)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: Colors.red, width: 12)]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 14, color: Colors.red, width: 12)]),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 15, color: Colors.red, width: 12)]),
          BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 13, color: Colors.red, width: 12)]),
          BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 10, color: Colors.red, width: 12)]),
        ],
      ),
    );
  }
}
