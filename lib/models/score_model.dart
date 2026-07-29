class ScoreModel {
  ScoreModel({required this.id, required this.name, required this.count, required this.score});

  factory ScoreModel.fromJson(Map<String, dynamic> json) {
    return ScoreModel(
      id: (json['id'] as int?) ?? 0,
      name: (json['name'] as String?) ?? '',
      count: (json['count'] as int?) ?? 0,
      score: (json['score'] as int?) ?? 0,
    );
  }

  final int id;
  final String name;
  final int count;
  final int score;
}
