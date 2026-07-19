class CourseDistHistoryModel {
  CourseDistHistoryModel({
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.bashoName,
    required this.day,
    required this.race,
    required this.raceName,
    required this.course,
    required this.dist,
  });

  factory CourseDistHistoryModel.fromJson(Map<String, dynamic> json) {
    return CourseDistHistoryModel(
      date: (json['date'] as String?) ?? '',

      kaisuu: (json['kaisuu'] as String?) ?? '',

      basho: (json['basho'] as String?) ?? '',

      bashoName: (json['basho_name'] as String?) ?? '',

      day: (json['day'] as String?) ?? '',

      race: (json['race'] as int?) ?? 0,

      raceName: (json['race_name'] as String?) ?? '',

      course: (json['course'] as String?) ?? '',

      dist: (json['dist'] as int?) ?? 0,
    );
  }

  final String date;
  final String kaisuu;
  final String basho;
  final String bashoName;
  final String day;
  final int race;
  final String raceName;
  final String course;
  final int dist;
}

////////////////////////////////////////////////////////////////

class CourseDistRaceAnalysisHorseModel {
  CourseDistRaceAnalysisHorseModel({
    required this.waku,
    required this.horseNumber,
    required this.name,
    required this.jockey,
    required this.hasExperience,
    required this.bestTimeSec,
    required this.timeRank,
    required this.runningStyle,
    required this.avgLastSurge,
    required this.jockeyChanged,
    required this.bestCondition,
    required this.conditionStats,
    required this.recentForm,
    required this.recentTrend,
    required this.courseDistStats,
    required this.records,
  });

  factory CourseDistRaceAnalysisHorseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> conditionStatsJson =
        (json['condition_stats'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    return CourseDistRaceAnalysisHorseModel(
      waku: (json['waku'] as int?) ?? 0,

      horseNumber: (json['num'] as int?) ?? 0,

      name: (json['name'] as String?) ?? '',

      jockey: (json['jockey'] as String?) ?? '',

      hasExperience: (json['has_experience'] as bool?) ?? false,

      bestTimeSec: double.tryParse(json['best_time_sec']?.toString() ?? '') ?? 0.0,

      timeRank: (json['time_rank'] as int?) ?? 0,

      runningStyle: (json['running_style'] as String?) ?? '',

      avgLastSurge: double.tryParse(json['avg_last_surge']?.toString() ?? '') ?? 0.0,

      jockeyChanged: (json['jockey_changed'] as bool?) ?? false,

      bestCondition: (json['best_condition'] as String?) ?? '',

      // ignore: always_specify_types
      conditionStats: conditionStatsJson.map((String key, value) {
        // ignore: always_specify_types
        return MapEntry(key, CourseDistConditionStatsModel.fromJson(value as Map<String, dynamic>));
      }),

      // ignore: always_specify_types
      recentForm: (json['recent_form'] as List<dynamic>? ?? <dynamic>[])
          // ignore: always_specify_types
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .toList(),

      recentTrend: (json['recent_trend'] as String?) ?? '',

      courseDistStats: CourseDistStatsModel.fromJson(
        (json['course_dist_stats'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      ),

      records: (json['records'] as List<dynamic>? ?? <dynamic>[])
          // ignore: always_specify_types
          .map((e) => CourseDistRaceRecordModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final int waku;

  /// JSON上のキーは `num`
  final int horseNumber;

  final String name;
  final String jockey;

  /// このコース×距離の出走経験があるか　　経験あり馬を優先的に見る。経験なしは未知数
  final bool hasExperience;

  /// 同コース×距離での最速タイム（秒）　　タイムが速い＝その距離への適性あり
  final double bestTimeSec;

  /// 経験馬の中での最速タイム順位　　1位に近いほど有力（ただし条件が違う場合あり）
  final int timeRank;

  /// 脚質（逃/先/中/差/追）　　展開予測に使う。逃げ馬が多い→差し有利、など
  final String runningStyle;

  /// 直線での平均伸び順位数　　プラス=追い込み型（展開次第で爆発）、マイナス=バテ型（消し候補）
  final double avgLastSurge;

  /// 前走から騎手が変わったか　　trueならrunning_styleは参考外かも
  final bool jockeyChanged;

  /// 最も複勝率が高い馬場状態　　今日の馬場状態と照合する
  final String bestCondition;

  /// 馬場状態別の成績内訳　　「この馬は重馬場が苦手」など
  final Map<String, CourseDistConditionStatsModel> conditionStats;

  /// 直近5走の着順（全距離）　　今の調子を把握
  final List<int> recentForm;

  /// 上昇/下降/安定　　上昇トレンドの馬を狙う
  final String recentTrend;

  final CourseDistStatsModel courseDistStats;

  final List<CourseDistRaceRecordModel> records;
}

////////////////////////////////////////////////////////////////

class CourseDistConditionStatsModel {
  CourseDistConditionStatsModel({required this.total, required this.win, required this.top3, required this.top3Rate});

  factory CourseDistConditionStatsModel.fromJson(Map<String, dynamic> json) {
    return CourseDistConditionStatsModel(
      total: (json['total'] as int?) ?? 0,

      win: (json['win'] as int?) ?? 0,

      top3: (json['top3'] as int?) ?? 0,

      top3Rate: double.tryParse(json['top3_rate']?.toString() ?? '') ?? 0.0,
    );
  }

  final int total;
  final int win;
  final int top3;
  final double top3Rate;
}

////////////////////////////////////////////////////////////////

class CourseDistStatsModel {
  CourseDistStatsModel({
    required this.course,
    required this.dist,
    required this.total,
    required this.win,
    required this.top3,
    required this.winRate,
    required this.top3Rate,
    required this.avgFinishing,
  });

  factory CourseDistStatsModel.fromJson(Map<String, dynamic> json) {
    return CourseDistStatsModel(
      course: (json['course'] as String?) ?? '',

      dist: (json['dist'] as int?) ?? 0,

      total: (json['total'] as int?) ?? 0,

      win: (json['win'] as int?) ?? 0,

      top3: (json['top3'] as int?) ?? 0,

      winRate: double.tryParse(json['win_rate']?.toString() ?? '') ?? 0.0,

      top3Rate: double.tryParse(json['top3_rate']?.toString() ?? '') ?? 0.0,

      avgFinishing: double.tryParse(json['avg_finishing']?.toString() ?? '') ?? 0.0,
    );
  }

  final String course;
  final int dist;
  final int total;
  final int win;
  final int top3;
  final double winRate;
  final double top3Rate;
  final double avgFinishing;
}

////////////////////////////////////////////////////////////////

class CourseDistRaceRecordModel {
  CourseDistRaceRecordModel({
    required this.date,
    required this.basho,
    required this.race,
    required this.raceName,
    required this.distRaw,
    required this.dist,
    required this.course,
    required this.finishingPosition,
    required this.numHorses,
    required this.popularity,
    required this.jockey,
    required this.condition,
    required this.time,
    required this.timeSec,
    required this.last3f,
    required this.grade,
    required this.corner1,
    required this.corner2,
    required this.corner3,
    required this.corner4,
    required this.lastSurge,
  });

  factory CourseDistRaceRecordModel.fromJson(Map<String, dynamic> json) {
    return CourseDistRaceRecordModel(
      date: (json['date'] as String?) ?? '',

      basho: (json['basho'] as String?) ?? '',

      race: (json['race'] as int?) ?? 0,

      raceName: (json['race_name'] as String?) ?? '',

      distRaw: (json['dist_raw'] as String?) ?? '',

      dist: (json['dist'] as int?) ?? 0,

      course: (json['course'] as String?) ?? '',

      finishingPosition: (json['finishing_position'] as int?) ?? 0,

      numHorses: (json['num_horses'] as int?) ?? 0,

      popularity: (json['popularity'] as int?) ?? 0,

      jockey: (json['jockey'] as String?) ?? '',

      condition: (json['condition'] as String?) ?? '',

      time: (json['time'] as String?) ?? '',

      timeSec: double.tryParse(json['time_sec']?.toString() ?? '') ?? 0.0,

      last3f: (json['last_3f'] as String?) ?? '',

      grade: (json['grade'] as String?) ?? '',

      corner1: (json['corner_1'] as int?) ?? 0,

      corner2: (json['corner_2'] as int?) ?? 0,

      corner3: (json['corner_3'] as int?) ?? 0,

      corner4: (json['corner_4'] as int?) ?? 0,

      lastSurge: double.tryParse(json['last_surge']?.toString() ?? '') ?? 0.0,
    );
  }

  final String date;
  final String basho;
  final int race;
  final String raceName;
  final String distRaw;
  final int dist;
  final String course;
  final int finishingPosition;
  final int numHorses;
  final int popularity;
  final String jockey;
  final String condition;
  final String time;
  final double timeSec;
  final String last3f;
  final String grade;
  final int corner1;
  final int corner2;
  final int corner3;
  final int corner4;
  final double lastSurge;
}
