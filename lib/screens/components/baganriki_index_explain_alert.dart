import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BaganrikiIndexExplainAlert extends ConsumerWidget {
  const BaganrikiIndexExplainAlert({super.key});

  static const List<String> _markdownContent = <String>[
    '## 馬眼力指数とは',
    '',
    '馬眼力オリジナルの指数で、**「いま、市場（馬券を買っている人たち）がこの馬をどれだけ熱く支持しているか」** を1つの数字にしたものです。',
    '',
    '人気順やその時点のオッズだけでは見えない、**「お金の集まり方」** に注目しています。',
    '',
    'なお、この指数は **画面に表示するための指標** です。AI予想の材料としてAIに渡しているわけではありません。',
    '',
    '---',
    '',
    '## 数値の目安',
    '',
    '|指数|目安|',
    '|---|---|',
    '|**150以上**|◎ 有力|',
    '|**120以上**|○ 注目|',
    '|**100前後**|△ 様子見|',
    '|**100未満**|✕ 妙味薄|',
    '',
    '**100がふつう（過去の同じ人気の馬と同じくらい）** の目安です。数字が大きいほど、ほかの同じ立場の馬よりも厚く支持されていることを表します。',
    '',
    '---',
    '',
    '## 何を見ているの？',
    '',
    '次の4つを掛け算して計算しています。',
    '',
    '### 1. 過去の同じ人気の馬と比べたオッズ（OPI）',
    '',
    'いつもの同じ人気の馬よりオッズが低ければ（＝よく買われていれば）、指数が上がります。',
    '',
    '### 2. 直前にかけてのオッズの動き',
    '',
    '発走21分前から6分前にかけて、単勝オッズがどれだけ下がったか（＝買われたか）を見ます。オッズが下がっていれば指数が上がり、上がっていれば（売られていれば）指数が下がります。',
    '',
    '### 3. 複勝での支持の強さ',
    '',
    '単勝の人気と、複勝の人気を比べます。',
    '',
    'たとえば **単勝は6番人気なのに、複勝では3番人気** という馬は、「勝ちきるかは分からないけど、3着以内には来そう」と見ている人が多いということ。こういう馬は指数が上がります。',
    '',
    '逆に、単勝の人気に比べて複勝の人気が低い馬は、指数が下がります。',
    '',
    '### 4. オッズの壁（断層）の位置',
    '',
    '人気順に並べたとき、隣どうしのオッズが2倍以上離れている場所を **「断層（オッズの壁）」** と呼んでいます。壁の上にいる馬は、それより下の馬とはハッキリ評価が分かれている、ということです。',
    '',
    '- **壁より上の馬** → 指数を1割アップ',
    '- **壁より下の馬** → 指数を1割ダウン',
    '- **壁が見当たらないレース、単勝と複勝で壁の出方が食い違うレース** → 増減なし',
    '',
    '---',
    '',
    '## OPIとは',
    '',
    '**O**ver **P**opularity **I**ndex（人気の過熱度）の略です。',
    '',
    '**過去の同じ人気順の馬の平均オッズ** を、**今回のオッズ** で割って計算します。',
    '',
    'たとえば、3番人気の馬の過去の平均単勝オッズが8倍だとします。',
    '',
    '- 今日の3番人気が **4倍** なら → OPIは **2.0**。いつもの3番人気より、ずっと買われている',
    '- 今日の3番人気が **8倍** なら → OPIは **1.0**。いつもどおり',
    '- 今日の3番人気が **16倍** なら → OPIは **0.5**。いつもの3番人気ほどは買われていない',
    '',
    '数字が大きいほど「いつもより人気が集まっている」、小さいほど「いつもより人気がない」という意味です。',
    '',
    '---',
    '',
    '## ご注意',
    '',
    '- この指数は、**オッズの動きだけ** から計算しています。馬の実力・騎手・馬場・展開などは考慮していません。',
    '- 指数が高いのは、「この馬が強い」という意味ではなく、**「この馬に多くのお金が集まっている」** という意味です。',
    '- 人気が集まっている馬は、そのぶん配当が安くなります。指数だけでなく、オッズとのバランスも見ながらご活用ください。',
    '- オッズが取得できていないなど、計算に必要なデータがそろわない馬は、指数が表示されないことがあります。',
    '- 指数はあくまで参考情報です。馬券の購入は、ご自身の判断と責任でお楽しみください。',
  ];

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
                  Text('馬眼力指数について', style: TextStyle(color: Colors.white, fontSize: 12)),
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
                    data: _markdownContent.join('\n'),
                    styleSheet: MarkdownStyleSheet(
                      h2: const TextStyle(fontSize: 13, color: Colors.greenAccent, fontWeight: FontWeight.bold),
                      h3: const TextStyle(fontSize: 12, color: Colors.yellowAccent, fontWeight: FontWeight.bold),
                      p: const TextStyle(fontSize: 11, color: Colors.white),
                      strong: const TextStyle(fontSize: 11, color: Colors.yellowAccent, fontWeight: FontWeight.bold),
                      listBullet: const TextStyle(fontSize: 11, color: Colors.white70),
                      tableHead: const TextStyle(fontSize: 11, color: Colors.greenAccent, fontWeight: FontWeight.bold),
                      tableBody: const TextStyle(fontSize: 11, color: Colors.white),
                      tableBorder: TableBorder.all(color: Colors.white24),
                      horizontalRuleDecoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.white24)),
                      ),
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
