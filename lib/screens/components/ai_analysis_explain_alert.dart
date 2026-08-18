import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../parts/odds_finder_dialog.dart';
import 'ai_second_explain_alert.dart';
import 'baganriki_brain_display_alert.dart';

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
      'レース発走の直前まで収集した **単勝・複勝オッズの動き** をもとに、AIが注目馬をピックアップしています。\n'
      '\n'
      '出走頭数に応じて、以下の頭数を選出します。\n'
      '\n'
      '- **8頭以下** → 4頭を選出\n'
      '- **9〜13頭** → 5頭を選出\n'
      '- **14頭以上** → 6頭を選出\n'
      '\n'
      'AIへの指示で最も重視しているのは **「当てること」ではなく「回収率を上げること」** です。1〜3番人気ばかりを選んで当てても低オッズのため回収率は上がりません。そのため **信頼度（来そうか）** と **妙味（そのオッズで買う価値があるか）** の2軸で馬を評価するよう指示しています。\n'
      '\n'
      '---\n'
      '\n'
      '## おすすめ度とは\n'
      '\n'
      '各選出馬には **おすすめ度**（100点満点）が付与されます。おすすめ度が高い順に表示されます。\n'
      '\n'
      'おすすめ度は以下の **2軸の合計** です。\n'
      '\n'
      '### 信頼度（60点分）— 来そうかどうか\n'
      '\n'
      '- 複勝オッズが継続的に下落している → 高評価\n'
      '- 断層の上側に位置している → 高評価\n'
      '- 単勝・複勝ともに資金流入が続いている → 高評価\n'
      '- 一時的な急落のみ・複勝が上昇傾向・断層の下側 → 低評価\n'
      '\n'
      '### 妙味（40点分）— そのオッズで買う価値があるか\n'
      '\n'
      '- 複勝 **1.5倍未満** → 5点以下（来ても儲からない）\n'
      '- 複勝 **1.5〜2.5倍** → 10〜20点\n'
      '- 複勝 **2.5〜4倍** → 20〜30点\n'
      '- 複勝 **4〜7倍** → 30〜38点\n'
      '- 複勝 **7倍以上かつ継続的な資金流入あり** → 38〜40点\n'
      '\n'
      '---\n'
      '\n'
      '## オッズ間断層とは\n'
      '\n'
      '人気順が隣り合う馬どうしのオッズの開きを表す指標です。\n'
      '\n'
      'この開きが大きい地点を「断層」と呼び、断層の手前にいる馬は市場から特別な支持を受けていると判断できます。**単勝断層** と **複勝断層** の両方を算出しており、同じ位置に断層が出ている場合は特に強いシグナルとして扱います。\n'
      '\n'
      '断層の位置・パターンに応じて、AIへの選出方針も変わります（下記「断層構造タイプ」参照）。\n'
      '\n'
      '---\n'
      '\n'
      '## 断層構造タイプとは\n'
      '\n'
      '断層の出方のパターンをシステムが自動判定し、AIへの選出方針として渡しています。\n'
      '\n'
      '- **タイプA**（二重断層・上位完結型）: 6番人気以内に断層が2か所以上 → 上位人気馬を中心に選出\n'
      '- **タイプB**（上位断層型）: 上位人気との間に断層が1か所 → 断層より上のグループを重視\n'
      '- **タイプC**（中間断層型）: 中位付近に断層 → 断層上側が本命・下側は穴候補\n'
      '- **タイプD**（断層なし・混戦型）: 断層なし → 複勝支持・変化率・6〜10番人気も均等に比較\n'
      '- **タイプE**（単複矛盾型）: 単勝と複勝で断層位置が食い違う → 複勝の継続的な動きを最優先\n'
      '\n'
      '---\n'
      '\n'
      '## OPIとは\n'
      '\n'
      '**OPI（Over Popularity Index）** は、今回のオッズが過去の同じ人気順の平均オッズと比べて高いか低いかを示す指標です。\n'
      '\n'
      '- **OPI > 1.2** → 過去より低いオッズ（市場が過大評価している可能性）→ 妙味が低い\n'
      '- **OPI < 0.8** → 過去より高いオッズ（市場が過小評価している可能性）→ 妙味がある\n'
      '\n'
      'AIへのおすすめ度算出の補正材料として活用しています。\n'
      '\n'
      '---\n'
      '\n'
      '## 推定確定オッズとは\n'
      '\n'
      '6分前オッズに**人気順位別の補正係数**を掛けて算出した「発走時点での最終オッズ予測値」です。過去の全レースから人気順位ごとに「6分前→確定オッズの変動パターン」を集計し、毎日更新しています。\n'
      '\n'
      '- **補正係数 < 1** → その人気順位の馬は直前にさらに人気が集中する傾向がある（見た目より確定オッズが下がりやすい）\n'
      '- **補正係数 > 1** → その人気順位の馬は直前に売れにくい傾向がある（見た目より確定オッズが上がりやすい）\n'
      '- **±誤差が大きい** → 予測の振れ幅が大きく、参考程度に留める\n'
      '\n'
      'AIへの妙味スコア計算では、6分前オッズそのままではなくこの**推定確定オッズを基準**に使うよう指示しています。\n'
      '\n'
      '---\n'
      '\n'
      '## 厳選穴レースとは\n'
      '\n'
      'AIが選出馬の中に **6〜10番人気の馬が含まれている** と判断した場合、そのレースを「厳選穴レース」とします。\n'
      '\n'
      'ただし、6番人気以内の隣接馬間に **断層が2個以上** ある場合は、上位人気馬の支配力が高いと判断し、厳選穴レースの対象から除外されます。\n'
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
      '## 過去のレース情報とは\n'
      '\n'
      '過去の出走履歴をAIに渡し、今回のレースの頭数に応じて有力馬を絞り込んだ指標です。\n'
      '\n'
      '頭数に応じた絞り込み基準は以下のとおりです。\n'
      '\n'
      '- **8頭以下** → 上位4頭に絞り込み\n'
      '- **9〜13頭** → 上位5頭に絞り込み\n'
      '- **14頭以上** → 上位6頭に絞り込み\n'
      '\n'
      '**なお、過去のレース情報が不十分な場合は、この指標が算出されないことがあります。**\n'
      '\n'
      '---\n'
      '\n'
      '## コース統計とは\n'
      '\n'
      '同じコース（距離・芝/ダート）での過去レースをもとに、単勝・複勝それぞれの回収率が高い人気順位を集計した統計です。\n'
      '\n'
      'たとえば「2番人気の単勝回収率が高い」という傾向があれば、今回の2番人気の馬を積極的に評価する根拠のひとつになります。AIへの分析でも、この統計と今回の人気順位を照らし合わせて予想するよう伝えています。\n'
      '\n'
      '**なお、統計データが存在しないコースの場合は、この情報はプロンプトに含まれません。**\n'
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
      '単勝・複勝オッズデータ（計測開始前〜発走6分前・全時点）\n'
      ' 1番(●人気) ○○○○○○\n'
      '  単勝: [計測前]●●.●→[21分]●●.●→[18分]●●.●→[15分]●●.●→[12分]●●.●→[ 9分]●●.●→[ 6分]●●.●倍（下落 ●●.●%）\n'
      '  複勝: 計測前●●.●-●●.●倍→6分前●●.●-●●.●倍（下落 ●●.●%）  単複比: ●.●倍\n'
      '  OPI: ●.●●（妙味あり）  ※●番人気の過去平均●.●倍÷現在●.●倍\n'
      '  推定確定オッズ: ●●.●倍（±●.●●）  ※6分前●●.●倍×補正係数●.●●●●\n'
      ' 2番(●人気) ○○○○○○\n'
      '  単勝: [計測前]●●.●→...→[ 6分]●●.●倍（上昇 +●●.●%）\n'
      '  複勝: 計測前●●.●-●●.●倍→6分前●●.●-●●.●倍（上昇 +●●.●%）  単複比: ●.●倍\n'
      '  OPI: ●.●●（過剰人気）  ※●番人気の過去平均●.●倍÷現在●.●倍\n'
      '  推定確定オッズ: ●●.●倍（±●.●●）  ※6分前●●.●倍×補正係数●.●●●●\n'
      ' ...（出走頭数分続く）\n'
      '\n'
      '単勝断層テーブル（6分前単勝オッズ・隣接人気順間の比率）\n'
      '※比率が2.00以上の箇所を「断層あり」と判断しています\n'
      ' ●人気(●番)●●.●倍 → ●人気(●番)●●.●倍  比率: ●.●●  ★断層\n'
      '\n'
      '複勝断層テーブル（6分前複勝最小オッズ・隣接複勝人気順間の比率）\n'
      '※単勝断層と複勝断層が同じ位置に出ている場合は断層の信頼度が上がります\n'
      ' 複●位(●番)●.●倍 → 複●位(●番)●.●倍  比率: ●.●●  ★断層\n'
      '\n'
      '【断層構造タイプ（システム算出済み）】\n'
      'タイプ●：●●●●●●●●●●\n'
      '選出方針：●●●●●●●●●●\n'
      '\n'
      'なお、オッズ分析にあたり、下記の注目馬番も参考にしてください。\n'
      '①　オッズ間断層の調査から絞り込んだ馬番「●|●」\n'
      '②　期待数値の調査から絞り込んだ馬番「●|●|●」\n'
      '③　過去のレース情報から絞り込んだ馬番「●|●|●」\n'
      '\n'
      '【このシステムの目的（最重要）】\n'
      'このシステムの目的は「当てること」ではなく「回収率を上げること」です。\n'
      '「来そうかどうか（信頼度）」と「そのオッズで買う価値があるか（妙味）」を必ず両方考えてください。\n'
      '\n'
      'オッズ推移から注目馬を●頭選出してください。\n'
      '\n'
      '【おすすめ度の計算方法】\n'
      'おすすめ度は100点満点で、以下の2軸を合算して判断してください。\n'
      '■ 信頼度（60点分）: 複勝オッズの継続下落・断層上側・単複ともに流入継続 → 高評価\n'
      '■ 妙味（40点分）: 複勝1.5倍未満→5点以下 / 1.5〜2.5倍→10〜20点 /\n'
      '  2.5〜4倍→20〜30点 / 4〜7倍→30〜38点 / 7倍以上かつ継続流入→38〜40点\n'
      '\n'
      '分析の観点：\n'
      '・複勝オッズの動きを単勝より重視してください\n'
      '・単勝オッズ下落10%以上は人気急上昇として注目（一時的な急落は過大評価しない）\n'
      '・単複比が高い馬＝勝ちにくいが3着以内には絡みやすい\n'
      '・複勝の幅が広い馬＝市場の評価が割れている不安定な馬\n'
      '・複勝の幅が狭い馬＝安定して3着以内が期待されている馬\n'
      '・OPI>1.2は過去同人気より低オッズ（妙味低）、OPI<0.8は高オッズ（妙味高）\n'
      '・妙味スコアは6分前オッズではなく推定確定オッズを基準にする（±誤差が大きい馬は参考程度）\n'
      '\n'
      '選出馬は必ず以下の形式で●頭分出力してください。\n'
      '─────────────────────────────\n'
      '厳選穴レース|1または0\n'
      '馬番：●、馬名：○○○○○○、人気順: ●、6分前オッズ: ●●.●、おすすめ度: ●●、選出理由：〜〜〜〜〜〜〜〜（4〜5行の文章）\n'
      '─────────────────────────────\n'
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

            Row(
              children: <Widget>[
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () => OddsFinderDialog(context: context, widget: const BaganrikiBrainDisplayAlert()),
                    borderRadius: BorderRadius.circular(10),
                    splashColor: Colors.white.withValues(alpha: 0.35),
                    highlightColor: Colors.white.withValues(alpha: 0.1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'AI予想の判断基準について',
                        style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () => OddsFinderDialog(context: context, widget: const AiSecondExplainAlert()),
                    borderRadius: BorderRadius.circular(10),
                    splashColor: Colors.white.withValues(alpha: 0.35),
                    highlightColor: Colors.white.withValues(alpha: 0.1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '2nd AIの実行について',
                        style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),

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
