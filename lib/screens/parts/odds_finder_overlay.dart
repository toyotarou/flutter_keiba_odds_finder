// =============================================================================
// ファイル名   : odds_finder_overlay.dart
// 概要         : ドラッグで移動できるオーバーレイ（レース選択など）を作って表示する関数と、
//                レース選択オーバーレイの表示切り替えに使う共有の値。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-08-22
// 最終更新日   : 2026-11-17
// =============================================================================

import 'package:flutter/material.dart';

/// レース選択オーバーレイ（home_screen の _firstEntries）を一時的に隠したいときに true にする。
/// 払戻金ダイアログの表示中だけ true にし、閉じたら false に戻す。home_screen 側がこの値を見て外す／戻す。
final ValueNotifier<bool> raceOverlayHiddenNotifier = ValueNotifier<bool>(false);

/// ドロアが開いているか（home_screen の onDrawerChanged で更新）。
/// ドロア表示中にダイアログを閉じても、ドロアが開いている間はレース選択オーバーレイを戻さないために使う。
bool raceOverlayDrawerOpen = false;

//=======================================================//

/// ドラッグで移動できるオーバーレイ1つぶんの情報（位置・大きさ・色）。
class DraggableOverlayItem {
  DraggableOverlayItem({required this.position, required this.width, required this.height, required this.color});

  late OverlayEntry entry;

  Offset position;

  final double width;
  final double height;

  final Color color;
}

//=======================================================//

/// 見出しをドラッグして移動できるオーバーレイを作る（表示はしない）。
/// 画面の外や、上端の [minY] より上には移動できない。[fixedFlag] が true なら移動できない。
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
  // 中身のスクロール位置を呼び出し側で保持したいときに渡す（作り直してもスクロール位置を戻せるように）
  ScrollController? scrollController,
}) {
  final Size screenSize = MediaQuery.of(context).size;

  final DraggableOverlayItem item = DraggableOverlayItem(
    // minY（上端の移動禁止エリア）より上に初期位置がある場合も minY に寄せる
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
                              // 上端に寄せるとスマホのシステム操作に邪魔されて、
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
                    child: Stack(
                      children: <Widget>[
                        // ignore: sized_box_shrink_expand
                        SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: Center(
                            child: Text(
                              title ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            // ignore: use_if_null_to_convert_nulls_to_bools
                            if (fixedFlag == true)
                              const Icon(Icons.check_box_outline_blank, color: Colors.transparent)
                            else
                              const Icon(Icons.drag_indicator, color: Colors.white),
                            IconButton(
                              onPressed: onRemove,
                              icon: const Icon(Icons.close, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
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

/// 1つ目の層のオーバーレイを表示する（すでに表示中のものは閉じてから表示する）。
/// 2つ目の層が表示中なら、その上に重ねる。
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
  ScrollController? scrollController,
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
    scrollController: scrollController,
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

/// 2つ目の層のオーバーレイを表示する（すでに表示中のものは閉じてから表示する）。
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
