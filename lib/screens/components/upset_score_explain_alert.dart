import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpsetScoreExplainAlert extends ConsumerStatefulWidget {
  const UpsetScoreExplainAlert({super.key});

  @override
  ConsumerState<UpsetScoreExplainAlert> createState() => _UpsetScoreExplainAlertState();
}

class _UpsetScoreExplainAlertState extends ConsumerState<UpsetScoreExplainAlert> {
  static const List<String> _markdownContent = <String>[
      '## 期待数値とは',
      '',
      '過去の類似レースにおける人気順別の中央値オッズと、現在のオッズを比較した指標です。',
      '',
      '「過去の中央値オッズ ÷ 現在の単勝オッズ」で算出します。',
      '',
      '---',
      '',
      '## 算出方法',
      '',
      '### ① 過去レースの比率パターンを蓄積',
      '',
      '過去レースの確定結果（単勝オッズ）を人気順に並べ、隣り合う人気順間のオッズ比（次 ÷ 前）を計算し、各レースの比率パターンとして保存します。',
      '',
      '> 例）1番人気1.5倍・2番人気2.3倍・3番人気3.0倍のレースの場合',
      '> 2.3÷1.5＝1.53、3.0÷2.3＝1.30 → パターン「1.53 | 1.30」として保存',
      '',
      '### ② 対象レースの比率パターンを計算',
      '',
      '事前に収集・記録されたオッズをもとに、①と同じ方法で比率パターンを算出します。',
      '',
      '### ③ 類似レースの特定',
      '',
      '②で算出した比率パターンを①のデータと照合します。比較は**出走頭数が同じレース同士**のみで行います。',
      '',
      '類似度はRMSE（各要素の差の二乗平均の平方根）をもとに算出し、**類似度70%以上**のレースを類似レースとして採用します。',
      '',
      '### ④ 人気順別の中央値オッズを算出',
      '',
      '③で特定した類似レース群について、人気順ごとに過去の確定単勝オッズを収集し、各人気順の**中央値（メジアン）**を算出します。',
      '',
      'この中央値を「過去の類似レースにおける各人気順の典型的なオッズ」として保存します。',
      '',
      '### ⑤ 期待数値の計算・表示',
      '',
      '```',
      '期待数値 ＝ 類似レースの中央値オッズ ÷ 現在の単勝オッズ',
      '```',
      '',
      'この値が高い順に上位馬をピックアップして表示します。',
      '',
      '---',
      '',
      '## 期待数値の読み方',
      '',
      '- 値が **1.0より大きい** ほど、過去と比べてオッズが高い（＝市場からやや軽視されているが、過去の同人気順馬は好走している）ことを意味します。',
      '- 値が **1.0より小さい** ほど、過去と比べてオッズが低い（＝市場から高く評価されている）ことを意味します。',
      '',
      '---',
      '',
      '## 強調表示について',
      '',
      '全出走馬の期待数値を表示したうえで、出走頭数に応じた以下の頭数分を上位として強調表示します。',
      '',
      '| 出走頭数 | 強調表示頭数 |',
      '|----------|----------|',
      '| 8頭以下 | 上位4頭 |',
      '| 9〜13頭 | 上位5頭 |',
      '| 14頭以上 | 上位6頭 |',
      '',
      '---',
      '',
      '## ご注意事項',
      '',
      '- 期待数値は過去の類似レースとの比較による参考指標です。馬の能力・騎手・馬場状態・血統などは考慮していません。',
      '- 類似レースが見つからない場合は、この項目は表示されません。',
      '- 予想が必ず的中することを保証するものではありません。',
      '- 馬券の購入はご自身の判断と責任のもとで行ってください。',
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
          Text('期待数値について', style: TextStyle(color: Colors.white, fontSize: 12)),
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
          data: _markdownContent.join('\n'),
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
