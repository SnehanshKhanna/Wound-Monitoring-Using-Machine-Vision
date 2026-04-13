import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';
import '../providers/profile_provider.dart';

class ReportsTab extends ConsumerWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Detailed Scan Reports')),
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

                List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No historical reports available.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;
                    return _buildReportCard(data, docId);
                  },
                );
              },
            ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> data, String docId) {
    final DateTime dt = data['timestamp'] is Timestamp 
        ? (data['timestamp'] as Timestamp).toDate() 
        : DateTime.parse(data['timestamp'].toString());
    final dateStr =
        '${dt.month}/${dt.day}/${dt.year} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (data['imageUrl'] != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.network(
                data['imageUrl'],
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: AppTheme.background,
                  child: const Center(
                    child: Icon(CupertinoIcons.exclamationmark_triangle),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Scan-ID: WND-${docId.substring(0, 4)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white12),
                const SizedBox(height: 16),

                // Display Parameters
                _buildParameterRow(
                  'Wound Area:',
                  '${(data['area'] ?? 0).toStringAsFixed(1)} px',
                ),
                _buildParameterRow(
                  'Redness (HSV):',
                  '${(data['redness'] ?? 0).toStringAsFixed(1)}',
                ),
                _buildParameterRow(
                  'Computed Risk Level:',
                  '${data['risk_level'] ?? 'N/A'}',
                ),
                _buildParameterRow(
                  'Healing Score:',
                  '${(data['healing_score'] ?? 0).toStringAsFixed(1)} / 100',
                ),
                _buildParameterRow(
                  'Versus Prev. Trend:',
                  '${data['healing_trend'] ?? 'N/A'}',
                ),

                const SizedBox(height: 16),
                // Text(
                //   'Hosted Diagnostics URL:',
                //   style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.7), fontSize: 11),
                // ),
                // Text(
                //   data['imageUrl'] ?? 'No Image Hosted',
                //   style: const TextStyle(
                //     color: Colors.blueAccent,
                //     fontSize: 11,
                //   ),
                //   maxLines: 1,
                //   overflow: TextOverflow.ellipsis,
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
