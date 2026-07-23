import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrecautionAnalysis extends ConsumerStatefulWidget {
  const PrecautionAnalysis({super.key});

  @override
  ConsumerState<PrecautionAnalysis> createState() => _PrecautionAnalysisState();
}

class _PrecautionAnalysisState extends ConsumerState<PrecautionAnalysis> {
  static const String _markdownContent =
      '## 過去データからの分析について\n'
      '\n'
      '---\n'
      '\n'
      '### ① オッズ断層の算出\n'
      '\n'
      '本日のレースの馬を人気順に並べ、隣り合う馬のオッズを割り算します。\n'
      '\n'
      '> 例）1番人気2.4倍・2番人気4.8倍 → 4.8 ÷ 2.4 ＝ 2.00\n'
      '\n'
      'これを全頭分計算します。馬眼力では「オッズ断層」と呼んでいます。\n'
      '\n'
      '---\n'
      '\n'
      '### ② 過去レースとの照合\n'
      '\n'
      'オッズ断層を過去3年分のレースと1件ずつ見比べて、「オッズ断層の並び方が似ているレース」を探します。\n'
      '\n'
      '---\n'
      '\n'
      '### ③ 類似レースの抽出\n'
      '\n'
      '似ている度合いが**70%以上**のレースを「類似レース」として取り出します。\n'
      '\n'
      'この結果は「類似の過去レース」として、別途表示しています。\n'
      '\n'
      '---\n'
      '\n'
      '### ④ 複勝率の算出\n'
      '\n'
      '取り出した類似レースで、同じ人気順位の馬が実際に何回3着以内に入ったかを数えます。\n'
      '\n'
      '```\n'
      '複勝率 ＝ 3着以内の回数 ÷ 類似レース件数 × 100\n'
      '```\n'
      '\n'
      '---\n'
      '\n'
      '### ⑤ 表示条件\n'
      '\n'
      '類似レースが**2件以上**あり、複勝率が**50%以上**の馬だけを表示しています。\n'
      '\n'
      '類似レースの件数が多いほど信頼性が高くなります。\n'
      '\n'
      '---\n'
      '\n'
      '### ⑥ オッズ変化率の算出\n'
      '\n'
      '```\n'
      'オッズ変化率 ＝（直前オッズ - 計測開始前オッズ）÷ 計測開始前オッズ × 100\n'
      '```\n'
      '\n'
      'マイナスは計測開始前より人気が上がったことを意味します。\n';

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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Container(
        margin: const EdgeInsets.all(3),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5)),
        child: MarkdownBody(
          data: _markdownContent,
          styleSheet: MarkdownStyleSheet(
            h2: const TextStyle(fontSize: 13, color: Colors.greenAccent, fontWeight: FontWeight.bold),
            h3: const TextStyle(fontSize: 12, color: Colors.yellowAccent, fontWeight: FontWeight.bold),
            p: const TextStyle(fontSize: 11, color: Colors.white),
            strong: const TextStyle(fontSize: 11, color: Colors.yellowAccent, fontWeight: FontWeight.bold),
            listBullet: const TextStyle(fontSize: 11, color: Colors.white70),
            horizontalRuleDecoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white24)),
            ),
            codeblockDecoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white24),
            ),
            code: const TextStyle(fontSize: 10, color: Colors.white70, fontFamily: 'monospace'),
            blockquoteDecoration: const BoxDecoration(
              color: Colors.white10,
              border: Border(left: BorderSide(color: Colors.white38, width: 4)),
            ),
            blockquote: const TextStyle(fontSize: 11, color: Colors.white70),
          ),
        ),
      ),
    );
  }
}
