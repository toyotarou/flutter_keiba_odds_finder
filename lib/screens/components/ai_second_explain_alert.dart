import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AiSecondExplainAlert extends ConsumerWidget {
  const AiSecondExplainAlert({super.key});

  static const String _markdownContent =
      '## 2nd AI（DeepSeek）とは\n'
      '\n'
      '「2nd AI」ボタンを押すと、中国のAI企業 **DeepSeek** が開発した **DeepSeek-V3** モデルが、\n'
      '1st AI（Claude）とは独立して同じレースを分析します。\n'
      '\n'
      '---\n'
      '\n'
      '## なぜ2つのAIを使うの？\n'
      '\n'
      '1st AIであるClaudeは非常に優秀ですが、どうしても **人気上位馬を中心にした堅実な予想** になりがちです。\n'
      'オッズの動きに忠実に従うあまり、ガチガチの本命サイドばかり選んでしまうことがあります。\n'
      '\n'
      'それ自体は間違いではありませんが、競馬の醍醐味は **穴馬の激走** にもあります。\n'
      '回収率を長期的に上げるためには、人気薄でもオッズ推移に根拠のある馬を拾えるかどうかが重要です。\n'
      '\n'
      'そこで2nd AIのDeepSeekには、少し違う視点を持ってもらっています。\n'
      '\n'
      '---\n'
      '\n'
      '## 2nd AIへの指示方針\n'
      '\n'
      '2nd AIのシステムプロンプトは次のとおりです。\n'
      '\n'
      '```\n'
      '競馬のオッズ推移を分析して有力馬を絞り込む専門家です。\n'
      'ただし、人気上位馬だけを並べる予想は面白くありません。\n'
      'オッズ推移に確かな根拠があれば、中穴・大穴馬も積極的に取り上げてください。\n'
      'まじめに、しかし少し遊んでみてください。\n'
      '```\n'
      '\n'
      '1st AIが「正確さ・信頼度」重視なのに対し、2nd AIは **「根拠ある遊び」** を許容しています。\n'
      '\n'
      '---\n'
      '\n'
      '## 使用するデータ\n'
      '\n'
      '2nd AIが分析に使うデータは、1st AIと同じです。\n'
      '\n'
      '- 単勝・複勝オッズの推移\n'
      '- 断層構造タイプ（システムが自動算出）\n'
      '- OPI（過去オッズ比較指数）\n'
      '- 過去のレース情報・コース統計\n'
      '\n'
      'ただし、**厳選穴レース判定のロジックは除外**して送信しています。\n'
      'これは2nd AI独自の視点で穴馬を見つけてもらうための意図的な設計です。\n'
      '\n'
      '---\n'
      '\n'
      '## 補欠とは\n'
      '\n'
      '2nd AIが選んだ馬のうち、**1st AI（Claude）が選んでいない馬**を「補欠」と表示しています。\n'
      '\n'
      '- 両AIが共通して選んだ馬 → メインリストに **緑枠の「2nd AI理由」** を追加表示\n'
      '- 2nd AIのみが選んだ馬 → リスト下部に **「補欠」バッジ付き** で別表示\n'
      '\n'
      '補欠馬はClaudeの評価では惜しくも外れた馬ですが、DeepSeekの視点では根拠のある注目馬です。\n'
      '本命サイドが物足りないと感じたときに、補欠馬を加えた馬券を検討する材料としてご活用ください。\n'
      '\n'
      '---\n'
      '\n'
      '## 「補欠でX頭をカバー」とは\n'
      '\n'
      'レース結果が出たあと、1st AIが完全には当てられなかったレースで、\n'
      '**補欠馬が実際の1〜3着に入っていた場合**に「補欠でX頭をカバー」と表示されます。\n'
      '\n'
      'これは「2nd AIの補欠馬も買い目に加えていれば、あとX頭カバーできた」という振り返り指標です。\n'
      '\n'
      '---\n'
      '\n'
      '## 結果の見方\n'
      '\n'
      '合致結果の表示は以下のように読みます。\n'
      '\n'
      '- **ピンク表示**：1st AIだけで3頭カバー、または補欠込みで合計3頭カバー\n'
      '- **黄色表示**：払戻が高額（三連複1万円以上）\n'
      '- **「+X」**（緑）：1st AIの合致数に加えて、補欠がさらにX頭カバーしたことを示す\n'
      '\n'
      '---\n'
      '\n'
      '## キャッシュについて\n'
      '\n'
      '2nd AIの分析結果は **サーバー側にキャッシュ**されます。\n'
      '同じレースに対して2回目以降に「2nd AI」ボタンを押した場合は、\n'
      'DeepSeek APIへの通信は発生せず、保存済みの結果が即座に返ります。\n'
      '\n'
      '---\n'
      '\n'
      '## ご注意事項\n'
      '\n'
      '- 2nd AIはあくまで参考情報です。必ず的中することを保証するものではありません。\n'
      '- 2nd AIの分析もオッズ推移データのみに基づいており、馬の能力・騎手・馬場などは考慮していません。\n'
      '- 馬券の購入はご自身の判断と責任のもとで行ってください。\n';

  ///
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('2nd AI（DeepSeek）について', style: TextStyle(color: Colors.white, fontSize: 12)),
                  SizedBox.shrink(),
                ],
              ),
            ),

            Divider(color: Colors.white.withValues(alpha: 0.5), thickness: 5),

            Expanded(
              child: SingleChildScrollView(
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
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
