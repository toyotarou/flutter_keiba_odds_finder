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

  final int id;
  final String userId;
  final int isAdmin;
  final int isDelete;
}
