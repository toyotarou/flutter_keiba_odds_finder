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
    TermsChapter(
      '1',
      '本日のレースの馬を人気順に並べ、隣り合う馬のオッズを割り算します。\n例えば「1番人気2.4倍・2番人気4.8倍」なら「4.8 ÷ 2.4 = 2.00」です。\nこれを全頭分計算します。\n馬眼力では「オッズ断層」と呼んでいます。',
    ),
    TermsChapter('2', 'オッズ断層を過去3年分のレースと1件ずつ見比べて、「オッズ断層の並び方が似ているレース」を探します。'),
    TermsChapter('3', '似ている度合いが70%以上のレースを「類似レース」として取り出します。\nこの結果は「類似の過去レース」として、別途表示しています。'),
    TermsChapter('4', '取り出した類似レースで、同じ人気順位の馬が実際に何回3着以内に入ったかを数えます。\n「3着以内の回数 ÷ 類似レース件数 × 100」が複勝率です。'),
    //    TermsChapter('5', '同じように、類似レースでその人気順位の馬に100円ずつ賭け続けた場合の平均払戻額を単勝回収率・複勝回収率として表示しています。'),
    TermsChapter('5', '類似レースが2件以上あり、複勝率が50%以上の馬だけを表示しています。\n類似レースの件数が多いほど信頼性が高くなります。'),
    TermsChapter('6', 'オッズ変化率は「（直前オッズ - 計測開始前オッズ）÷ 計測開始前オッズ × 100」で計算しています。\nマイナスは計測開始前より人気が上がったことを意味します。'),
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

            Divider(color: Colors.white.withValues(alpha: 0.5), thickness: 5),
            const SizedBox(height: 16),

            Expanded(child: _buildBody()),

            const SizedBox(height: 20),
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
          Text('過去データからの分析について', style: TextStyle(color: Colors.white, fontSize: 12)),

          SizedBox.shrink(),
        ],
      ),
    );
  }

  ///
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
