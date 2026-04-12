import 'package:flutter/material.dart';
import '../theme.dart';

enum RiskLevel {
  low,
  moderate,
  high;

  Color get color {
    switch (this) {
      case RiskLevel.low:
        return AppTheme.accentSafe;
      case RiskLevel.moderate:
        return AppTheme.accentModerateRisk;
      case RiskLevel.high:
        return AppTheme.accentHighRisk;
    }
  }

  String get label {
    switch (this) {
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.moderate:
        return 'Moderate Risk';
      case RiskLevel.high:
        return 'High Risk';
    }
  }
}

class WoundData {
  final String id;
  final DateTime lastAssessed;
  final RiskLevel riskLevel;
  final double areaCm2;
  final int infectionRiskPercent;
  final int daysSinceScan;
  final List<String> tissueTypes;
  final String healingStage;

  WoundData({
    required this.id,
    required this.lastAssessed,
    required this.riskLevel,
    required this.areaCm2,
    required this.infectionRiskPercent,
    required this.daysSinceScan,
    required this.tissueTypes,
    required this.healingStage,
  });
}

// Mock Data
final WoundData currentWound = WoundData(
  id: 'WND-8492-C',
  lastAssessed: DateTime.now().subtract(const Duration(days: 2)),
  riskLevel: RiskLevel.moderate,
  areaCm2: 12.4,
  infectionRiskPercent: 34,
  daysSinceScan: 2,
  tissueTypes: ['Granulation', 'Slough'],
  healingStage: 'Proliferative',
);
