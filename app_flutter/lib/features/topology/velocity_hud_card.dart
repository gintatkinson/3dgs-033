import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:app_flutter/core/theme/theme_controller.dart';
import 'package:provider/provider.dart';

String _headingCompassLabel(double headingDegrees) {
  const directions = [
    'N', 'NNE', 'NE', 'ENE',
    'E', 'ESE', 'SE', 'SSE',
    'S', 'SSW', 'SW', 'WSW',
    'W', 'WNW', 'NW', 'NNW',
  ];
  final sectorSize = 360.0 / directions.length;
  final halfSector = sectorSize / 2;
  final adjusted = (headingDegrees + halfSector) % 360.0;
  final index = (adjusted / sectorSize).floor() % directions.length;
  return directions[index];
}

class VelocityHudCard extends StatelessWidget {
  final double vNorth;
  final double vEast;
  final double vUp;
  final String? timestamp;
  final String? validUntil;

  const VelocityHudCard({
    super.key,
    required this.vNorth,
    required this.vEast,
    required this.vUp,
    this.timestamp,
    this.validUntil,
  });

  double get horizontalSpeed => math.sqrt(vNorth * vNorth + vEast * vEast);

  double get headingDegrees {
    if (vNorth == 0.0 && vEast == 0.0) return 0.0;
    final deg = math.atan2(vEast, vNorth) * 180.0 / math.pi;
    return deg < 0 ? deg + 360.0 : deg;
  }

  bool get isStationary => vNorth == 0.0 && vEast == 0.0 && vUp == 0.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final panelOpacity = context.watch<ThemeController>().panelOpacity;
    final cs = theme.colorScheme;

    final speedMs = horizontalSpeed;
    final speedKmh = speedMs * 3.6;
    final hdg = headingDegrees;
    final compass = _headingCompassLabel(hdg);
    final verticalSign = vUp >= 0 ? '+' : '';

    final bool hasValidity = timestamp != null || validUntil != null;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(panelOpacity),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: cs.primary.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.08),
            blurRadius: 16.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.speed, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                'Velocity',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: isStationary
                      ? cs.tertiaryContainer.withOpacity(0.6)
                      : cs.primaryContainer.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  isStationary ? 'Stationary' : 'Moving',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isStationary ? cs.onTertiaryContainer : cs.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildMetric(
                context,
                icon: Icons.trending_flat,
                label: 'Horizontal',
                value: '${speedMs.toStringAsFixed(1)} m/s',
                subtitle: '${speedKmh.toStringAsFixed(1)} km/h',
              ),
              const Spacer(),
              _buildMetric(
                context,
                icon: Icons.explore,
                label: 'Heading',
                value: '${hdg.toStringAsFixed(1)}° ${compass}',
                subtitle: null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildMetric(
            context,
            icon: Icons.trending_up,
            label: 'Vertical',
            value: '$verticalSign${vUp.toStringAsFixed(2)} m/s',
            subtitle: null,
          ),
          if (hasValidity) ...[
            const SizedBox(height: 10),
            Divider(height: 1, color: theme.dividerColor.withOpacity(0.3)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: cs.onSurface.withOpacity(0.6)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _validityText(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withOpacity(0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetric(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: theme.colorScheme.primary.withOpacity(0.7)),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
      ],
    );
  }

  String _validityText() {
    final buffer = StringBuffer();
    if (timestamp != null) {
      buffer.write('Timestamp: $timestamp');
    }
    if (timestamp != null && validUntil != null) {
      buffer.write('  |  ');
    }
    if (validUntil != null) {
      buffer.write('Valid Until: $validUntil');
    }
    return buffer.toString();
  }
}
