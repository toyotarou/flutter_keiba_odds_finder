import 'package:flutter/material.dart';

import 'odds_finder_overlay.dart';

// 20261005: hideRaceOverlay: true で開いているダイアログの数。1以上の間、レース選択オーバーレイを隠す。
// ダイアログが重なって開いても、全部閉じるまでは戻さないように数えている。
int _raceOverlayHideCount = 0;

// ignore: non_constant_identifier_names
Future<void> OddsFinderDialog({
  required BuildContext context,
  required Widget widget,
  double paddingTop = 0,
  double paddingRight = 0,
  double paddingBottom = 0,
  double paddingLeft = 0,
  bool clearBarrierColor = false,
  bool hideRaceOverlay = false,
}) {
  // 20261005: 表示中はレース選択オーバーレイ（home_screen）を隠す
  if (hideRaceOverlay) {
    _raceOverlayHideCount++;
    raceOverlayHiddenNotifier.value = true;
  }

  // ignore: inference_failure_on_function_invocation
  return showDialog(
    context: context,
    barrierColor: clearBarrierColor ? Colors.transparent : Colors.blueGrey.withOpacity(0.3),
    builder: (_) {
      return Container(
        padding: EdgeInsets.only(top: paddingTop, right: paddingRight, bottom: paddingBottom, left: paddingLeft),
        child: Dialog(
          backgroundColor: Colors.blueGrey.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          insetPadding: const EdgeInsets.all(30),
          child: widget,
        ),
      );
    },
    // ignore: always_specify_types
  ).then((value) {
    // 20261005: 閉じたらレース選択オーバーレイを戻す（他にも隠す指定のダイアログが開いていれば戻さない）
    if (hideRaceOverlay) {
      _raceOverlayHideCount--;
      // 20261006: ドロアが開いている間は戻さない
      raceOverlayHiddenNotifier.value = _raceOverlayHideCount > 0 || raceOverlayDrawerOpen;
    }
  });
}
