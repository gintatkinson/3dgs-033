import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_flutter/features/topology/frame_health_notifier.dart';

class FrameHealthIndicator extends StatelessWidget {
  const FrameHealthIndicator({super.key});

  Color _dotColor(FrameStatus status, ColorScheme cs) {
    switch (status) {
      case FrameStatus.healthy:
        return const Color(0xFF4CAF50);
      case FrameStatus.degraded:
        return const Color(0xFFFFEB3B);
      case FrameStatus.poor:
        return const Color(0xFFF44336);
    }
  }

  String _label(FrameStatus status) {
    switch (status) {
      case FrameStatus.healthy:
        return 'Healthy';
      case FrameStatus.degraded:
        return 'Degraded';
      case FrameStatus.poor:
        return 'Poor';
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<FrameHealthNotifier>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final status = notifier.status;
    final dotColor = _dotColor(status, cs);
    final label = _label(status);
    final pct = notifier.dropPercentage;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: dotColor.withOpacity(0.4), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10.0,
            height: 10.0,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: dotColor.withOpacity(0.5),
                  blurRadius: 6.0,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$label  ${pct.toStringAsFixed(1)}%',
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
