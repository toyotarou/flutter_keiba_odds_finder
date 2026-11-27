// =============================================================================
// ファイル名   : specified_commercial_transactions_alert.dart
// 概要         : 特定商取引法にもとづく表記の画面（Markdown）。左のメニューから開く。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-11-25
// 最終更新日   : 2026-11-25
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 特定商取引法にもとづく表記の画面。
class SpecifiedCommercialTransactionsAlert extends ConsumerStatefulWidget {
  const SpecifiedCommercialTransactionsAlert({super.key});

  @override
  ConsumerState<SpecifiedCommercialTransactionsAlert> createState() => _SpecifiedCommercialTransactionsAlertState();
}

/// 特定商取引法にもとづく表記の画面の状態。
class _SpecifiedCommercialTransactionsAlertState extends ConsumerState<SpecifiedCommercialTransactionsAlert> {
  // 【要記入】の箇所は、販売事業者（運営者）が決まりしだい書き換える。
  static const List<String> _markdownContent = <String>[
    '## 販売事業者',
    '',
    '株式会社成貴',
    '',
    '---',
    '',
    '## 運営責任者',
    '',
    '代表取締役　吉成光',
    '',
    '---',
    '',
    '## 所在地',
    '',
    '神奈川県川崎市川崎区小田5-18-7',
    '',
    '---',
    '',
    '## 電話番号',
    '',
    '044-380-0248',
    '',
    '---',
    '',
    '## メールアドレス',
    '',
    'kabunaruki427@outlook.jp',
    '',
    '---',
    '',
    '## 販売価格',
    '',
    '- スタンダードコース：月額3,300円（税込）',
    '- ミディアムコース：月額38,500円（税込）',
    '- プレミアコース：月額220,000円（税込）',
    '',
    '---',
    '',
    '## 商品代金以外の必要料金',
    '',
    '本サービスのご利用にかかるインターネット接続料金・通信料金は、お客様のご負担となります。',
    '',
    '---',
    '',
    '## お支払い方法',
    '',
    'クレジットカード決済',
    '',
    '---',
    '',
    '## お支払い時期',
    '',
    'お申し込み時に初回分をお支払いいただきます。以降は、ご契約の更新日ごとに自動でお支払いいただきます。',
    '',
    '---',
    '',
    '## サービスの提供時期',
    '',
    'お支払いの手続き完了後、ただちにご利用いただけます。',
    '',
    '---',
    '',
    '## 解約について',
    '',
    '有料プランの解約は、サービス内のアカウント設定よりいつでもおこなうことができます。解約後は、現在の請求期間終了日まで有料機能をご利用いただけます。期間途中での解約による日割り返金はおこなっておりません。',
    '',
    '---',
    '',
    '## 返品・返金について',
    '',
    'デジタルコンテンツという性質上、お支払いいただいた料金の返金はいたしかねます。ただし、当サービス側の重大な障害・不具合によりサービスが長期間利用できなかった場合など、当サービスが返金を適当と判断した場合はこの限りではございません。',
    '',
    '---',
    '',
    '## 動作環境',
    '',
    'インターネットに接続できるスマートフォン・パソコンの最新のブラウザでご利用ください。',
    '',
    '---',
    '',
    '## 特記事項',
    '',
    '本サービスが提供する情報はすべて参考情報であり、馬券の的中を保証するものではございません。馬券の購入はお客様ご自身の判断と責任においておこなってください。',
  ];

  /// 特定商取引法にもとづく表記の画面を組み立てる。
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

            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  /// 画面上部の見出しを表示する。
  Widget _buildHeader(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 12, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text('特定商取引法にもとづく表記', style: TextStyle(color: Colors.white, fontSize: 12)),
          SizedBox.shrink(),
        ],
      ),
    );
  }

  /// 表記の本文を表示する。
  Widget _buildBody(BuildContext context) {
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
            p: const TextStyle(fontSize: 11, color: Colors.white),
            listBullet: const TextStyle(fontSize: 11, color: Colors.white70),
            horizontalRuleDecoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white24)),
            ),
          ),
        ),
      ),
    );
  }
}
