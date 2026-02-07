import 'package:flutter/material.dart';

import '../../models/analytics/kpi_item.dart';
import 'kpi_display.dart';

class KPISection extends StatelessWidget {
  final List<KPIItem> items;

  const KPISection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items.map((item) => SizedBox(width: 220, child: KPIDisplay(item: item))).toList()
      ),
    );
  }
}
