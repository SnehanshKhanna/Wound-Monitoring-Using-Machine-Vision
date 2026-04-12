import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme.dart';

class PipelineStepper extends StatelessWidget {
  final int currentStep;
  final List<String> steps = const [
    'Preprocess',
    'Segment',
    'Extract',
    'Classify',
    'Assess'
  ];

  const PipelineStepper({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(steps.length, (index) {
          final isCompleted = index < currentStep;
          final isActive = index == currentStep;
          
          return Expanded(
            child: Row(
              children: [
                _buildStepCircle(isCompleted, isActive, index),
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted ? AppTheme.accentSafe : AppTheme.surfaceLight,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepCircle(bool isCompleted, bool isActive, int index) {
    Color color;
    if (isCompleted) {
      color = AppTheme.accentSafe;
    } else if (isActive) {
      color = AppTheme.primaryBlue;
    } else {
      color = AppTheme.surfaceLight;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? color.withOpacity(0.2) : color,
            border: Border.all(
              color: color,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(CupertinoIcons.checkmark_alt, size: 16, color: Colors.white)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isActive ? color : Colors.white54,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          steps[index],
          style: TextStyle(
            color: isCompleted || isActive ? Colors.white : Colors.white54,
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
