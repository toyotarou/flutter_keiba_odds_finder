class HorseDetailModel {
  HorseDetailModel({
    required this.cname,
    required this.horseName,
    required this.horseNameEn,
    required this.profile,
    required this.prize,
    required this.races,
    required this.stats,
  });

  factory HorseDetailModel.fromJson(Map<String, dynamic> json) {
    return HorseDetailModel(
      cname: json['cname']?.toString() ?? '',
      horseName: json['horse_name']?.toString() ?? '',
      horseNameEn: json['horse_name_en']?.toString() ?? '',
      profile: HorseDetailProfileModel.fromJson(json['profile'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      prize: HorseDetailPrizeModel.fromJson(json['prize'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      races: (json['races'] as List<dynamic>? ?? <dynamic>[])
          // ignore: always_specify_types
          .map((e) => HorseDetailRaceHistoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      stats: HorseDetailStatsModel.fromJson(json['stats'] as Map<String, dynamic>? ?? <String, dynamic>{}),
    );
  }

  final String cname;       // JRAレース結果ページへのアクセスキー
  final String horseName;   // 馬名（日本語）
  final String horseNameEn; // 馬名（英語）

  final HorseDetailProfileModel profile; // プロフィール（血統・調教師など）
  final HorseDetailPrizeModel prize;     // 賞金情報

  final List<HorseDetailRaceHistoryModel> races; // 出走レース履歴

  final HorseDetailStatsModel stats; // レース条件別成績

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'cname': cname,
      'horse_name': horseName,
      'horse_name_en': horseNameEn,
      'profile': profile.toJson(),
      'prize': prize.toJson(),
      'races': races.map((HorseDetailRaceHistoryModel e) => e.toJson()).toList(),
      'stats': stats.toJson(),
    };
  }
}

////////////////////////////////////////////////////////////////////////

class HorseDetailProfileModel {
  HorseDetailProfileModel({
    required this.father,
    required this.sex,
    required this.owner,
    required this.mother,
    required this.age,
    required this.trainer,
    required this.maternalSire,
    required this.birthDate,
    required this.breeder,
    required this.maternalDam,
    required this.coatColor,
    required this.origin,
    required this.nameMeaning,
    required this.market,
  });

  factory HorseDetailProfileModel.fromJson(Map<String, dynamic> json) {
    return HorseDetailProfileModel(
      father: json['father']?.toString() ?? '',
      sex: json['sex']?.toString() ?? '',
      owner: json['owner']?.toString() ?? '',
      mother: json['mother']?.toString() ?? '',
      age: json['age']?.toString() ?? '',
      trainer: json['trainer']?.toString() ?? '',
      maternalSire: json['maternal_sire']?.toString() ?? '',
      birthDate: json['birth_date']?.toString() ?? '',
      breeder: json['breeder']?.toString() ?? '',
      maternalDam: json['maternal_dam']?.toString() ?? '',
      coatColor: json['coat_color']?.toString() ?? '',
      origin: json['origin']?.toString() ?? '',
      nameMeaning: json['name_meaning']?.toString() ?? '',
      market: json['market']?.toString() ?? '',
    );
  }

  final String father;       // 父（種牡馬名）
  final String sex;          // 性別（牡・牝・騸）
  final String owner;        // 馬主名
  final String mother;       // 母（繁殖牝馬名）
  final String age;          // 馬齢
  final String trainer;      // 調教師名
  final String maternalSire; // 母の父（母方の種牡馬）
  final String birthDate;    // 生年月日
  final String breeder;      // 生産牧場
  final String maternalDam;  // 母の母（母方の祖母）
  final String coatColor;    // 毛色（青鹿毛・栗毛など）
  final String origin;       // 産地（生産地）
  final String nameMeaning;  // 馬名意味
  final String market;       // 取引市場（セリに出品された市場名）

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'father': father,
      'sex': sex,
      'owner': owner,
      'mother': mother,
      'age': age,
      'trainer': trainer,
      'maternal_sire': maternalSire,
      'birth_date': birthDate,
      'breeder': breeder,
      'maternal_dam': maternalDam,
      'coat_color': coatColor,
      'origin': origin,
      'name_meaning': nameMeaning,
      'market': market,
    };
  }
}

////////////////////////////////////////////////////////////////////////

class HorseDetailPrizeModel {
  HorseDetailPrizeModel({
    required this.totalPrize,
    required this.bonusPrize,
    required this.localPrize,
    required this.overseasPrize,
    required this.flatEarnedPrize,
    required this.hurdleEarnedPrize,
  });

  factory HorseDetailPrizeModel.fromJson(Map<String, dynamic> json) {
    return HorseDetailPrizeModel(
      totalPrize: json['total_prize']?.toString() ?? '',
      bonusPrize: json['bonus_prize']?.toString() ?? '',
      localPrize: json['local_prize']?.toString() ?? '',
      overseasPrize: json['overseas_prize']?.toString() ?? '',
      flatEarnedPrize: json['flat_earned_prize']?.toString() ?? '',
      hurdleEarnedPrize: json['hurdle_earned_prize']?.toString() ?? '',
    );
  }

  final String totalPrize;        // 総賞金（獲得賞金の合計）
  final String bonusPrize;        // 内付加賞（基本賞金に上乗せされる賞金）
  final String localPrize;        // 内地方賞金（地方競馬で獲得した賞金）
  final String overseasPrize;     // 内海外賞金（海外レースで獲得した賞金）
  final String flatEarnedPrize;   // 収得賞金・平地（平地レースの出走資格に使われる累積賞金）
  final String hurdleEarnedPrize; // 収得賞金・障害（障害レースの出走資格に使われる累積賞金）

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'total_prize': totalPrize,
      'bonus_prize': bonusPrize,
      'local_prize': localPrize,
      'overseas_prize': overseasPrize,
      'flat_earned_prize': flatEarnedPrize,
      'hurdle_earned_prize': hurdleEarnedPrize,
    };
  }
}

////////////////////////////////////////////////////////////////////////

class HorseDetailRaceHistoryModel {
  HorseDetailRaceHistoryModel({
    required this.date,
    required this.basho,
    required this.raceName,
    required this.distance,
    required this.baba,
    required this.numHorses,
    required this.ninki,
    required this.chakujun,
    required this.jockey,
    required this.futan,
    required this.bataiju,
    required this.time,
    required this.rt,
    required this.chakuma,
  });

  factory HorseDetailRaceHistoryModel.fromJson(Map<String, dynamic> json) {
    return HorseDetailRaceHistoryModel(
      date: json['date']?.toString() ?? '',
      basho: json['basho']?.toString() ?? '',
      raceName: json['race_name']?.toString() ?? '',
      distance: json['distance']?.toString() ?? '',
      baba: json['baba']?.toString() ?? '',
      numHorses: json['num_horses']?.toString() ?? '',
      ninki: json['ninki']?.toString() ?? '',
      chakujun: json['chakujun']?.toString() ?? '',
      jockey: json['jockey']?.toString() ?? '',
      futan: json['futan']?.toString() ?? '',
      bataiju: json['bataiju']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      rt: json['rt']?.toString() ?? '',
      chakuma: json['chakuma']?.toString() ?? '',
    );
  }

  final String date;      // 年月日（レース開催日）
  final String basho;     // 場（開催競馬場名。例：東京・阪神）
  final String raceName;  // レース名
  final String distance;  // 距離（コース種別＋距離。例：芝1600・ダ1200）
  final String baba;      // 馬場（馬場状態：良・稍重・重・不良）
  final String numHorses; // 頭数（出走頭数）
  final String ninki;     // 人気（単勝オッズ順位。1が最も支持が高い）
  final String chakujun;  // 着順（ゴールした順位）
  final String jockey;    // 騎手名
  final String futan;     // 負担重量＝斤量（騎手＋鞍など装具の合計kg）
  final String bataiju;   // 馬体重（レース当日の馬の体重 kg）
  final String time;      // タイム（レースの走破タイム）
  final String rt;        // Rt＝レーティング（重賞・オープン特別のみ付与される国際評価値）
  final String chakuma;   // 1着馬（2着馬）（このレースで1着になった馬名。2着以下の場合は2着馬名）

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'date': date,
      'basho': basho,
      'race_name': raceName,
      'distance': distance,
      'baba': baba,
      'num_horses': numHorses,
      'ninki': ninki,
      'chakujun': chakujun,
      'jockey': jockey,
      'futan': futan,
      'bataiju': bataiju,
      'time': time,
      'rt': rt,
      'chakuma': chakuma,
    };
  }
}

////////////////////////////////////////////////////////////////////////

class HorseDetailStatsModel {
  HorseDetailStatsModel({
    required this.flatTotal,
    required this.hurdleTotal,
    required this.byCourse,
    required this.byPopularity,
    required this.byDistance,
    required this.byTrackCondition,
  });

  factory HorseDetailStatsModel.fromJson(Map<String, dynamic> json) {
    return HorseDetailStatsModel(
      flatTotal: HorseDetailStatsValueModel.fromJson(
        json['flat_total'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      hurdleTotal: HorseDetailStatsValueModel.fromJson(
        json['hurdle_total'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      byCourse: _parseStatsMap(json['by_course']),
      byPopularity: _parseStatsMap(json['by_popularity']),
      byDistance: _parseStatsMap(json['by_distance']),
      byTrackCondition: _parseStatsMap(json['by_track_condition']),
    );
  }

  final HorseDetailStatsValueModel flatTotal;    // 平地レース合計成績
  final HorseDetailStatsValueModel hurdleTotal;  // 障害レース合計成績

  // コース別成績（芝・ダートなどコース種別ごと）
  final Map<String, HorseDetailStatsValueModel> byCourse;

  // 人気別成績（単勝人気順位ごと）
  final Map<String, HorseDetailStatsValueModel> byPopularity;

  // 距離別成績（距離帯ごと）
  final Map<String, HorseDetailStatsValueModel> byDistance;

  // 馬場状態別成績（良・稍重・重・不良ごと）
  final Map<String, HorseDetailStatsValueModel> byTrackCondition;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'flat_total': flatTotal.toJson(),
      'hurdle_total': hurdleTotal.toJson(),
      // ignore: always_specify_types
      'by_course': byCourse.map((String key, HorseDetailStatsValueModel value) => MapEntry(key, value.toJson())),
      // ignore: always_specify_types
      'by_popularity': byPopularity.map(
        // ignore: always_specify_types
        (String key, HorseDetailStatsValueModel value) => MapEntry(key, value.toJson()),
      ),
      // ignore: always_specify_types
      'by_distance': byDistance.map((String key, HorseDetailStatsValueModel value) => MapEntry(key, value.toJson())),
      // ignore: always_specify_types
      'by_track_condition': byTrackCondition.map(
        // ignore: always_specify_types
        (String key, HorseDetailStatsValueModel value) => MapEntry(key, value.toJson()),
      ),
    };
  }

  static Map<String, HorseDetailStatsValueModel> _parseStatsMap(dynamic json) {
    final Map<String, dynamic> map = json as Map<String, dynamic>? ?? <String, dynamic>{};

    return map.map(
      // ignore: always_specify_types
      (String key, value) => MapEntry(key, HorseDetailStatsValueModel.fromJson(value as Map<String, dynamic>)),
    );
  }
}

////////////////////////////////////////////////////////////////////////

class HorseDetailStatsValueModel {
  HorseDetailStatsValueModel({
    required this.first,
    required this.second,
    required this.third,
    required this.fourthOrLower,
    required this.starts,
    required this.winRate,
    required this.placeRate,
    required this.showRate,
  });

  factory HorseDetailStatsValueModel.fromJson(Map<String, dynamic> json) {
    return HorseDetailStatsValueModel(
      first: json['first']?.toString() ?? '',
      second: json['second']?.toString() ?? '',
      third: json['third']?.toString() ?? '',
      fourthOrLower: json['fourth_or_lower']?.toString() ?? '',
      starts: json['starts']?.toString() ?? '',
      winRate: json['win_rate']?.toString() ?? '',
      placeRate: json['place_rate']?.toString() ?? '',
      showRate: json['show_rate']?.toString() ?? '',
    );
  }

  final String first;          // 1着回数
  final String second;         // 2着回数
  final String third;          // 3着回数
  final String fourthOrLower;  // 4着以下回数
  final String starts;         // 出走回数（合計）
  final String winRate;        // 勝率（1着 ÷ 出走回数）
  final String placeRate;      // 連対率（1・2着 ÷ 出走回数）
  final String showRate;       // 複勝率（1〜3着 ÷ 出走回数）

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'first': first,
      'second': second,
      'third': third,
      'fourth_or_lower': fourthOrLower,
      'starts': starts,
      'win_rate': winRate,
      'place_rate': placeRate,
      'show_rate': showRate,
    };
  }
}
