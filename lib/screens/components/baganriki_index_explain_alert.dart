import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BaganrikiIndexExplainAlert extends ConsumerWidget {
  const BaganrikiIndexExplainAlert({super.key});

  static const List<String> _markdownContent = <String>[
    '## 馬眼力指数とは',
    '',
    'このシステムが独自に算出する、**オッズ推移を軸にした総合評価スコア**です。',
    '',
    '単純な人気順でも、オッズの瞬間値でもなく、',
    '「**市場がこの馬をどう見ているか**」の変化を多角的に捉えようとしたものです。',
    '',
    '---',
    '',
    '## 何を見ているの？',
    '',
    '大きく分けると、以下の要素を掛け合わせて算出しています。',
    '',
    '- **期待値**（OPI）— 過去の人気帯に対して、今のオッズは高いか安いか',
    '- **オッズの動き**— レース直前にかけて、どれだけ支持が集まっているか',
    '- **単複の一致感**— 単勝と複勝、どちらも同じように買われているか',
    '- **断層補正**— オッズ分布における「壁」の内側にいるか、外側にいるか',
    '',
    'これらを組み合わせることで、**「今、市場から正当に評価されているか」** を数値化しています。',
    '',
    '---',
    '',
    '## 数値の目安',
    '',
    '|指数|目安|',
    '|---|---|',
    '|**150以上**|◎ 強い支持あり|',
    '|**120以上**|○ 注目に値する|',
    '|**100前後**|△ 様子見|',
    '|**100未満**|✕ 妙味薄め|',
    '',
    '---',
    '',
    '## 断層とは',
    '',
    'オッズ分布に「大きな段差」がある場合、その境界を断層と呼んでいます。',
    '',
    '断層の内側（上位グループ）にいる馬と、外側にいる馬では、',
    '同じ指数帯でも**意味合いが変わってくる**ことがあります。',
    '',
    'このあたりは複数のパターンに分類していますが、詳細は割愛します。',
    '「断層タイプ」という言葉が出てきたら、そういうことだと思ってください。',
    '',
    '---',
    '',
    '## OPIとは',
    '',
    '**O**dds **P**opularity **I**ndex の略です。',
    '',
    '人気順別の**過去平均オッズ**と、**今のオッズ**を比較して、',
    '「割安か、割高か」を相対的に評価する指標です。',
    '',
    '例えば、3番人気の馬の過去平均単勝オッズが8倍だとして、',
    '今日のオッズが4倍なら、市場は過去より強く支持しているということになります。',
    '逆に12倍なら、相対的に過小評価されている状態です。',
    '',
    'このズレが大きいほど、何らかのシグナルが出ているとも読めます。',
    '',
    '---',
    '',
    '## ご注意',
    '',
    'この指数はオッズ推移データのみから算出されるものです。',
    '馬の能力・騎手・馬場・展開などは一切考慮していません。',
    '',
    '高い指数が「この馬が強い」を意味するのではなく、',
    '**「市場がこの馬を支持している」** という事実を反映しているにすぎません。',
    '',
    '指数はあくまで参考情報です。馬券の購入はご自身の判断でお願いします。',
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
