import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme.dart';
import '../models/wound_data.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/wound_summary_card.dart';
import '../widgets/metric_card.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Good Morning,',
        subtitle: 'Sarah Jenkins',
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WoundSummaryCard(wound: currentWound),
                  const SizedBox(height: 32),
                  Text(
                    'Quick Stats',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        MetricCard(
                          title: 'Wound Area',
                          value: '${currentWound.areaCm2} cm²',
                          icon: CupertinoIcons.viewfinder_circle_fill,
                          iconColor: AppTheme.primaryBlue,
                        ),
                        MetricCard(
                          title: 'Infection Risk',
                          value: '${currentWound.infectionRiskPercent}%',
                          icon: CupertinoIcons.exclamationmark_triangle_fill,
                          iconColor: AppTheme.accentHighRisk,
                        ),
                        MetricCard(
                          title: 'Days Since Scan',
                          value: '${currentWound.daysSinceScan}',
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
                  _buildActivityList(),
                  const SizedBox(height: 80), // Padding for FAB
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // In a real app this would navigate to the Scan tab or open camera directly
        },
        icon: const Icon(CupertinoIcons.camera_viewfinder),
        label: const Text('New Scan'),
      ),
    );
  }

  Widget _buildActivityList() {
    return Column(
      children: [
        _buildActivityTile(
          icon: CupertinoIcons.doc_text_fill,
          iconColor: AppTheme.primaryBlue,
          title: 'Report Generated',
          time: 'Today, 09:41 AM',
        ),
        _buildActivityTile(
          icon: CupertinoIcons.camera_fill,
          iconColor: AppTheme.accentSafe,
          title: 'New Scan Added',
          time: 'Yesterday, 14:30 PM',
        ),
        _buildActivityTile(
          icon: CupertinoIcons.chat_bubble_2_fill,
          iconColor: AppTheme.accentModerateRisk,
          title: 'Consulted AI Assistant',
          time: '2 days ago',
        ),
      ],
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
