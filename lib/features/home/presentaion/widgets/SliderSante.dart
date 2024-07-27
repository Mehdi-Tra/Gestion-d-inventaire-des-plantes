import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class SliderSante extends StatefulWidget {
  final double value;
  final Function(double) onchange;
  const SliderSante({required this.value, required this.onchange ,super.key});

  @override
  State<SliderSante> createState() => _SliderSanteState();
}

class _SliderSanteState extends State<SliderSante> {
  
  double? newValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Sante",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(
              alignment: Alignment.center,
              child: SfSlider(
                min: 0.0,
                max: 100.0,
                value: widget.value,
                interval: 25,
                showTicks: true,
                showLabels: true,
                activeColor: _getSliderColor(widget.value),
                inactiveColor: _getSliderColor(widget.value).withOpacity(0.4),
                onChanged: (dynamic newValue) {
                  setState(() {
                    newValue = _roundToNearest(newValue);
                    widget.onchange(newValue);
                    log("${newValue}");
                  });
                },
                labelFormatterCallback:
                    (dynamic actualValue, String formattedText) {
                  return _getHealthStatus(actualValue);
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Color _getSliderColor(double value) {
    if (value == 0) {
      return Colors.red;
    } else if (value == 25) {
      return Colors.yellow;
    } else if (value == 75) {
      return Colors.orange;
    } else if (value == 100) {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }

  String _getHealthStatus(double value) {
    if (value == 0) {
      return 'Grand danger';
    } else if (value == 25) {
      return 'Mauvaise';
    } else if (value == 75) {
      return 'Moyenne';
    } else if (value == 100) {
      return 'Bonne';
    } else {
      return "";
    }
  }

  double _roundToNearest(double value) {
    const step = 25;
    return (value / step).round() * step.toDouble();
  }
  
}
