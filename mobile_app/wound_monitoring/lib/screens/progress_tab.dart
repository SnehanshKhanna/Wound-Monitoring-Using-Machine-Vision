import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme.dart';
import '../models/wound_data.dart';
import '../widgets/risk_badge.dart';

class ProgressTab extends StatelessWidget {
  const ProgressTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Healing Progress'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Row(
              children: [
                Text('Sarah J.', style: TextStyle(color: Colors.white)),
                Icon(CupertinoIcons.chevron_down, size: 16, color: Colors.white),
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Wound Area Reduction',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Improving 📈',
                  style: TextStyle(color: AppTheme.accentSafe, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLineChart(),
            const SizedBox(height: 40),
            const Text(
              'Infection Risk Score',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildBarChart(),
            const SizedBox(height: 40),
            const Text(
              'Session History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSessionList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text('${value.toInt()} cm', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['Day 1', 'Day 3', 'Day 7', 'Day 10', 'Today'];
                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(days[value.toInt()], style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 24.5),
                FlSpot(1, 22.0),
                FlSpot(2, 18.5),
                FlSpot(3, 14.2),
                FlSpot(4, 12.4),
              ],
              isCurved: true,
              color: AppTheme.primaryBlue,
              barWidth: 4,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryBlue.withOpacity(0.3),
                    AppTheme.primaryBlue.withOpacity(0.0),
                  ],
                ),
              ),
              dotData: const FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text('${value.toInt()}%', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['D1', 'D3', 'D7', 'D10', 'Now'];
                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(days[value.toInt()], style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            _buildBarGroup(0, 85, AppTheme.accentHighRisk),
            _buildBarGroup(1, 70, AppTheme.accentHighRisk),
            _buildBarGroup(2, 55, AppTheme.accentModerateRisk),
            _buildBarGroup(3, 42, AppTheme.accentModerateRisk),
            _buildBarGroup(4, 34, AppTheme.accentSafe),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildSessionList() {
    return Column(
      children: [
        _buildSessionTile('Today, 10:45 AM', '12.4 cm²', RiskLevel.moderate),
        _buildSessionTile('May 14, 09:30 AM', '14.2 cm²', RiskLevel.moderate),
        _buildSessionTile('May 11, 14:15 PM', '18.5 cm²', RiskLevel.high),
        _buildSessionTile('May 7, 11:00 AM', '22.0 cm²', RiskLevel.high),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSessionTile(String date, String area, RiskLevel risk) {
    return Theme(
      data: ThemeData.dark().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(CupertinoIcons.photo, color: AppTheme.textSecondary),
        ),
        title: Text(date, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: Text('Area: $area', style: const TextStyle(color: AppTheme.textSecondary)),
        trailing: RiskBadge(riskLevel: risk),
        children: const [
          Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Notes: Improved granulation. Decreased slough tissue. Patient reported less pain during dressing change.',
              style: TextStyle(color: Colors.white70),
            ),
          )
        ],
      ),
    );
  }
}
