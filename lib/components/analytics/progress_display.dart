import 'package:flutter/material.dart';
import 'package:reading_where/models/analytics/kpi_location.dart';

class ProgressDisplay extends StatefulWidget {
  final double percentage;
  final String label;
  const ProgressDisplay({super.key, required this.label, this.percentage=0});

  @override
  State<ProgressDisplay> createState() => _ProgressDisplayState();
}

class _ProgressDisplayState extends State<ProgressDisplay> {
  @override
  Widget build(BuildContext context) {
    Color barColor = Colors.green;
    if(widget.percentage < 0.25) {
      barColor = Colors.red;
    } else if(widget.percentage < 0.50) {
      barColor = Colors.orange;
    } else if(widget.percentage < 0.75) {
      barColor = Colors.yellow;
    } else if(widget.percentage < 0.9999) {
      barColor = Colors.lime;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8),
      child: Column(
        children: [
          Text(widget.label),
          LinearProgressIndicator(
            value: widget.percentage,
            minHeight: 14,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(barColor),
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }
}
