import 'package:flutter/material.dart';

void widgetDisplayOverlay({
  required BuildContext context,
  required GlobalKey buttonKey,
  required Widget child,
  Duration displayDuration = const Duration(seconds: 3),
  Duration fadeDuration = const Duration(milliseconds: 300),
}) {
  final OverlayState overlayState = Overlay.of(context);

  final RenderBox? renderBox = buttonKey.currentContext?.findRenderObject() as RenderBox?;
  if (renderBox == null) {
    return;
  }

  final Offset buttonOffset = renderBox.localToGlobal(Offset.zero);
  final Size buttonSize = renderBox.size;

  final AnimationController animationController = AnimationController(
    vsync: Navigator.of(context),
    duration: fadeDuration,
  );

  final CurvedAnimation curvedAnimation = CurvedAnimation(parent: animationController, curve: Curves.easeInOut);

  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (BuildContext context) {
      return Positioned(
        right: 0,
        top: buttonOffset.dy - buttonSize.height - 10,
        child: Material(
          color: Colors.transparent,
          child: FadeTransition(opacity: curvedAnimation, child: child),
        ),
      );
    },
  );

  overlayState.insert(overlayEntry);
  animationController.forward();

  // ignore: always_specify_types
  Future.delayed(displayDuration, () async {
    await animationController.reverse();
    overlayEntry.remove();
    animationController.dispose();
  });
}
