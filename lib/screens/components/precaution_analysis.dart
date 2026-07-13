import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../parts/terms_chapter.dart';

class PrecautionAnalysis extends ConsumerStatefulWidget {
  const PrecautionAnalysis({super.key});

  @override
  ConsumerState<PrecautionAnalysis> createState() => _PrecautionAnalysisState();
}

class _PrecautionAnalysisState extends ConsumerState<PrecautionAnalysis> {
  static const List<TermsChapter> _chapters = <TermsChapter>[
    TermsChapter('1', '本日のレースの馬を人気順に並べ、隣り合う馬のオッズを割り算します。\n例えば「1番人気2.4倍・2番人気4.8倍」なら「4.8 ÷ 2.4 = 2.00」です。\nこれを全頭分計算します。'),
    TermsChapter('2', 'その計算結果を過去3年分のレースと1件ずつ見比べて、「オッズの並び方が似ているレース」を探します。'),
    TermsChapter('3', '似ている度合いが70%以上のレースを「類似レース」として取り出します。\nこの結果は「類似の過去レース」として、別途表示しています。'),
    TermsChapter('4', '取り出した類似レースで、同じ人気順位の馬が実際に何回3着以内に入ったかを数えます。\n「3着以内の回数 ÷ 類似レース件数 × 100」が複勝率です。'),
    TermsChapter('5', '同じように、類似レースでその人気順位の馬に100円ずつ賭け続けた場合の平均払戻額を単勝回収率・複勝回収率として表示しています。'),
    TermsChapter('6', '類似レースが2件以上あり、複勝率が50%以上の馬だけを表示しています。\n類似レースの件数が多いほど信頼性が高くなります。'),
    TermsChapter('7', 'オッズ変化率は「（直前オッズ - 計測開始前オッズ）÷ 計測開始前オッズ × 100」で計算しています。\nマイナスは計測開始前より人気が上がったことを意味します。'),
  ];

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeader(context),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  ///
  Widget _buildHeader(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 12, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '分析について',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),

          SizedBox.shrink(),
        ],
      ),
    );
  }

  ///
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Divider(color: Colors.greenAccent.withValues(alpha: 0.6), thickness: 1),
          const SizedBox(height: 16),

          Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5)),

            child: Column(
              children: _chapters
                  .asMap()
                  .entries
                  .map(
                    (MapEntry<int, TermsChapter> entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: TermsChapterTile(index: entry.key + 1, chapter: entry.value),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
