import 'package:flutter/material.dart';
import 'package:reading_where/models/analytics/kpi_item.dart';

class KPIDisplay extends StatelessWidget {
  final KPIItem item;
  const KPIDisplay({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    String? doubleFixed;
    if(item.doubleValue != null) {
      doubleFixed = item.doubleValue!.toStringAsFixed(2);
    }
    return Container(
      color: Colors.white,
      //width: 200,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
      child: Column(
        children: [
          Text(item.label),
          Text(
            "${item.intValue ?? doubleFixed ?? "-"}",
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 36
            ),
          ),
        ],
      ),
    );
  }
}
