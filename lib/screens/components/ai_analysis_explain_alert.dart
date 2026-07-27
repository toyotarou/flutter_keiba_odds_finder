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
      '## どんな分析をしているの？\n'
      '\n'
      'レース発走の直前まで収集した **単勝・複勝オッズの動き** をもとに、AIが注目馬を導き出しています。\n'
      '\n'
      'AIへの質問は以下の7点です。\n'
      '\n'
      '1. **勝つ確率が高そうな馬（最大3頭）と理由**\n'
      '2. **積極的に消してよい馬と理由**\n'
      '3. **複勝・ワイドで狙える馬**\n'
      '4. **中穴の単勝1点勝負をするなら、どの馬か**\n'
      '5. **人気馬＋穴馬のワイド1点勝負をするなら、どの組み合わせか**\n'
      '6. **このレースに1000円使うとしたら、どういう馬券を買うか**\n'
      '7. **レースの総評**（混戦か本命か、買い方の方向性）\n'
      '\n'
      '---\n'
      '\n'
      '## オッズ間断層とは\n'
      '\n'
      '人気順が隣り合う馬どうしのオッズの開きを表す指標です。\n'
      '\n'
      'この開きが大きい地点を「断層」と呼び、断層の手前にいる馬は市場から特別な支持を受けていると判断できます。断層が確認された馬はAIへの分析でも重点的に注目するよう伝えています。\n'
      '\n'
      '---\n'
      '\n'
      '## 期待数値とは\n'
      '\n'
      '過去の似たようなレースで、同じ人気順の馬がつけていたオッズと今回を比べた指標です。\n'
      '\n'
      '「過去より今回のオッズが高め＝市場からやや軽視されているが、過去の同じ立場の馬は好走している」という観点で注目馬を絞り込んでいます。\n'
      '\n'
      '**なお、過去に似たレースが見つからない場合は、この指標が算出されないことがあります。**\n'
      '\n'
      '---\n'
      '\n'
      '## こんなプロンプトをAIに送っています\n'
      '\n'
      '```\n'
      'あなたは競馬オッズ分析の専門家です。\n'
      '有料公開するものなので、正しい日本語で返してください。\n'
      '\n'
      'レース情報\n'
      '日付: ●●●●-●●-●●\n'
      '開催: ●回●●●日\n'
      'レース: ●R ●●●●●●\n'
      '\n'
      '単勝・複勝オッズデータ（計測開始前から発走6分前）\n'
      ' 1番 ○○○○○○  単勝: ●●.●倍→●●.●倍(上昇 +●●.●%)  複勝: ●●.●-●●.●倍(下落 ●●.●%)  単複比: ●.●倍\n'
      ' 2番 ○○○○○○  単勝: ●●.●倍→●●.●倍(下落 ●●.●%)  複勝: ●●.●-●●.●倍(上昇 +●●.●%)  単複比: ●.●倍\n'
      ' ...（出走頭数分続く）\n'
      '\n'
      'なお、オッズ分析にあたり、下記の注目馬番も参考にしてください。\n'
      '特に、②の期待数値の馬番はかなり結果を出せているので、重点的に注視してください。\n'
      '①　オッズ間断層の調査から絞り込んだ馬番「●|●」\n'
      '②　期待数値の調査から絞り込んだ馬番「●|●|●」（※類似レースがない場合は表示されません）\n'
      '\n'
      '分析依頼\n'
      'オッズ推移から以下を教えてください。\n'
      '1. 勝つ確率が高そうな馬（最大3頭）と理由\n'
      '2. 積極的に消してよい馬と理由\n'
      '3. 複勝・ワイドで狙える馬（単複比・複勝変動に注目）\n'
      '4. 中穴の単勝1点勝負をするとしたら、どの馬を選ぶか\n'
      '5. 人気馬＋穴馬のワイド1点勝負をする場合の組み合わせ\n'
      '6. このレースに1000円使うとしたら、どういう馬券を購入するか\n'
      '7. このレースの総評（混戦か本命か、買い方の方向性）\n'
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
