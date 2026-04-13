import 'package:flutter/material.dart';
import '../models/wound_data.dart';
import 'package:google_fonts/google_fonts.dart';

class RiskBadge extends StatelessWidget {
  final RiskLevel riskLevel;

  const RiskBadge({super.key, required this.riskLevel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: riskLevel.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: riskLevel.color.withOpacity(0.5)),
      ),
      child: Text(
        riskLevel.label,
        style: GoogleFonts.inter(
          color: riskLevel.color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
