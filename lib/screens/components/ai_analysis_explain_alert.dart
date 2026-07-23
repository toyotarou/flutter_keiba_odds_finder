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
      'レース発走の直前まで収集した **単勝・複勝オッズの推移データ** をもとに、Claude AI がリアルタイムで分析を行い、注目馬を導き出しています。\n'
      '\n'
      '具体的には、以下の情報をAIに提供しています。\n'
      '\n'
      '- レース基本情報（日付・開催・レース名）\n'
      '- 各馬の単勝・複勝オッズ（計測開始時点 ＆ 発走6分前）\n'
      '- オッズの変動方向と変動率\n'
      '- 単複比（単勝オッズ ÷ 複勝最小オッズ）\n'
      '- オッズ間断層（隣り合う人気順のオッズの開き具合）\n'
      '- 期待数値（過去の類似レースと比べたオッズの割安・割高感）\n'
      '\n'
      '---\n'
      '\n'
      '## オッズ間断層とは\n'
      '\n'
      '人気順が隣り合う馬どうしの、オッズの開きを数値化したものです。\n'
      '\n'
      '「次の人気の馬のオッズ ÷ この人気の馬のオッズ」で算出します。\n'
      '\n'
      '- この値が **2.0以上** になると、その人気順の間に大きな「壁」があることを意味します。\n'
      '- 壁の手前にいる馬は、市場から抜けた評価を受けていると判断できます。\n'
      '- 計測開始時点と発走6分前の2時点で算出し、その変化も確認しています。\n'
      '\n'
      '---\n'
      '\n'
      '## 期待数値とは\n'
      '\n'
      '過去の類似レースで、同じ人気順の馬がどのくらいのオッズだったかの中央値と、今回のオッズを比較した数値です。\n'
      '\n'
      '「過去の中央値オッズ ÷ 今回のオッズ」で算出します。\n'
      '\n'
      '- 値が **1.0より大きい** ほど、過去と比べてオッズが高い（＝市場からやや軽視されているが、過去の同人気順馬は好走している）ことを意味します。\n'
      '- 値が **1.0より小さい** ほど、過去と比べてオッズが低い（＝市場から高く評価されている）ことを意味します。\n'
      '- 計測開始時点と発走6分前の2時点で算出し、その変化も確認しています。\n'
      '- 過去の類似レースが見つからない場合は、この項目は表示されません。\n'
      '\n'
      '---\n'
      '\n'
      '## AIへの分析依頼内容\n'
      '\n'
      'AIには、以下の7点を回答するよう依頼しています。\n'
      '\n'
      '1. **勝つ確率が高そうな馬（最大3頭）と理由**\n'
      '2. **積極的に消してよい馬と理由**\n'
      '3. **複勝・ワイドで狙える馬**（単複比・複勝変動に注目）\n'
      '4. **中穴の単勝1点勝負をするとしたら、どの馬を選ぶか**\n'
      '5. **人気馬＋穴馬のワイド1点勝負をする場合に選ぶとしたら、どの組み合わせを選ぶか**\n'
      '6. **このレースに1000円使うとしたら、どういう馬券を購入するか**\n'
      '7. **レースの総評**（混戦か本命か、買い方の方向性）\n'
      '\n'
      '分析では、以下の観点を重視するよう指示しています。\n'
      '\n'
      '- 単勝オッズが **10%以上下落** した馬 ＝ 直前に人気が急上昇した注目馬\n'
      '- **単複比が高い**馬 ＝ 勝ちにくいが3着以内には絡みやすい\n'
      '- 複勝の最小・最大の **幅が広い**馬 ＝ 市場の評価が割れている不安定な馬\n'
      '- 複勝の最小・最大の **幅が狭い**馬 ＝ 安定して3着以内が期待されている馬\n'
      '- **複勝オッズが下落**している馬 ＝ 3着以内の信頼度が高い\n'
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
      'レース: ●R ●●●●●●\n'
      '\n'
      '単勝・複勝オッズデータ（計測開始前から発走6分前）\n'
      ' 1番 ○○○○○○  単勝: ●●.●倍→●●.●倍(上昇 +●●.●%)  複勝: ●●.●-●●.●倍(下落 ●●.●%)  単複比: ●.●倍\n'
      ' 2番 ○○○○○○  単勝: ●●.●倍→●●.●倍(下落 ●●.●%)  複勝: ●●.●-●●.●倍(上昇 +●●.●%)  単複比: ●.●倍\n'
      ' ...（出走頭数分続く）\n'
      '\n'
      '①オッズ間断層\n'
      ' 1- 2  ●.●● → ●.●● (上昇 +●●.●%)\n'
      ' 2- 3  ●.●● → ●.●● (下落 ●●.●%)\n'
      ' ...（人気順の組み合わせ分続く）\n'
      '隣り合う人気順間のオッズ比率（次の人気順のオッズ ÷ この人気順のオッズ）です。\n'
      '断層値が2.0以上の人気順に位置する馬を、他の馬より高い確率で推薦してください。\n'
      '\n'
      '②期待数値\n'
      ' 1  ●.●● → ●.●● (下落 ●●.●%)\n'
      ' 2  ●.●● → ●.●● (上昇 +●●.●%)\n'
      ' ...（出走頭数分続く）\n'
      '過去の類似レースにおける人気順別の中央値オッズを、今回のレースの同人気順のオッズで割った値です。\n'
      '上位●頭を他の馬より高い確率で推薦してください。\n'
      '\n'
      '分析依頼\n'
      'オッズ推移から以下を教えてください。\n'
      '1. 勝つ確率が高そうな馬（最大3頭）と理由\n'
      '2. 積極的に消してよい馬と理由\n'
      '3. 複勝・ワイドで狙える馬（単複比・複勝変動に注目）\n'
      '4. 中穴の単勝1点勝負をするとしたら、どの馬を選ぶか\n'
      '5. 人気馬＋穴馬のワイド1点勝負をする場合に選ぶとしたら、どの組み合わせを選ぶか\n'
      '6. このレースに1000円使うとしたら、どういう馬券を購入するか\n'
      '7. このレースの総評（混戦か本命か、買い方の方向性）\n'
      '\n'
      '分析の観点：\n'
      '・単勝オッズ下落10%以上は人気急上昇として注目\n'
      '・単複比が高い馬＝勝ちにくいが3着以内には絡みやすい\n'
      '・複勝の最小・最大の幅が広い馬＝市場の評価が割れている不安定な馬\n'
      '・複勝の最小・最大の幅が狭い馬＝安定して3着以内が期待されている馬\n'
      '・複勝オッズが下落している馬は3着以内の信頼度が高い\n'
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
