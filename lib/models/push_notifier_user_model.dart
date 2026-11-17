// =============================================================================
// ファイル名   : push_notifier_user_model.dart
// 概要         : プッシュ通知の送信対象ユーザー1件分を保持するモデル。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-06-22
// 最終更新日   : 2026-11-17
// =============================================================================

/// プッシュ通知の送信対象ユーザー1件分。
class PushNotifierUserModel {
  PushNotifierUserModel({required this.id, required this.userId, required this.isDelete});

  factory PushNotifierUserModel.fromJson(Map<String, dynamic> json) {
    return PushNotifierUserModel(
      id: (json['id'] as int?) ?? 0,
      userId: (json['user_id'] as String?) ?? '',
      isDelete: (json['is_delete'] as int?) ?? 0,
    );
  }

  /// レコードID
  final int id;
  /// ユーザーID
  final String userId;
  /// 削除フラグ
  final int isDelete;
}
