import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';
import '../models/wound_data.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/wound_summary_card.dart';
import '../widgets/metric_card.dart';
import '../providers/profile_provider.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(profileProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: _getGreeting(),
        subtitle: user?.name ?? 'Loading Profile...',
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.id)
                  .collection('history')
                  .orderBy('timestamp', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Default empty state
                WoundData latestWound = WoundData(
                  id: "NO DATA",
                  lastAssessed: DateTime.now(),
                  riskLevel: RiskLevel.low,
                  areaCm2: 0,
                  infectionRiskPercent: 0,
                  daysSinceScan: 0,
                  tissueTypes: [],
                  healingStage: 'N/A',
                );

                List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];
                
                if (docs.isNotEmpty) {
                  final data = docs.first.data() as Map<String, dynamic>;
                  final date = data['timestamp'] is Timestamp 
                      ? (data['timestamp'] as Timestamp).toDate() 
                      : DateTime.parse(data['timestamp'].toString());
                  
                  RiskLevel risk = RiskLevel.low;
                  if (data['risk_level'] != null) {
                    if (data['risk_level'].toString().toLowerCase().contains('high')) risk = RiskLevel.high;
                    if (data['risk_level'].toString().toLowerCase().contains('moderate')) risk = RiskLevel.moderate;
                  }

                  latestWound = WoundData(
                    id: "SCAN-${date.millisecondsSinceEpoch.toString().substring(8)}",
                    lastAssessed: date,
                    riskLevel: risk,
                    areaCm2: (data['area'] ?? 0).toDouble(),
                    infectionRiskPercent: (data['redness'] ?? 0).toInt(), 
                    daysSinceScan: DateTime.now().difference(date).inDays,
                    tissueTypes: [],
                    healingStage: data['healing_trend'] ?? 'N/A',
                  );
                }

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            WoundSummaryCard(wound: latestWound),
                            const SizedBox(height: 32),
                            Text(
                              'Quick Stats',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 160,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  MetricCard(
                                    title: 'Wound Area',
                                    value: '${latestWound.areaCm2.toStringAsFixed(1)} px',
                                    icon: CupertinoIcons.viewfinder_circle_fill,
                                    iconColor: AppTheme.primaryBlue,
                                  ),
                                  MetricCard(
                                    title: 'Infection Risk (Redness)',
                                    value: '${latestWound.infectionRiskPercent.toStringAsFixed(1)}',
                                    icon: CupertinoIcons.exclamationmark_triangle_fill,
                                    iconColor: AppTheme.accentHighRisk,
                                  ),
                                  MetricCard(
                                    title: 'Days Since Scan',
                                    value: '${latestWound.daysSinceScan}',
                                    icon: CupertinoIcons.time,
                                    iconColor: AppTheme.accentModerateRisk,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Recent Activity',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            _buildActivityList(docs),
                            const SizedBox(height: 80), 
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildActivityList(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text("No scans found.", style: TextStyle(color: AppTheme.textSecondary))),
      );
    }

    return Column(
      children: docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final dt = data['timestamp'] is Timestamp 
            ? (data['timestamp'] as Timestamp).toDate() 
            : DateTime.parse(data['timestamp'].toString());
        return _buildActivityTile(
          icon: CupertinoIcons.camera_fill,
          iconColor: AppTheme.accentSafe,
          title: 'Scan Logged: WND-${doc.id.substring(0,4)}',
          time: '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}',
        );
      }).toList(),
    );
  }

  Widget _buildActivityTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(CupertinoIcons.chevron_right, color: AppTheme.textSecondary, size: 16),
        ],
      ),
    );
  }
}
