class PushNotifierUserModel {
  PushNotifierUserModel({required this.id, required this.userId, required this.isDelete});

  factory PushNotifierUserModel.fromJson(Map<String, dynamic> json) {
    return PushNotifierUserModel(
      id: (json['id'] as int?) ?? 0,
      userId: (json['user_id'] as String?) ?? '',
      isDelete: (json['is_delete'] as int?) ?? 0,
    );
  }

  final int id;
  final String userId;
  final int isDelete;
}
