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
    this.borderRadius = 3.0,
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

  /// 四隅の角丸半径。
  final double borderRadius;

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
        padding: EdgeInsets.all(selectedBorderWidth),
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
                      cornerRadius: borderRadius,
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
    required this.cornerRadius,
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
  final double cornerRadius;

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
    final double pl = tabWidth; // panelLeft
    final double r = cornerRadius;
    final Radius rad = Radius.circular(r);

    double tabTop(int i) => i * (tabHeight + tabGap);
    double tabBottom(int i) => tabTop(i) + tabHeight;

    final double selTop = tabTop(selectedIndex);
    final double selBottom = tabBottom(selectedIndex);

    // パネル輪郭（時計回り → clockwise: true）
    canvas.drawPath(
      Path()
        ..moveTo(pl, selTop)
        ..lineTo(pl, r)
        ..arcToPoint(Offset(pl + r, 0), radius: rad, clockwise: true) // 左上
        ..lineTo(w - r, 0)
        ..arcToPoint(Offset(w, r), radius: rad, clockwise: true) // 右上
        ..lineTo(w, h - r)
        ..arcToPoint(Offset(w - r, h), radius: rad, clockwise: true) // 右下
        ..lineTo(pl + r, h)
        ..arcToPoint(Offset(pl, h - r), radius: rad, clockwise: true) // 左下
        ..lineTo(pl, selBottom),
      selected,
    );

    // 選択タブ（反時計回り → clockwise: false）
    canvas.drawPath(
      Path()
        ..moveTo(pl, selTop)
        ..lineTo(r, selTop)
        ..arcToPoint(Offset(0, selTop + r), radius: rad, clockwise: false) // 左上
        ..lineTo(0, selBottom - r)
        ..arcToPoint(Offset(r, selBottom), radius: rad, clockwise: false) // 左下
        ..lineTo(pl, selBottom),
      selected,
    );

    // 非選択タブ（clockwise: false）
    for (int i = 0; i < tabCount; i++) {
      if (i == selectedIndex) continue;
      final double top = tabTop(i);
      final double bottom = tabBottom(i);
      final Path tabPath = i < selectedIndex
          // 上側: 上辺＋左辺。左上コーナーを丸める
          ? (Path()
              ..moveTo(pl, top)
              ..lineTo(r, top)
              ..arcToPoint(Offset(0, top + r), radius: rad, clockwise: false)
              ..lineTo(0, bottom))
          // 下側: 左辺＋下辺。左下コーナーを丸める
          : (Path()
              ..moveTo(0, top)
              ..lineTo(0, bottom - r)
              ..arcToPoint(Offset(r, bottom), radius: rad, clockwise: false)
              ..lineTo(pl, bottom));
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
        old.selectedStrokeWidth != selectedStrokeWidth ||
        old.cornerRadius != cornerRadius;
  }
}
