import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'theme.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnalyticsScreen extends StatefulWidget {
  final String language;
  const AnalyticsScreen({super.key, required this.language});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {

  bool get isHindi => widget.language == "हिंदी" || widget.language == "Hindi";
  bool get isMarathi => widget.language == "मराठी" || widget.language == "Marathi";
  bool get isDemoUser => FirebaseAuth.instance.currentUser?.email == 'demo@swasthyogi.app';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isMarathi ? "विश्लेषण" : (isHindi ? "एनालिटिक्स" : "Analytics")),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChartCard("Wellness Trends (Weekly)", isDemoUser ? _buildLineChart(AppTheme.medicalBlue) : _buildEmptyState("Log health data to see trends")),
            const SizedBox(height: 20),
            _buildChartCard("Incident Frequency", isDemoUser ? _buildBarChart(Colors.red) : _buildEmptyState("No incidents logged yet")),
            const SizedBox(height: 20),
            _buildChartCard("Severity Breakdown", isDemoUser ? _buildPieChart() : _buildEmptyState("N/A")),
            const SizedBox(height: 24),
            _buildInsightsCard(),
          ],
        ),
      ),
    );
  }
  Widget _buildChartCard(String title, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(height: 200, child: chart),
        ],
      ),
    );
  }

  Widget _buildLineChart(Color color) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 3), FlSpot(1, 4), FlSpot(2, 3.5), 
              FlSpot(3, 5), FlSpot(4, 4.5), FlSpot(5, 6), FlSpot(6, 5.5),
            ],
            isCurved: true,
            color: color,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(Color color) {
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: color, width: 16, borderRadius: BorderRadius.circular(4))]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: color, width: 16, borderRadius: BorderRadius.circular(4))]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 14, color: color, width: 16, borderRadius: BorderRadius.circular(4))]),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 15, color: color, width: 16, borderRadius: BorderRadius.circular(4))]),
          BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 13, color: color, width: 16, borderRadius: BorderRadius.circular(4))]),
          BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 10, color: color, width: 16, borderRadius: BorderRadius.circular(4))]),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(color: Colors.red, value: 40, title: 'Critical', radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(color: Colors.orange, value: 30, title: 'Urgent', radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(color: Colors.blue, value: 30, title: 'Minor', radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildInsightsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.accentCyan.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentCyan.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppTheme.accentCyan),
              SizedBox(width: 8),
              Text(
                "Key Insights",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isDemoUser
                ? "Stress levels correlate with lower sleep duration. Your mood has improved by 20% compared to last week.\n\nCritical incidents peaked on Tuesday. Average response time has decreased by 15% this week."
                : "Complete your daily check-ins and log emergency incidents to see AI-powered health insights here.",
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.query_stats, color: Colors.grey.withOpacity(0.5), size: 40),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: Colors.grey.withOpacity(0.8), fontSize: 12)),
        ],
      ),
    );
  }
}
