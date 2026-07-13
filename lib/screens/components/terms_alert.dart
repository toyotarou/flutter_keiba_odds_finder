import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../parts/odds_finder_dialog.dart';
import '../parts/terms_chapter.dart';
import 'precaution_analysis.dart';

class TermsAlert extends ConsumerStatefulWidget {
  const TermsAlert({super.key});

  @override
  ConsumerState<TermsAlert> createState() => _TermsAlertState();
}

class _TermsAlertState extends ConsumerState<TermsAlert> {
  static const List<TermsChapter> _chapters = <TermsChapter>[
    TermsChapter(
      '第1条（本規約について）',
      '本規約は、「馬眼力」（以下「本サービス」）の利用に関する条件を定めるものです。本サービスをご利用いただく前に、必ず本規約をお読みください。本サービスをご利用いただいた時点で、本規約に同意いただいたものとみなします。',
    ),
    TermsChapter(
      '第2条（サービスの内容）',
      '本サービスは、JRAが公式に提供するオッズ情報および過去のオッズデータをもとに、独自のアルゴリズムによって分析・集計した情報を提供するものです。掲載している分析結果・数値・指標はすべて参考情報であり、特定のレースや馬券の的中を保証するものでは一切ございません。なお、本サービスはJRAおよびその関連団体の公式サービスとは一切関係なく、JRAの公認・推薦・監修を受けたものでもございません。JRAの商標・ロゴ・名称は各権利者に帰属します。',
    ),
    TermsChapter(
      '第3条（会員登録）',
      '本サービスの有料機能をご利用いただくには、所定の方法により会員登録をおこなっていただく必要があります。登録情報は正確かつ最新の情報をご入力ください。虚偽の情報による登録が判明した場合、当サービスは予告なくアカウントを停止・削除する場合がございます。',
    ),
    TermsChapter(
      '第4条（利用料金・支払い）',
      '本サービスの有料プランの料金・支払方法・請求サイクルは、サービス内の料金ページにて別途定めるものとします。利用者は所定の方法により料金をお支払いいただくものとします。支払いが確認できない場合、有料機能の利用を制限する場合がございます。',
    ),
    TermsChapter(
      '第5条（無料トライアル）',
      '当サービスは、新規会員を対象に無料トライアル期間を設ける場合がございます。無料トライアル期間終了後は、自動的に有料プランへ移行いたします。移行を希望されない場合は、トライアル期間終了前にキャンセル手続きをおこなってください。',
    ),
    TermsChapter(
      '第6条（キャンセル・解約）',
      '有料プランの解約は、サービス内のアカウント設定よりいつでもおこなうことができます。解約後は、現在の請求期間終了日まで有料機能をご利用いただけます。期間途中での解約による日割り返金はおこなっておりませんので、あらかじめご了承ください。',
    ),
    TermsChapter(
      '第7条（返金ポリシー）',
      '原則として、お支払いいただいた料金の返金はいたしかねます。ただし、当サービス側の重大な障害・不具合によりサービスが長期間利用できなかった場合など、当サービスが返金を適当と判断した場合はこの限りではございません。返金をご希望の場合は、サービス内のお問い合わせよりご連絡ください。',
    ),
    TermsChapter(
      '第8条（禁止事項）',
      '利用者は以下の行為をおこなってはなりません。\n・本サービスのデータ・コンテンツを無断で転載・複製・販売する行為\n・アカウントを第三者に譲渡・貸与する行為\n・本サービスへの不正アクセスやサーバーへの過度な負荷をかける行為\n・リバースエンジニアリング等により本サービスの内部構造を解析する行為\n・その他、当サービスが不適切と判断する行為',
    ),
    TermsChapter('第9条（アカウントの停止・削除）', '利用者が本規約に違反した場合、当サービスは事前通知なくアカウントの停止または削除をおこなう場合がございます。この場合、支払済みの料金の返金はいたしかねます。'),
    TermsChapter(
      '第10条（免責事項）',
      '本サービスが提供する情報はすべて参考目的のみであり、馬券の的中を保証するものではございません。競馬は公営ギャンブルであり、結果は予測不可能な要素を多分に含んでおります。馬券の購入はお客様ご自身の判断と責任においておこなっていただきますようお願いいたします。本サービスの情報を参考にしたことによる損失・損害・その他いかなる不利益についても、当サービスは一切の責任を負いかねます。また、システムの障害・メンテナンス等による一時的なサービス停止についても、同様に責任を負いかねますのでご了承ください。',
    ),
    TermsChapter(
      '第11条（サービスの変更・停止）',
      '当サービスは、利用者への事前通知なく、サービス内容の変更・機能の追加または削除・サービスの一時停止・終了をおこなう場合がございます。サービス終了の場合、可能な限り事前にお知らせするよう努めますが、これによって生じた損害についても当サービスは責任を負いかねます。',
    ),
    TermsChapter('第12条（個人情報の取り扱い）', '本サービスにおける個人情報の取り扱いについては、別途定めるプライバシーポリシーに従うものとします。'),
    TermsChapter(
      '第13条（規約の変更）',
      '当サービスは、必要に応じて本規約を変更することがございます。重要な変更の場合はサービス内または登録メールアドレス宛にお知らせいたします。変更後も本サービスをご利用いただいた場合、変更後の規約に同意いただいたものとみなします。',
    ),
    TermsChapter('第14条（準拠法・管轄裁判所）', '本規約は日本法に準拠するものとし、本サービスに関して紛争が生じた場合は、当サービス運営者の所在地を管轄する裁判所を専属的合意管轄とします。'),
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
          Text(
            '利用規約',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          SizedBox.shrink(),
        ],
      ),
    );
  }

  ///
  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Divider(color: Colors.greenAccent.withValues(alpha: 0.6), thickness: 1),
                const SizedBox(height: 16),

                Container(
                  margin: const EdgeInsets.all(3),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5)),
                  child: Column(
                    children: _chapters
                        .asMap()
                        .entries
                        .map(
                          (MapEntry<int, TermsChapter> entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: TermsChapterTile(index: entry.key + 1, chapter: entry.value),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),

        Divider(color: Colors.white.withValues(alpha: 0.5)),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('注意事項'),
              SizedBox(
                height: 50,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: () {
                            OddsFinderDialog(context: context, widget: const PrecautionAnalysis());
                          },
                          borderRadius: BorderRadius.circular(10),
                          splashColor: Colors.white.withValues(alpha: 0.2),
                          highlightColor: Colors.white.withValues(alpha: 0.1),
                          child: Container(
                            margin: const EdgeInsets.all(3),
                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('分析について', style: TextStyle(fontSize: 10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}
