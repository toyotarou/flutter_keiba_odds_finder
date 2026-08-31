class DeveloperNewsModel {
  DeveloperNewsModel({
    required this.kind,
    required this.sentDate,
    required this.diffSeconds,
    required this.time,
    required this.description,
  });

  factory DeveloperNewsModel.fromJson(Map<String, dynamic> json) {
    return DeveloperNewsModel(
      kind: (json['kind'] as String?) ?? '',
      sentDate: (json['sent_date'] as String?) ?? '',
      diffSeconds: (json['diff_seconds'] as int?) ?? 0,
      time: (json['time'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
    );
  }

  final String kind;
  final String sentDate;
  final int diffSeconds;
  final String time;
  final String description;
}
