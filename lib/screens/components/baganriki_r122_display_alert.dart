// @ANCHOR-20261020-R122-FLUTTER  r12.2 の読取APIを表示します
//
//   ・正式公開（publication）と、いまのライブ状態（liveState）を分けて出します。
//     公開した枠は動かしません。取消は「いまの枠」と「いま出せる候補数」にだけ出ます。
//   ・暫定選出のときは星を出さず、暫定の文と理由を出します。
//   ・購入の推奨はしません（学習段階は COLLECT_ONLY のままです）。
//   ・原AI応答と予約tokenはAPIが返しません。ここにも出しません。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../models/baganriki_r122_model.dart';
import '../../utility/functions.dart';

class BaganrikiR122DisplayAlert extends ConsumerStatefulWidget {
  const BaganrikiR122DisplayAlert({required this.raceNumber, super.key});

  final int raceNumber;

  @override
  ConsumerState<BaganrikiR122DisplayAlert> createState() => _BaganrikiR122DisplayAlertState();
}

class _BaganrikiR122DisplayAlertState extends ConsumerState<BaganrikiR122DisplayAlert>
    with ControllersMixin<BaganrikiR122DisplayAlert> {
  String _raceId = '';

  ///
  @override
  void initState() {
    super.initState();

    _raceId = buildR122RaceId(
      date: appParamState.selectedScheduleDate,
      kbd: appParamState.selectedScheduleKaisuuBashoDay,
      raceNumber: widget.raceNumber,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await baganrikiR122Notifier.getR122Race(raceId: _raceId);
    });
  }

  ///
  @override
  Widget build(BuildContext context) {
    final BaganrikiR122Model? race = baganrikiR122State.raceMap[_raceId];
    final String error = baganrikiR122State.errorMap[_raceId] ?? '';
    final bool loading = baganrikiR122State.loadingRaceIds.contains(_raceId);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeader(),
            Divider(color: Colors.white.withValues(alpha: 0.5), thickness: 5),
            Expanded(child: _buildBody(race: race, error: error, loading: loading)),
          ],
        ),
      ),
    );
  }

  ///
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              '馬眼力 r12.2  $_raceId',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          GestureDetector(
            onTap: () async => baganrikiR122Notifier.reloadR122Race(raceId: _raceId),
            child: Icon(Icons.refresh, size: 18, color: Colors.white.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }

  ///
  Widget _buildBody({required BaganrikiR122Model? race, required String error, required bool loading}) {
    if (loading && race == null) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (race == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            error.isEmpty ? 'データがありません' : '読めませんでした\n$error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildStateBox(race),
          const SizedBox(height: 10),
          _buildPublicationBox(race),
          const SizedBox(height: 10),
          _buildLiveBox(race),
          const SizedBox(height: 10),
          _buildWorkerBox(race),
          const SizedBox(height: 10),
          _buildTimeBox(race),
          const SizedBox(height: 10),
          _buildNoteBox(race),
        ],
      ),
    );
  }

  ///
  Widget _box({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: const TextStyle(color: Colors.greenAccent, fontSize: 11)),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }

  ///
  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: TextStyle(color: valueColor ?? Colors.white, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  ///
  Widget _buildStateBox(BaganrikiR122Model race) {
    final List<Widget> rows = <Widget>[
      _row('表示状態', race.stateLabel),
      _row('mode', '${race.mode} / ${race.modeStatus}'),
      _row('配分モード', race.allocationMode),
      _row('判定の版', race.modePolicyId),
    ];

    if (race.isProvisional) {
      // 暫定では星を出しません（確定した波乱度としては出せません）
      rows.add(_row('暫定', race.provisionalLabel, valueColor: Colors.yellowAccent));
      rows.add(_row('暫定の理由', race.provisionalNote));
    } else if (race.displayRating != null) {
      rows.add(_row('星', '★' * race.displayRating!));
    }

    if (race.isUnresolved) {
      rows.add(_row('選出', '止めています（UNRESOLVED）', valueColor: Colors.orangeAccent));
    }

    return _box(title: 'いまの状態', children: rows);
  }

  ///
  Widget _buildPublicationBox(BaganrikiR122Model race) {
    final BaganrikiR122PublicationModel? pub = race.publication;

    if (pub == null) {
      return _box(
        title: '正式公開',
        children: <Widget>[
          const Text('まだ公開していません', style: TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      );
    }

    return _box(
      title: '正式公開（取消では動きません）',
      children: <Widget>[
        _row('公開ID', pub.publicationId),
        _row('公開時刻', pub.publishedAt),
        _row('公開した枠', pub.publicationQuota?.label ?? '—'),
        _row('目標数', pub.publicationTargetCount.toString()),
        // @ANCHOR-20261023-R122-COUNTS  正式公開時の頭数（いまの頭数は下のライブ状態）
        _row('公開時の頭数', pub.activeCount?.toString() ?? '—'),
        const SizedBox(height: 6),
        const Text('候補馬', style: TextStyle(color: Colors.white54, fontSize: 10)),
        const SizedBox(height: 4),
        Wrap(spacing: 6, runSpacing: 6, children: pub.candidates.map(_candidateChip).toList()),
        const SizedBox(height: 6),
        const Text(
          '＋5 は両AIの原公開一致を証明できた馬です',
          style: TextStyle(color: Colors.white38, fontSize: 9),
        ),
      ],
    );
  }

  ///
  Widget _candidateChip(BaganrikiR122CandidateModel c) {
    final bool cancelled = cancelledNums().contains(c.horseNo);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: cancelled
            ? Colors.grey.withValues(alpha: 0.3)
            : (c.hasProvenBonus
                  ? const Color(0xFF4CAF50).withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.12)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        cancelled
            ? '${c.horseNo}（取消）'
            : '${c.horseNo} ${c.band}${c.hasProvenBonus ? ' +5' : ''}',
        style: TextStyle(
          color: cancelled ? Colors.white38 : Colors.white,
          fontSize: 11,
          decoration: cancelled ? TextDecoration.lineThrough : TextDecoration.none,
        ),
      ),
    );
  }

  ///
  List<int> cancelledNums() {
    final BaganrikiR122Model? race = baganrikiR122State.raceMap[_raceId];

    return race?.liveState?.cancellations ?? <int>[];
  }

  ///
  Widget _buildLiveBox(BaganrikiR122Model race) {
    final BaganrikiR122LiveStateModel? live = race.liveState;

    if (live == null) {
      return _box(
        title: 'いまのライブ状態',
        children: <Widget>[
          const Text('データがありません', style: TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      );
    }

    return _box(
      title: 'いまのライブ状態（取消を映します）',
      children: <Widget>[
        _row('いまの頭数', live.activeCount?.toString() ?? '—'),
        _row('いまの枠', live.actualQuota?.label ?? '—'),
        _row('いま出せる候補', live.availableCandidateCount?.toString() ?? '—'),
        _row('取消の馬番', live.cancellations.isEmpty ? 'なし' : live.cancellations.join('・')),
        _row('目安の枠', live.liveQuota?.label ?? '—'),
        _row('版（状態）', live.stateRevision.toString()),
        _row('版（応答）', live.responseRevision.toString()),
        _row('版（公開）', live.publicationRevision.toString()),
      ],
    );
  }

  ///
  Widget _buildWorkerBox(BaganrikiR122Model race) {
    if (race.workerState.isEmpty) {
      return _box(
        title: 'AIの枠（初回0・訂正1）',
        children: <Widget>[
          const Text('まだ枠はありません', style: TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      );
    }

    return _box(
      title: 'AIの枠（初回0・訂正1）',
      children: race.workerState.map((BaganrikiR122WorkerSlotModel s) {
        final String body = '${s.status}'
            '${s.complete ? '・complete' : ''}'
            '${s.receivedAt.isEmpty ? '' : '  受領 ${s.receivedAt}'}'
            '${s.failureReason.isEmpty ? '' : '\n${s.failureReason}'}';

        return _row('${s.role} ${s.attemptLabel}', body, valueColor: _statusColor(s.status));
      }).toList(),
    );
  }

  ///
  Color _statusColor(String status) {
    switch (status) {
      case 'RECEIVED':
        return Colors.lightGreenAccent;
      case 'SENT':
      case 'RESERVED':
        return Colors.white;
      case 'FAILED':
      case 'UNKNOWN_RESULT':
        return Colors.orangeAccent;
      default:
        return Colors.white;
    }
  }

  ///
  Widget _buildTimeBox(BaganrikiR122Model race) {
    final BaganrikiR122InputAuditModel? audit = race.inputAudit;
    final BaganrikiR122LiveStateModel? live = race.liveState;
    final Map<String, dynamic> src = audit?.salesCloseSource ?? <String, dynamic>{};

    return _box(
      title: '時刻（発走時刻を起点にしています）',
      children: <Widget>[
        _row('投票締切', (audit?.salesCloseAt ?? '').isEmpty ? '—' : audit!.salesCloseAt),
        _row('締切の出どころ', (src['source'] as String?) ?? '—'),
        _row('応答期限', live?.effectiveReplyDeadline ?? '—'),
        _row('公開期限', live?.effectivePublishDeadline ?? '—'),
        _row('入力の凍結', audit?.inputFreezeAt ?? '—'),
        // @ANCHOR-20261023-R122-COUNTS  凍結したときの頭数（N）
        _row('凍結時の頭数', audit?.frozenCount?.toString() ?? '—'),
        // @ANCHOR-20261023-R122-ACQTIME  取得完了時刻（変更計画書4章「実際の取得完了時刻も表示する」）
        _row('取得完了（6分前）', (audit?.receivedAtOf(6) ?? '').isEmpty ? '—' : audit!.receivedAtOf(6)),
        _row(
          '各時点の取得',
          audit == null
              ? '—'
              : <int>[21, 18, 15, 12, 9, 6]
                    .map((int t) => '$t分前:${audit.statusOf(t) == 'ADOPTED' ? '○' : (audit.statusOf(t).isEmpty ? '—' : '×')}')
                    .join('  '),
        ),
        _row('基準', audit?.anchorKind ?? '—'),
        if ((src['rule'] as String?) != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              src['rule'] as String,
              style: const TextStyle(color: Colors.white38, fontSize: 9),
            ),
          ),
      ],
    );
  }

  ///
  Widget _buildNoteBox(BaganrikiR122Model race) {
    final List<Widget> rows = <Widget>[
      _row('学習段階', race.learningStage),
      _row('model_version', race.modelVersion ?? 'null'),
      _row('購入の扱い', race.purchasePolicyStatus),
      _row('schema', race.schemaVersion),
    ];

    if (race.shortfalls.isNotEmpty) {
      rows.add(const SizedBox(height: 6));
      rows.add(const Text('枠の不足', style: TextStyle(color: Colors.white54, fontSize: 10)));
      for (final Map<String, dynamic> s in race.shortfalls) {
        rows.add(
          Text(
            '  ${s['band'] ?? ''}帯 要求${s['requested'] ?? '-'}・適格${s['eligible'] ?? '-'}'
            '・不足${s['shortfall'] ?? '-'}'
            // @ANCHOR-20261023-R122-SHORTREASON  不足の理由（変更計画書8章「不足数と理由」）
            '${_shortfallReason(s)}',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        );
      }
    }

    if (race.diagnostics.isNotEmpty) {
      rows.add(const SizedBox(height: 6));
      rows.add(const Text('診断', style: TextStyle(color: Colors.white54, fontSize: 10)));
      for (final Map<String, dynamic> d in race.diagnostics) {
        rows.add(
          Text(
            '  ${d['code'] ?? ''}  ${d['message'] ?? ''}',
            style: const TextStyle(color: Colors.orangeAccent, fontSize: 10),
          ),
        );
      }
    }

    rows.add(const SizedBox(height: 8));
    rows.add(
      const Text(
        'この画面は記録の表示です。購入の推奨はしません。',
        style: TextStyle(color: Colors.white38, fontSize: 9),
      ),
    );

    return _box(title: '申し送り', children: rows);
  }

  /// @ANCHOR-20261023-R122-SHORTREASON  不足の理由を言葉にします
  ///   要求した枠に対して、根拠を確認できた馬（適格）が足りないことが理由です。
  ///   枠を別の帯へまわした（moved_to へ moved 頭）ときは添えます。数合わせはしていません。
  String _shortfallReason(Map<String, dynamic> s) {
    final int moved = r122IntOrNull(s['moved']) ?? 0;
    final Object? movedTo = s['moved_to'];
    final String to = movedTo is List<dynamic> ? movedTo.join('・') : '';
    final int shortfall = r122IntOrNull(s['shortfall']) ?? 0;

    final String fill = (moved > 0 && to.isNotEmpty) ? '（$moved頭ぶんの枠を他の帯（$to）へまわした）' : '';
    final String why = shortfall > 0 ? '：根拠を確認できた馬が要求数に届かないため' : '';

    return '$fill$why';
  }
}
