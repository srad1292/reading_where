import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reading_where/enums/asset_type.dart';

class LocationExpansionTile extends StatelessWidget {
  final String title;
  final String assetPath;
  final List<Widget> children;
  final AssetType assetType;
  final bool readFrom;
  final bool hasBooks;

  const LocationExpansionTile({
    super.key,
    required this.title,
    required this.assetPath,
    required this.children,
    this.readFrom = false,
    this.hasBooks = false,
    this.assetType = AssetType.svg,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ExpansionTile(
        leading: _getLeading(),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: hasBooks ? const TextStyle(fontWeight: FontWeight.bold) : null,
              ),
            ),
            if (readFrom)
              ...[
                const SizedBox(width: 6),
                const Icon(Icons.check_circle, color: Colors.green, size: 18),
              ],
          ],
        ),
        children: children,
      ),
    );
  }

  Widget _getLeading() {
    return assetType == AssetType.svg ? _getSvgAsset() : _getImageAsset();
  }

  Widget _getSvgAsset() {
    print("Trying to get svg from path $assetPath");
    return SvgPicture.asset(
        assetPath,
        width: 44
    );
  }

  Widget _getImageAsset() {
    return Image.asset(
      assetPath,
      width: 44,
    );
  }
}
