import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AiAnalysisExplainAlert extends ConsumerStatefulWidget {
  const AiAnalysisExplainAlert({super.key});

  @override
  ConsumerState<AiAnalysisExplainAlert> createState() => _AiAnalysisExplainAlertState();
}

class _AiAnalysisExplainAlertState extends ConsumerState<AiAnalysisExplainAlert> {
  static const String _markdownContent =
      '## 使用AIについて\n'
      '\n'
      '当サービスのAI予想には、Anthropic社が開発した **Claude AI** を使用しています。\n'
      '\n'
      '---\n'
      '\n'
      '## 分析の仕組み\n'
      '\n'
      'レース発走の直前まで収集した **単勝オッズの推移データ** をもとに、Claude AI がリアルタイムで分析を行い、注目馬を導き出しています。\n'
      '\n'
      '具体的には、以下の情報をAIに提供しています。\n'
      '\n'
      '- レース基本情報（日付・開催・レース名・クラス）\n'
      '- 各馬の単勝オッズ（計測開始時点 ＆ 発走3分前）\n'
      '- オッズの変動方向と変動率\n'
      '\n'
      '---\n'
      '\n'
      '## AIへの分析依頼内容\n'
      '\n'
      'AIには、以下の3点を回答するよう依頼しています。\n'
      '\n'
      '1. **勝つ確率が高そうな馬（最大3頭）と理由**\n'
      '2. **積極的に消してよい馬と理由**\n'
      '3. **レースの総評**（混戦か本命か、買い方の方向性）\n'
      '\n'
      'オッズが **10%以上下落した馬（＝直前に人気が急上昇した馬）** を特に重視するよう指示しています。\n'
      '\n'
      '---\n'
      '\n'
      '## AIへの実際のプロンプト（例）\n'
      '\n'
      '以下は、AIに送信しているプロンプトのサンプルです。レースごとに自動生成されます。\n'
      '\n'
      '```\n'
      'あなたは競馬オッズ分析の専門家です。\n'
      '有料公開するものなので、できるだけ正しい日本語で返してください。\n'
      '\n'
      'レース情報\n'
      '日付: ●●●●-●●-●●\n'
      '開催: ●回●●●●日\n'
      'レース: ●R ●●●●●●（●●）[●●]\n'
      '\n'
      '単勝オッズデータ（計測開始前から発走3分前）\n'
      ' 1番 ○○○○○○  計測開始前: ●●.●倍  3分前: ●●.●倍  変動: 上昇 +●●.●%\n'
      ' 2番 ○○○○○○  計測開始前: ●●.●倍  3分前: ●●.●倍  変動: 下落 ●●.●%\n'
      ' 3番 ○○○○○○  計測開始前: ●●.●倍  3分前: ●●.●倍  変動: 上昇 +●●.●%\n'
      ' ...（出走頭数分続く）\n'
      '\n'
      '分析依頼\n'
      'オッズ推移から以下を教えてください。\n'
      '1. 勝つ確率が高そうな馬（最大3頭）と理由\n'
      '2. 積極的に消してよい馬と理由\n'
      '3. このレースの総評（混戦か本命か、買い方の方向性）\n'
      '\n'
      'オッズ下落10%以上は人気急上昇として注目してください。\n'
      '日本語・箇条書きで簡潔にまとめてください。\n'
      '\n'
      '【必須】回答の最後の行に、必ず以下の形式だけで注目馬を出力してください。\n'
      '他の文章や説明は一切付けず、この1行だけを最終行にしてください。\n'
      'PICKUP:馬番|馬名|おすすめ度/馬番|馬名|おすすめ度/馬番|馬名|おすすめ度\n'
      '```\n'
      '\n'
      '---\n'
      '\n'
      '## ご注意事項\n'
      '\n'
      '- AI予想はオッズの推移データのみを根拠とした参考情報です。馬の能力・騎手・馬場状態・血統などは考慮していません。\n'
      '- 予想が必ず的中することを保証するものではありません。\n'
      '- 馬券の購入はご自身の判断と責任のもとで行ってください。\n'
      '- 当サービスのAI予想はJRAおよびその関連団体とは一切関係ありません。\n';

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
          Text('AI予想について', style: TextStyle(color: Colors.white, fontSize: 12)),
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
          ),
        ),
      ),
    );
  }
}
