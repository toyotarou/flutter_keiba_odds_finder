// @ANCHOR-20261020-R122-FLUTTER  r12.2 読取APIのモデル
//   GET /api/baganriki/r12-2/races/{race_id}
//
//   ・手書きクラスです（Freezedは使いません）。
//   ・数値は十進数文字列のまま来るものがあります。
//     一律 double にせず、文字列は文字列のまま持ちます。
//   ・正式公開（publication）と、いまのライブ状態（liveState）は別物です。
//     publicationQuota は公開したときのまま。取消はいまの枠（actualQuota）
//     と availableCandidateCount にだけ出ます。
//   ・原AI応答と予約tokenはAPIが返しません。ここにも持ちません。

/// 帯ごとの枠（A=1〜6人気／B=7〜10／D=11以下）
class BaganrikiR122QuotaModel {
  BaganrikiR122QuotaModel({required this.a, required this.b, required this.d});

  factory BaganrikiR122QuotaModel.fromJson(Map<String, dynamic> json) {
    return BaganrikiR122QuotaModel(
      a: (json['A'] as int?) ?? 0,
      b: (json['B'] as int?) ?? 0,
      d: (json['D'] as int?) ?? 0,
    );
  }

  final int a;
  final int b;
  final int d;

  int get total => a + b + d;

  String get label => '$a/$b/$d';

  Map<String, dynamic> toJson() => <String, dynamic>{'A': a, 'B': b, 'D': d};
}

/// 公開した候補馬の1頭
class BaganrikiR122CandidateModel {
  BaganrikiR122CandidateModel({
    required this.horseNo,
    required this.band,
    required this.score,
    required this.bonus,
    required this.bothPublic,
    required this.bonusProven,
    required this.independentGroups,
  });

  factory BaganrikiR122CandidateModel.fromJson(Map<String, dynamic> json) {
    return BaganrikiR122CandidateModel(
      horseNo: (json['horse_no'] as int?) ?? 0,
      band: (json['band'] as String?) ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      bonus: (json['bonus'] as num?)?.toDouble() ?? 0.0,
      bothPublic: (json['both_public'] as bool?) ?? false,
      bonusProven: (json['bonus_proven'] as bool?) ?? false,
      independentGroups: (json['independent_groups'] as int?) ?? 0,
    );
  }

  final int horseNo;
  final String band;
  final double score;
  final double bonus;
  final bool bothPublic;
  final bool bonusProven;
  final int independentGroups;

  /// 両AIの原公開一致を証明できて加点された馬か
  bool get hasProvenBonus => bonusProven && bonus > 0;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'horse_no': horseNo,
    'band': band,
    'score': score,
    'bonus': bonus,
    'both_public': bothPublic,
    'bonus_proven': bonusProven,
    'independent_groups': independentGroups,
  };
}

/// 正式公開（履歴。取消では動きません）
class BaganrikiR122PublicationModel {
  BaganrikiR122PublicationModel({
    required this.publicationId,
    required this.publishedAt,
    required this.predictionTargetCount,
    required this.predictionQuota,
    required this.publicationTargetCount,
    required this.publicationQuota,
    required this.candidates,
    this.activeCount,
  });

  factory BaganrikiR122PublicationModel.fromJson(Map<String, dynamic> json) {
    final List<BaganrikiR122CandidateModel> cands = <BaganrikiR122CandidateModel>[];
    final Object? rawCands = json['candidates'];
    if (rawCands is List<dynamic>) {
      for (final dynamic e in rawCands) {
        if (e is Map<String, dynamic>) {
          cands.add(BaganrikiR122CandidateModel.fromJson(e));
        }
      }
    }
    return BaganrikiR122PublicationModel(
      publicationId: (json['publication_id'] as String?) ?? '',
      publishedAt: (json['published_at'] as String?) ?? '',
      predictionTargetCount: (json['prediction_target_count'] as int?) ?? 0,
      predictionQuota: json['prediction_quota'] is Map<String, dynamic>
          ? BaganrikiR122QuotaModel.fromJson(json['prediction_quota'] as Map<String, dynamic>)
          : null,
      publicationTargetCount: (json['publication_target_count'] as int?) ?? 0,
      publicationQuota: json['publication_quota'] is Map<String, dynamic>
          ? BaganrikiR122QuotaModel.fromJson(json['publication_quota'] as Map<String, dynamic>)
          : null,
      candidates: cands,
      // @ANCHOR-20261023-R122-COUNTS  正式公開したときの頭数（無い版のAPIでは null）
      activeCount: r122IntOrNull(json['active_count']),
    );
  }

  final String publicationId;
  final String publishedAt;
  final int predictionTargetCount;
  final BaganrikiR122QuotaModel? predictionQuota;
  final int publicationTargetCount;
  final BaganrikiR122QuotaModel? publicationQuota;
  final List<BaganrikiR122CandidateModel> candidates;

  /// 正式公開したときの頭数（いまの頭数は liveState.activeCount）
  final int? activeCount;
}

/// いまのライブ状態（取消を映します）
class BaganrikiR122LiveStateModel {
  BaganrikiR122LiveStateModel({
    required this.stateRevision,
    required this.responseRevision,
    required this.publicationRevision,
    required this.latestPublicationId,
    required this.cancellations,
    required this.activeCount,
    required this.liveTargetCount,
    required this.liveQuota,
    required this.actualQuota,
    required this.availableCandidateCount,
    required this.liveClose,
    required this.effectivePublishDeadline,
    required this.effectiveReplyDeadline,
  });

  factory BaganrikiR122LiveStateModel.fromJson(Map<String, dynamic> json) {
    final List<int> cancels = <int>[];
    final Object? rawCancels = json['cancellations'];
    if (rawCancels is List<dynamic>) {
      for (final dynamic e in rawCancels) {
        if (e is int) {
          cancels.add(e);
        } else if (e is String) {
          final int? n = int.tryParse(e);
          if (n != null) {
            cancels.add(n);
          }
        }
      }
    }
    return BaganrikiR122LiveStateModel(
      stateRevision: (json['state_revision'] as int?) ?? 0,
      responseRevision: (json['response_revision'] as int?) ?? 0,
      publicationRevision: (json['publication_revision'] as int?) ?? 0,
      latestPublicationId: (json['latest_publication_id'] as String?) ?? '',
      cancellations: cancels,
      activeCount: json['active_count'] as int?,
      liveTargetCount: json['live_target_count'] as int?,
      liveQuota: json['live_quota'] is Map<String, dynamic>
          ? BaganrikiR122QuotaModel.fromJson(json['live_quota'] as Map<String, dynamic>)
          : null,
      actualQuota: json['actual_quota'] is Map<String, dynamic>
          ? BaganrikiR122QuotaModel.fromJson(json['actual_quota'] as Map<String, dynamic>)
          : null,
      availableCandidateCount: json['available_candidate_count'] as int?,
      liveClose: (json['live_close'] as String?) ?? '',
      effectivePublishDeadline: (json['effective_publish_deadline'] as String?) ?? '',
      effectiveReplyDeadline: (json['effective_reply_deadline'] as String?) ?? '',
    );
  }

  final int stateRevision;
  final int responseRevision;
  final int publicationRevision;
  final String latestPublicationId;
  final List<int> cancellations;
  final int? activeCount;
  final int? liveTargetCount;
  final BaganrikiR122QuotaModel? liveQuota;
  final BaganrikiR122QuotaModel? actualQuota;
  final int? availableCandidateCount;
  final String liveClose;
  final String effectivePublishDeadline;
  final String effectiveReplyDeadline;
}

/// ワーカーの枠（初回0・訂正1）。token と原応答は返りません
class BaganrikiR122WorkerSlotModel {
  BaganrikiR122WorkerSlotModel({
    required this.role,
    required this.attemptNo,
    required this.status,
    required this.complete,
    required this.reservedAt,
    required this.receivedAt,
    required this.failureReason,
  });

  factory BaganrikiR122WorkerSlotModel.fromJson(Map<String, dynamic> json) {
    return BaganrikiR122WorkerSlotModel(
      role: (json['role'] as String?) ?? '',
      attemptNo: (json['attempt_no'] as int?) ?? 0,
      status: (json['status'] as String?) ?? '',
      complete: (json['complete'] as bool?) ?? false,
      reservedAt: (json['reserved_at'] as String?) ?? '',
      receivedAt: (json['received_at'] as String?) ?? '',
      failureReason: (json['failure_reason'] as String?) ?? '',
    );
  }

  final String role;
  final int attemptNo;
  final String status;
  final bool complete;
  final String reservedAt;
  final String receivedAt;
  final String failureReason;

  String get attemptLabel => attemptNo == 0 ? '初回' : '訂正';
}

/// 入力の監査（取得の状態・coverage・締切の出どころ）
class BaganrikiR122InputAuditModel {
  BaganrikiR122InputAuditModel({
    required this.inputFreezeAt,
    required this.timeContractVersion,
    required this.anchorKind,
    required this.samplingPolicyId,
    required this.salesCloseAt,
    required this.salesCloseSource,
    required this.collectionAudit,
    required this.coverage,
    this.frozenCount,
  });

  factory BaganrikiR122InputAuditModel.fromJson(Map<String, dynamic> json) {
    return BaganrikiR122InputAuditModel(
      inputFreezeAt: (json['input_freeze_at'] as String?) ?? '',
      timeContractVersion: (json['time_contract_version'] as String?) ?? '',
      anchorKind: (json['anchor_kind'] as String?) ?? '',
      samplingPolicyId: (json['sampling_policy_id'] as String?) ?? '',
      salesCloseAt: (json['sales_close_at'] as String?) ?? '',
      salesCloseSource: json['sales_close_source'] is Map<String, dynamic>
          ? json['sales_close_source'] as Map<String, dynamic>
          : <String, dynamic>{},
      collectionAudit: json['collection_audit'] is Map<String, dynamic>
          ? json['collection_audit'] as Map<String, dynamic>
          : <String, dynamic>{},
      coverage: json['coverage'] is Map<String, dynamic>
          ? json['coverage'] as Map<String, dynamic>
          : <String, dynamic>{},
      // @ANCHOR-20261023-R122-COUNTS  凍結したときの頭数（N）
      frozenCount: r122IntOrNull(json['frozen_count']),
    );
  }

  final String inputFreezeAt;
  final String timeContractVersion;
  final String anchorKind;
  final String samplingPolicyId;
  final String salesCloseAt;
  final Map<String, dynamic> salesCloseSource;
  final Map<String, dynamic> collectionAudit;
  final Map<String, dynamic> coverage;

  /// 凍結したときの頭数（N）
  final int? frozenCount;

  /// @ANCHOR-20261023-R122-ACQTIME  そのスロットの取得完了時刻（受信を終えた実時刻）
  ///   採用できなかったスロットは空文字です。推定で埋めません。
  String receivedAtOf(int slot) {
    final Object? row = collectionAudit[slot.toString()];
    if (row is Map<String, dynamic> && row['status'] == 'ADOPTED') {
      return (row['response_received_at'] as String?) ?? '';
    }
    return '';
  }

  /// そのスロットの状態（ADOPTED／UNAVAILABLE／空）
  String statusOf(int slot) {
    final Object? row = collectionAudit[slot.toString()];
    return row is Map<String, dynamic> ? ((row['status'] as String?) ?? '') : '';
  }
}

/// @ANCHOR-20261023-R122-COUNTS  整数を読みます（数値でも数字の文字列でも）。読めなければ null
int? r122IntOrNull(Object? v) {
  if (v is int) {
    return v;
  }
  if (v is String) {
    return int.tryParse(v);
  }
  return null;
}

/// 読取APIの1レースぶん
class BaganrikiR122Model {
  BaganrikiR122Model({
    required this.schemaVersion,
    required this.raceId,
    required this.state,
    required this.mode,
    required this.modeStatus,
    required this.allocationMode,
    required this.modePolicyId,
    required this.displayRating,
    required this.provisionalLabel,
    required this.provisionalNote,
    required this.publication,
    required this.liveState,
    required this.workerState,
    required this.inputAudit,
    required this.diagnostics,
    required this.shortfalls,
    required this.buyRecommended,
    required this.purchasePolicyStatus,
    required this.learningStage,
    required this.modelVersion,
  });

  factory BaganrikiR122Model.fromJson(Map<String, dynamic> json) {
    final Object? prov = json['provisional'];
    final Map<String, dynamic> provMap = prov is Map<String, dynamic> ? prov : <String, dynamic>{};

    final List<BaganrikiR122WorkerSlotModel> slots = <BaganrikiR122WorkerSlotModel>[];
    final Object? rawSlots = json['worker_state'];
    if (rawSlots is List<dynamic>) {
      for (final dynamic e in rawSlots) {
        if (e is Map<String, dynamic>) {
          slots.add(BaganrikiR122WorkerSlotModel.fromJson(e));
        }
      }
    }

    final List<Map<String, dynamic>> diags = <Map<String, dynamic>>[];
    final Object? rawDiags = json['diagnostics'];
    if (rawDiags is List<dynamic>) {
      for (final dynamic e in rawDiags) {
        if (e is Map<String, dynamic>) {
          diags.add(e);
        }
      }
    }

    final List<Map<String, dynamic>> shorts = <Map<String, dynamic>>[];
    final Object? rawShorts = json['shortfalls'];
    if (rawShorts is List<dynamic>) {
      for (final dynamic e in rawShorts) {
        if (e is Map<String, dynamic>) {
          shorts.add(e);
        }
      }
    }

    return BaganrikiR122Model(
      schemaVersion: (json['schema_version'] as String?) ?? '',
      raceId: (json['race_id'] as String?) ?? '',
      state: (json['state'] as String?) ?? '',
      mode: (json['mode'] as String?) ?? '',
      modeStatus: (json['mode_status'] as String?) ?? '',
      allocationMode: (json['allocation_mode'] as String?) ?? '',
      modePolicyId: (json['mode_policy_id'] as String?) ?? '',
      displayRating: json['display_rating'] as int?,
      provisionalLabel: (provMap['label'] as String?) ?? '',
      provisionalNote: (provMap['note'] as String?) ?? '',
      publication: json['publication'] is Map<String, dynamic>
          ? BaganrikiR122PublicationModel.fromJson(json['publication'] as Map<String, dynamic>)
          : null,
      liveState: json['live_state'] is Map<String, dynamic>
          ? BaganrikiR122LiveStateModel.fromJson(json['live_state'] as Map<String, dynamic>)
          : null,
      workerState: slots,
      inputAudit: json['input_audit'] is Map<String, dynamic>
          ? BaganrikiR122InputAuditModel.fromJson(json['input_audit'] as Map<String, dynamic>)
          : null,
      diagnostics: diags,
      shortfalls: shorts,
      buyRecommended: (json['buy_recommended'] as bool?) ?? false,
      purchasePolicyStatus: (json['purchase_policy_status'] as String?) ?? '',
      learningStage: (json['learning_stage'] as String?) ?? '',
      modelVersion: json['model_version'] as String?,
    );
  }

  final String schemaVersion;
  final String raceId;
  final String state;
  final String mode;
  final String modeStatus;
  final String allocationMode;
  final String modePolicyId;
  final int? displayRating;
  final String provisionalLabel;
  final String provisionalNote;
  final BaganrikiR122PublicationModel? publication;
  final BaganrikiR122LiveStateModel? liveState;
  final List<BaganrikiR122WorkerSlotModel> workerState;
  final BaganrikiR122InputAuditModel? inputAudit;
  final List<Map<String, dynamic>> diagnostics;
  final List<Map<String, dynamic>> shortfalls;
  final bool buyRecommended;
  final String purchasePolicyStatus;
  final String learningStage;
  final String? modelVersion;

  /// 表示状態の日本語
  String get stateLabel {
    switch (state) {
      case 'PENDING':
        return '処理中（期限内）';
      case 'PUBLISHED':
        return '公開済み';
      case 'UNAVAILABLE':
        return '公開なし';
      case 'CANCELLED':
        return '全頭取消';
      default:
        return state;
    }
  }

  /// 暫定選出かどうか
  bool get isProvisional => modeStatus == 'PROVISIONAL';

  /// 選出を止めている状態かどうか
  bool get isUnresolved => modeStatus == 'UNRESOLVED';
}
