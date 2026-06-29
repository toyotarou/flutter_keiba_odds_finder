import 'package:flutter/material.dart';

/// ルーズリーフの見出し（ツマミ）風の縦タブ + 右パネル。
/// 選択中のタブだけ「右辺」と、その範囲の「パネル左辺」を描かないことで、
/// 塗りを使わずにタブとパネルを地続きに見せる。
class SideTabPanel extends StatelessWidget {
  const SideTabPanel({
    super.key,
    required this.tabLabels,
    required this.selectedIndex,
    required this.onSelected,
    this.height = 160,
    this.tabWidth = 80,
    this.tabGap = 10,
    this.borderColor = Colors.white,
    this.selectedBorderColor = const Color(0xFF4CAF50),
    this.unselectedTextColor = Colors.white,
    this.borderWidth = 1.5,
    this.selectedBorderWidth = 3.0,
    this.tabTextStyle,
    this.panelTextStyle,
    this.panelChild,
  });

  final List<String> tabLabels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// 全体の高さ。
  final double height;

  /// 左のタブ列の幅。
  final double tabWidth;

  /// タブ同士の縦の隙間。
  final double tabGap;

  final Color borderColor;

  /// 選択中タブ＋パネルのボーダー色。
  final Color selectedBorderColor;

  /// 非選択タブのテキスト色。
  final Color unselectedTextColor;

  final double borderWidth;
  final double selectedBorderWidth;
  final TextStyle? tabTextStyle;
  final TextStyle? panelTextStyle;

  /// パネル内に出す中身。null の場合は選択中タブのラベルを表示。
  final Widget? panelChild;

  @override
  Widget build(BuildContext context) {
    final int n = tabLabels.length;

    return SizedBox(
      height: height,
      child: Padding(
        // 端のボーダーが半分はみ出してクリップされるのを防ぐ
        padding: EdgeInsets.all(borderWidth),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double h = constraints.maxHeight;
            final double th = (h - tabGap * (n - 1)) / n; // 各タブの高さ

            double tabTop(int i) => i * (th + tabGap);

            return Stack(
              children: <Widget>[
                // ① タブ＋パネルの輪郭をまとめて描画
                Positioned.fill(
                  child: CustomPaint(
                    painter: _SideTabPainter(
                      tabCount: n,
                      selectedIndex: selectedIndex,
                      tabWidth: tabWidth,
                      tabHeight: th,
                      tabGap: tabGap,
                      color: borderColor.withValues(alpha: 0.4),
                      selectedColor: selectedBorderColor.withValues(alpha: 0.4),
                      strokeWidth: borderWidth,
                      selectedStrokeWidth: selectedBorderWidth,
                    ),
                  ),
                ),

                // ② 各タブのラベル＋タップ領域
                for (int i = 0; i < n; i++)
                  Positioned(
                    left: 0,
                    top: tabTop(i),
                    width: tabWidth,
                    height: th,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onSelected(i),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            tabLabels[i],
                            textAlign: TextAlign.center,
                            style:
                                tabTextStyle ??
                                TextStyle(
                                  color: i == selectedIndex ? selectedBorderColor : unselectedTextColor,
                                  fontSize: 13,
                                  fontWeight: i == selectedIndex ? FontWeight.bold : FontWeight.normal,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // ③ パネルの中身（選択中タブに応じて切り替わる）
                Positioned(
                  left: tabWidth,
                  top: 0,
                  right: 0,
                  bottom: 0,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child:
                        panelChild ??
                        Text(
                          tabLabels[selectedIndex],
                          style:
                              panelTextStyle ??
                              TextStyle(color: selectedBorderColor, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SideTabPainter extends CustomPainter {
  _SideTabPainter({
    required this.tabCount,
    required this.selectedIndex,
    required this.tabWidth,
    required this.tabHeight,
    required this.tabGap,
    required this.color,
    required this.selectedColor,
    required this.strokeWidth,
    required this.selectedStrokeWidth,
  });

  final int tabCount;
  final int selectedIndex;
  final double tabWidth;
  final double tabHeight;
  final double tabGap;
  final Color color;
  final Color selectedColor;
  final double strokeWidth;
  final double selectedStrokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint selected = Paint()
      ..color = selectedColor
      ..strokeWidth = selectedStrokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    final Paint normal = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    final double w = size.width;
    final double h = size.height;
    final double panelLeft = tabWidth;

    double tabTop(int i) => i * (tabHeight + tabGap);
    double tabBottom(int i) => tabTop(i) + tabHeight;

    final double selTop = tabTop(selectedIndex);
    final double selBottom = tabBottom(selectedIndex);

    // パネル輪郭: gap を挟んだ開いたパス（コーナーは miter join で alpha 重複なし）
    canvas.drawPath(
      Path()
        ..moveTo(panelLeft, selTop)
        ..lineTo(panelLeft, 0)
        ..lineTo(w, 0)
        ..lineTo(w, h)
        ..lineTo(panelLeft, h)
        ..lineTo(panelLeft, selBottom),
      selected,
    );

    // 選択タブ: 右辺なしの開いたパス
    canvas.drawPath(
      Path()
        ..moveTo(panelLeft, selTop)
        ..lineTo(0, selTop)
        ..lineTo(0, selBottom)
        ..lineTo(panelLeft, selBottom),
      selected,
    );

    // 非選択タブ: 上側は「上辺＋左辺」、下側は「左辺＋下辺」のL字パス
    for (int i = 0; i < tabCount; i++) {
      if (i == selectedIndex) {
        continue;
      }
      final double top = tabTop(i);
      final double bottom = tabBottom(i);
      final Path tabPath = i < selectedIndex
          ? (Path()
              ..moveTo(panelLeft, top)
              ..lineTo(0, top)
              ..lineTo(0, bottom))
          : (Path()
              ..moveTo(0, top)
              ..lineTo(0, bottom)
              ..lineTo(panelLeft, bottom));
      canvas.drawPath(tabPath, normal);
    }
  }

  @override
  bool shouldRepaint(covariant _SideTabPainter old) {
    return old.selectedIndex != selectedIndex ||
        old.tabCount != tabCount ||
        old.tabWidth != tabWidth ||
        old.tabHeight != tabHeight ||
        old.tabGap != tabGap ||
        old.color != color ||
        old.selectedColor != selectedColor ||
        old.strokeWidth != strokeWidth ||
        old.selectedStrokeWidth != selectedStrokeWidth;
  }
}
