import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_flutter/core/theme/theme_controller.dart';
import 'package:app_flutter/domain/coordinate_transformer.dart';

class CoordinateDisplay extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double height;
  final String inputDatum;
  final BorderRadiusGeometry cardBorderRadius;
  final EdgeInsetsGeometry sectionPadding;
  final double gapSize;
  final BorderRadius inputBorderRadius;

  const CoordinateDisplay({
    super.key,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.height = 0.0,
    this.inputDatum = DatumRegistry.wgs84,
    this.cardBorderRadius = const BorderRadius.all(Radius.circular(12.0)),
    this.sectionPadding = const EdgeInsets.all(20.0),
    this.gapSize = 8.0,
    this.inputBorderRadius = const BorderRadius.all(Radius.circular(6.0)),
  });

  @override
  State<CoordinateDisplay> createState() => _CoordinateDisplayState();
}

class _CoordinateDisplayState extends State<CoordinateDisplay> {
  String _displayDatum = DatumRegistry.wgs84;
  double? _prevLat;
  double? _prevLon;
  double? _prevHeight;
  String? _prevInputDatum;
  String? _prevDisplayDatum;
  List<double>? _cachedResult;

  static const List<String> _datums = [
    DatumRegistry.wgs84,
    DatumRegistry.nad83,
    DatumRegistry.etrs89,
    DatumRegistry.jgd2011,
    DatumRegistry.cgcs2000,
  ];

  static const Map<String, String> _datumLabels = {
    DatumRegistry.wgs84: 'WGS-84',
    DatumRegistry.nad83: 'NAD83',
    DatumRegistry.etrs89: 'ETRS89',
    DatumRegistry.jgd2011: 'JGD2011',
    DatumRegistry.cgcs2000: 'CGCS2000',
  };

  List<double> _transform() {
    if (widget.inputDatum == _displayDatum) {
      return [widget.latitude, widget.longitude, widget.height];
    }
    try {
      return CoordinateTransformer.transform(
        widget.inputDatum,
        _displayDatum,
        widget.latitude,
        widget.longitude,
        widget.height,
      );
    } catch (_) {
      return [widget.latitude, widget.longitude, widget.height];
    }
  }

  List<double> _displayCoordinates() {
    if (_prevLat == widget.latitude &&
        _prevLon == widget.longitude &&
        _prevHeight == widget.height &&
        _prevInputDatum == widget.inputDatum &&
        _prevDisplayDatum == _displayDatum &&
        _cachedResult != null) {
      return _cachedResult!;
    }
    _prevLat = widget.latitude;
    _prevLon = widget.longitude;
    _prevHeight = widget.height;
    _prevInputDatum = widget.inputDatum;
    _prevDisplayDatum = _displayDatum;
    _cachedResult = _transform();
    return _cachedResult!;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final panelOpacity = context.watch<ThemeController>().panelOpacity;
    final brandPrimary = cs.primary;
    final surfaceFill = cs.surfaceContainerHighest.withOpacity(panelOpacity);

    final coords = _displayCoordinates();
    final displayLat = coords[0];
    final displayLon = coords[1];
    final displayHeight = coords[2];

    return Container(
      padding: widget.sectionPadding,
      decoration: BoxDecoration(
        color: surfaceFill,
        borderRadius: widget.cardBorderRadius,
        border: Border.all(
          color: brandPrimary,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: brandPrimary.withValues(alpha: 0.1),
            blurRadius: 24.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Coordinates',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(
                    color: cs.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'Active Reference',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
          SizedBox(height: widget.gapSize + 4),
          Text(
            'Datum',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          SizedBox(height: widget.gapSize),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: _displayDatum,
            dropdownColor: cs.surfaceContainerHighest.withOpacity(panelOpacity),
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              filled: true,
              fillColor: cs.surface.withOpacity(panelOpacity),
              enabledBorder: OutlineInputBorder(
                borderRadius: widget.inputBorderRadius,
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: widget.inputBorderRadius,
                borderSide: BorderSide(color: brandPrimary, width: 1.5),
              ),
            ),
            items: _datums.map((datum) {
              return DropdownMenuItem<String>(
                value: datum,
                child: Text(_datumLabels[datum] ?? datum),
              );
            }).toList(),
            onChanged: (String? val) {
              if (val != null && val != _displayDatum) {
                setState(() {
                  _displayDatum = val;
                });
              }
            },
          ),
          SizedBox(height: widget.gapSize + 4),
          _buildCoordinateRow(context, 'Latitude', displayLat.toStringAsFixed(4), panelOpacity),
          SizedBox(height: widget.gapSize),
          _buildCoordinateRow(context, 'Longitude', displayLon.toStringAsFixed(4), panelOpacity),
          SizedBox(height: widget.gapSize),
          _buildCoordinateRow(context, 'Height', '${displayHeight.toStringAsFixed(2)} m', panelOpacity),
        ],
      ),
    );
  }

  Widget _buildCoordinateRow(BuildContext context, String label, String value, double panelOpacity) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(panelOpacity),
        borderRadius: widget.inputBorderRadius,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
