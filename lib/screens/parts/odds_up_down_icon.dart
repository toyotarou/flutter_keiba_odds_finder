import 'package:flutter/material.dart';

/// 直前の値と比較してアップ／ダウンのアイコンを返す。
/// [current] が空 or [prev] が null/空 の場合は非表示。
/// [label] を指定するとアイコンの下に小さく表示する。
class OddsUpDownIcon extends StatelessWidget {
  const OddsUpDownIcon({super.key, required this.current, this.prev, this.label});

  final String current;
  final String? prev;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final double? cur = double.tryParse(current);
    final double? pre = double.tryParse(prev ?? '');

    if (cur == null || pre == null) {
      return const SizedBox.shrink();
    }

    final Icon icon;
    if (cur > pre) {
      icon = const Icon(Icons.arrow_upward, size: 15, color: Colors.redAccent);
    } else if (cur < pre) {
      icon = const Icon(Icons.arrow_downward, size: 15, color: Colors.greenAccent);
    } else {
      icon = const Icon(Icons.drag_handle, size: 15, color: Colors.white54);
    }

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(3)),
      child: label != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                icon,
                Text(label!, style: const TextStyle(fontSize: 8, color: Colors.white)),
              ],
            )
          : icon,
    );
  }
}
