import 'package:flutter/material.dart';

/// 20261005: レース選択オーバーレイ（home_screen の _firstEntries）を一時的に隠したいときに true にする。
/// 払戻金ダイアログの表示中だけ true にし、閉じたら false に戻す。home_screen 側がこの値を見て外す／戻す。
final ValueNotifier<bool> raceOverlayHiddenNotifier = ValueNotifier<bool>(false);

//=======================================================//

class DraggableOverlayItem {
  DraggableOverlayItem({required this.position, required this.width, required this.height, required this.color});

  late OverlayEntry entry;

  Offset position;

  final double width;
  final double height;

  final Color color;
}

//=======================================================//

OverlayEntry createDraggableOverlayEntry({
  required BuildContext context,
  required Offset initialOffset,
  required double width,
  required double height,
  required Color color,
  required VoidCallback onRemove,
  required Widget widget,
  required ValueChanged<Offset> onPositionChanged,
  bool? fixedFlag,
  String? title,
  Color? draggingColor,
  double minY = 0,
  Color headerColor = Colors.transparent,
}) {
  final Size screenSize = MediaQuery.of(context).size;

  final DraggableOverlayItem item = DraggableOverlayItem(
    // 20261005: minY（上端の移動禁止エリア）より上に初期位置がある場合も minY に寄せる
    position: Offset(initialOffset.dx, initialOffset.dy < minY ? minY : initialOffset.dy),
    width: width,
    height: height,
    color: color,
  );

  // ドラッグ中かどうか（draggingColor 指定時の背景色切り替え用）
  bool isDragging = false;

  final OverlayEntry entry = OverlayEntry(
    builder: (BuildContext context) {
      return Positioned(
        left: item.position.dx,
        top: item.position.dy,
        child: Material(
          elevation: 8,
          // ドラッグ中で draggingColor 指定があれば、その背景色にする
          color: (isDragging && draggingColor != null) ? draggingColor : item.color,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: item.width,
            height: item.height,
            child: Column(
              children: <Widget>[
                Container(
                  color: headerColor,
                  height: 40,
                  width: double.infinity,
                  child: Listener(
                    onPointerDown: (draggingColor == null || (fixedFlag ?? false))
                        ? null
                        : (PointerDownEvent event) {
                            isDragging = true;
                            item.entry.markNeedsBuild();
                          },
                    onPointerUp: (draggingColor == null || (fixedFlag ?? false))
                        ? null
                        : (PointerUpEvent event) {
                            isDragging = false;
                            item.entry.markNeedsBuild();
                          },
                    onPointerCancel: (draggingColor == null || (fixedFlag ?? false))
                        ? null
                        : (PointerCancelEvent event) {
                            isDragging = false;
                            item.entry.markNeedsBuild();
                          },
                    // ignore: use_if_null_to_convert_nulls_to_bools
                    onPointerMove: (fixedFlag == true)
                        ? null
                        : (PointerMoveEvent event) {
                            if (event.buttons == 1) {
                              item.position += event.delta;

                              final double maxX = screenSize.width - item.width;
                              final double maxY = screenSize.height - item.height;
                              final num clampedX = item.position.dx.clamp(0, maxX);
                              // 20261005: 上端に寄せるとスマホのシステム操作に邪魔されて、
                              // 二度と動かせなくなるため、minY より上には移動させない
                              final num clampedY = item.position.dy.clamp(minY, maxY < minY ? minY : maxY);

                              item.position = Offset(
                                double.parse(clampedX.toString()),
                                double.parse(clampedY.toString()),
                              );

                              onPositionChanged(item.position);

                              item.entry.markNeedsBuild();
                            }
                          },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // ignore: use_if_null_to_convert_nulls_to_bools
                        if (fixedFlag == true)
                          const Icon(Icons.check_box_outline_blank, color: Colors.transparent)
                        else
                          const Icon(Icons.drag_indicator, color: Colors.white),
                        Expanded(
                          child: Text(
                            title ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: onRemove,
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(width: double.infinity),
                        widget,
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      );
    },
  );

  item.entry = entry;
  return entry;
}

//=======================================================//

///
void addFirstOverlay({
  required BuildContext context,
  required List<OverlayEntry> firstEntries,
  required List<OverlayEntry> secondEntries,
  required void Function(VoidCallback fn) setStateCallback,
  required double width,
  required double height,
  required Color color,
  required Offset initialPosition,
  required Widget widget,
  required ValueChanged<Offset> onPositionChanged,
  bool? fixedFlag,
  String? title,
  Color? draggingColor,
  double minY = 0,
  Color headerColor = Colors.transparent,
}) {
  if (firstEntries.isNotEmpty) {
    for (final OverlayEntry e in firstEntries) {
      e.remove();
    }
    setStateCallback(() => firstEntries.clear());
  }

  late OverlayEntry entry;
  entry = createDraggableOverlayEntry(
    context: context,
    initialOffset: initialPosition,
    width: width,
    height: height,
    color: color,
    onRemove: () {
      entry.remove();
      setStateCallback(() => firstEntries.remove(entry));
    },
    widget: widget,
    onPositionChanged: onPositionChanged,
    fixedFlag: fixedFlag,
    title: title,
    draggingColor: draggingColor,
    minY: minY,
    headerColor: headerColor,
  );

  setStateCallback(() => firstEntries.add(entry));

  final OverlayState overlayState = Overlay.of(context);

  if (secondEntries.isNotEmpty) {
    overlayState.insert(entry, above: secondEntries.last);
  } else {
    overlayState.insert(entry);
  }
}

//=======================================================//

///
void addSecondOverlay({
  required BuildContext context,
  required List<OverlayEntry> secondEntries,
  required void Function(VoidCallback fn) setStateCallback,
  required double width,
  required double height,
  required Color color,
  required Offset initialPosition,
  required Widget widget,
  required ValueChanged<Offset> onPositionChanged,
  bool? fixedFlag,
}) {
  if (secondEntries.isNotEmpty) {
    for (final OverlayEntry e in secondEntries) {
      e.remove();
    }
    setStateCallback(() => secondEntries.clear());
  }

  late OverlayEntry entry;
  entry = createDraggableOverlayEntry(
    context: context,
    initialOffset: initialPosition,
    width: width,
    height: height,
    color: color,
    onRemove: () {
      entry.remove();
      setStateCallback(() => secondEntries.remove(entry));
    },
    widget: widget,
    onPositionChanged: onPositionChanged,
    fixedFlag: fixedFlag,
  );

  setStateCallback(() => secondEntries.add(entry));
  Overlay.of(context).insert(entry);
}
