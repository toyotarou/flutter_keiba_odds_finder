// =============================================================================
// ファイル名   : widget_display_overlay.dart
// 概要         : タップした位置（またはボタンの上）に、指定したウィジェットを短時間だけ表示する関数。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-06-29
// 最終更新日   : 2026-11-17
// =============================================================================

import 'package:flutter/material.dart';

/// [tapPosition]（タップした位置）の横、または [buttonKey] のボタンの上に、[child] を表示する。
/// [displayDuration] のあいだ表示し、フェードで消す。
void widgetDisplayOverlay({
  required BuildContext context,
  GlobalKey? buttonKey,
  Offset? tapPosition,
  required Widget child,
  Duration displayDuration = const Duration(seconds: 1),
  Duration fadeDuration = const Duration(milliseconds: 300),
}) {
  final double top;
  final double? left;
  final double? right;

  if (tapPosition != null) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isRightSide = tapPosition.dx > screenWidth / 2;
    top = tapPosition.dy - 10;
    left = isRightSide ? null : tapPosition.dx + 10;
    right = isRightSide ? screenWidth - tapPosition.dx + 10 : null;
  } else if (buttonKey != null) {
    final RenderBox? renderBox = buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return;
    }
    final Offset buttonOffset = renderBox.localToGlobal(Offset.zero);
    final Size buttonSize = renderBox.size;
    top = buttonOffset.dy - buttonSize.height - 10;
    left = null;
    right = 0;
  } else {
    return;
  }

  final AnimationController animationController = AnimationController(
    vsync: Navigator.of(context),
    duration: fadeDuration,
  );
  final CurvedAnimation curvedAnimation = CurvedAnimation(parent: animationController, curve: Curves.easeInOut);

  late OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (_) => Positioned(
      left: left,
      right: right,
      top: top,
      child: Material(
        color: Colors.transparent,
        child: FadeTransition(opacity: curvedAnimation, child: child),
      ),
    ),
  );

  Overlay.of(context).insert(overlayEntry);
  animationController.forward();

  // ignore: always_specify_types
  Future.delayed(displayDuration, () async {
    await animationController.reverse();
    overlayEntry.remove();
    animationController.dispose();
  });
}
