import 'package:flutter/material.dart';

import '../../models/analytics/kpi_item.dart';
import 'kpi_display.dart';

class KPISection extends StatelessWidget {
  final List<KPIItem> items;

  const KPISection({super.key, required this.items});

  // @override
  // Widget build(BuildContext context) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 14),
  //     child: Wrap(
  //         spacing: 12,
  //         runSpacing: 12,
  //         children: items.map((item) => SizedBox(width: 220, child: KPIDisplay(item: item))).toList()
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // How many items per row?
          final double maxWidth = constraints.maxWidth;

          // Desired card width
          const double cardWidth = 220;

          // If two cards fit with spacing, use 2. Otherwise use 1.
          final bool twoPerRow = maxWidth >= (cardWidth * 2 + 12);

          final double actualWidth = twoPerRow
              ? (maxWidth - 12) / 2
              : maxWidth;

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: items
                .map((item) => SizedBox(
              width: actualWidth,
              child: KPIDisplay(item: item),
            ))
                .toList(),
          );
        },
      ),
    );
  }

}
