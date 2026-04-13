import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';
import '../models/wound_data.dart';
import '../widgets/risk_badge.dart';
import '../providers/profile_provider.dart';

class ProgressTab extends ConsumerWidget {
  const ProgressTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Healing Progress'),
        actions: [
          TextButton(
            onPressed: () {},
            child: Row(
              children: [
                Text(user?.name ?? 'Loading...', style: const TextStyle(color: Colors.white)),
                const SizedBox(width: 4),
                const Icon(CupertinoIcons.person_circle, size: 20, color: Colors.white),
              ],
            ),
          )
        ],
      ),
      body: user == null 
        ? const Center(child: CircularProgressIndicator())
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.id)
                .collection('history')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final docs = snapshot.data?.docs ?? [];
              
              if (docs.isEmpty) {
                return const Center(
                  child: Text('No history found. Upload images to start tracking!', 
                    style: TextStyle(color: AppTheme.textSecondary)
                  )
                );
              }

              // Build chart data
              List<FlSpot> areaSpots = [];
              for (int i = 0; i < docs.length && i < 5; i++) {
                final data = docs[i].data() as Map<String, dynamic>;
                double area = (data['area'] ?? 0).toDouble();
                // Map backwards because docs are descending order
                areaSpots.add(FlSpot((docs.length > 5 ? 4 : docs.length - 1) - i.toDouble(), area));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Wound Area Trend',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildLineChart(areaSpots),
                    const SizedBox(height: 40),
                    const Text(
                      'Session History',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ...docs.map((doc) => _buildSessionTile(doc.data() as Map<String, dynamic>)),
                    const SizedBox(height: 80),
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _buildLineChart(List<FlSpot> spots) {
    if (spots.isEmpty) return const SizedBox();
    
    // Sort spots by x value
    spots.sort((a, b) => a.x.compareTo(b.x));

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
                  return Text('${value.toInt()}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('T${value.toInt()}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
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

  Widget _buildSessionTile(Map<String, dynamic> data) {
    final DateTime dt = data['timestamp'] is Timestamp 
        ? (data['timestamp'] as Timestamp).toDate() 
        : DateTime.parse(data['timestamp'].toString());
    final dateStr = '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    
    RiskLevel risk = RiskLevel.low;
    if (data['risk_level'] != null) {
      if (data['risk_level'].toString().toLowerCase().contains('high')) risk = RiskLevel.high;
      if (data['risk_level'].toString().toLowerCase().contains('moderate')) risk = RiskLevel.moderate;
    }

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
            image: data['imageUrl'] != null 
              ? DecorationImage(image: NetworkImage(data['imageUrl']), fit: BoxFit.cover)
              : null,
          ),
          child: data['imageUrl'] == null 
            ? const Icon(CupertinoIcons.photo, color: AppTheme.textSecondary)
            : null,
        ),
        title: Text(dateStr, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: Text('Area: ${data['area'] ?? 0} px', style: const TextStyle(color: AppTheme.textSecondary)),
        trailing: RiskBadge(riskLevel: risk),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatColumn('Area', '${(data['area'] ?? 0).toStringAsFixed(0)} px'),
                _buildStatColumn('Red.', '${(data['redness'] ?? 0).toStringAsFixed(0)}'),
                _buildStatColumn('Score', '${(data['healing_score'] ?? 0).toStringAsFixed(1)}'),
                _buildStatColumn('Trend', '${data['healing_trend'] ?? 'N/A'}'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}
