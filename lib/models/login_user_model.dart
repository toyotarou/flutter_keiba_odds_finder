// =============================================================================
// ファイル名   : login_user_model.dart
// 概要         : ログインユーザー1件分（ユーザーID・管理者フラグ・削除フラグ）を保持するモデル。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-06-18
// 最終更新日   : 2026-11-17
// =============================================================================

/// ログインユーザー1件分。
class LoginUserModel {
  LoginUserModel({required this.id, required this.userId, required this.isAdmin, required this.isDelete});

  factory LoginUserModel.fromJson(Map<String, dynamic> json) {
    return LoginUserModel(
      id: (json['id'] as int?) ?? 0,
      userId: (json['user_id'] as String?) ?? '',
      isAdmin: (json['is_admin'] as int?) ?? 0,
      isDelete: (json['is_delete'] as int?) ?? 0,
    );
  }

  /// レコードID
  final int id;
  /// ユーザーID
  final String userId;
  /// 管理者フラグ
  final int isAdmin;
  /// 削除フラグ
  final int isDelete;
}
