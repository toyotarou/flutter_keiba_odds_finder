import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../models/race_introspection_model.dart';
import '../../models/race_result_history_model.dart';
import '../../models/summary_model.dart';
import '../../utility/functions.dart';

class RaceIntrospectionDisplayAlert extends ConsumerStatefulWidget {
  const RaceIntrospectionDisplayAlert({super.key});

  @override
  ConsumerState<RaceIntrospectionDisplayAlert> createState() => _RaceIntrospectionDisplayAlertState();
}

class _RaceIntrospectionDisplayAlertState extends ConsumerState<RaceIntrospectionDisplayAlert>
    with ControllersMixin<RaceIntrospectionDisplayAlert> {
  Map<int, List<RaceResultHistoryModel>> _battleRecordMap = <int, List<RaceResultHistoryModel>>{};

  ///
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchHorseBattleRecords());
  }

  ///
  RaceIntrospectionModel? get _model {
    final List<SummaryModel> list = summaryState.oneRaceSummaryList;
    if (list.isEmpty) {
      return null;
    }
    final SummaryModel s = list.first;
    final int kaisuu = int.tryParse(s.kaisuu) ?? 0;
    return findRaceIntrospection(
      raceIntrospectionState.raceIntrospectionMap,
      date: s.date,
      kaisuu: kaisuu,
      basho: s.basho,
      day: s.day,
      race: s.race,
    );
  }

  ///
  @override
  Widget build(BuildContext context) {
    final RaceIntrospectionModel? model = _model;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildHeader(model),
              Divider(color: Colors.white.withValues(alpha: 0.5), thickness: 5),
              Expanded(child: _buildBody(model)),
            ],
          ),
        ),
      ),
    );
  }

  ///
  static Map<int, String> _parsePickupHorses(String introspection) {
    final Map<int, String> result = <int, String>{};
    final List<String> lines = introspection.split('\n');
    bool inPickup = false;
    for (final String line in lines) {
      final String trimmed = line.trim();
      if (trimmed == '## ピックアップ') {
        inPickup = true;
        continue;
      }
      if (inPickup) {
        if (trimmed.startsWith('## ')) {
          break;
        }
        final RegExpMatch? m = _pickupLineReg.firstMatch(trimmed);
        if (m != null) {
          final int? num = int.tryParse(m.group(1)!);
          final String name = m.group(2)?.trim() ?? '';
          if (num != null && name.isNotEmpty) {
            result[num] = name;
          }
        }
      }
    }
    return result;
  }

  ///
  Future<void> _fetchHorseBattleRecords() async {
    final RaceIntrospectionModel? model = _model;
    if (model == null || model.introspection.isEmpty) {
      return;
    }

    final Map<int, String> pickupHorses = _parsePickupHorses(model.introspection);
    final List<String> horseNames = pickupHorses.values.where((String n) => n.isNotEmpty).toList();
    if (horseNames.isEmpty) {
      return;
    }

    try {
      final Map<String, List<RaceResultHistoryModel>> byName = await fetchBattleRecordsByName(
        ref,
        horseNames: horseNames,
      );
      final Map<int, List<RaceResultHistoryModel>> result = <int, List<RaceResultHistoryModel>>{};
      for (final MapEntry<int, String> entry in pickupHorses.entries) {
        final List<RaceResultHistoryModel>? list = byName[entry.value];
        if (list != null) {
          result[entry.key] = list;
        }
      }
      if (mounted) {
        setState(() => _battleRecordMap = result);
      }
    } catch (e) {
      debugPrint('[RaceIntrospection] _fetchHorseBattleRecords error: $e');
    }
  }

  ///
  int? _pickupFinishingPosition(int? horseNum) {
    if (horseNum == null) {
      return null;
    }
    final RaceIntrospectionModel? model = _model;
    if (model == null) {
      return null;
    }
    final List<RaceResultHistoryModel>? records = _battleRecordMap[horseNum];
    if (records == null) {
      return null;
    }
    final RaceResultHistoryModel? record = records
        .where((RaceResultHistoryModel r) => r.date == model.date)
        .firstOrNull;
    if (record == null) {
      return null;
    }
    final int pos = record.finishingPosition;
    return (pos >= 1 && pos <= 3) ? pos : null;
  }

  ///
  Widget _buildHeader(RaceIntrospectionModel? model) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (model != null) ...<Widget>[
              Text('${model.date}　${model.kaisuu}回${model.basho}${model.day}日　${model.race}R'),
              if (model.raceName.isNotEmpty) Text(model.raceName),
            ],
          ],
        ),
      ),
    );
  }

  ///
  Widget _buildBody(RaceIntrospectionModel? model) {
    if (model == null || model.introspection.isEmpty) {
      return const Center(
        child: Text('振り返りデータがありません', style: TextStyle(color: Colors.white54, fontSize: 13)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Container(
        margin: const EdgeInsets.all(3),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5)),
        child: _buildContent(model.introspection),
      ),
    );
  }

  ///
  Widget _buildContent(String text) {
    final List<Widget> widgets = <Widget>[];
    final List<String> sections = text.split(RegExp(r'\n(?=##)'));

    for (final String section in sections) {
      if (section.trim().isEmpty) {
        continue;
      }
      final List<String> lines = section.split('\n');
      final String heading = lines.first.trim();

      if (heading.startsWith('##')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              heading.replaceFirst(RegExp(r'^#+\s*'), ''),
              style: const TextStyle(fontSize: 13, color: Colors.greenAccent, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }

      final List<String> contentLines = lines.skip(1).where((String l) => l.trim().isNotEmpty).toList();

      if (heading == '## ピックアップ') {
        for (final String line in contentLines) {
          widgets.add(_buildPickupRow(line.trim()));
        }
      } else if (contentLines.isNotEmpty) {
        widgets.add(
          MarkdownBody(
            data: contentLines.join('\n\n'),
            styleSheet: MarkdownStyleSheet(
              h3: const TextStyle(fontSize: 12, color: Colors.yellowAccent, fontWeight: FontWeight.bold),
              p: const TextStyle(fontSize: 11, color: Colors.white, letterSpacing: 0.8, height: 1.8),
              strong: const TextStyle(fontSize: 11, color: Colors.yellowAccent, fontWeight: FontWeight.bold),
              listBullet: const TextStyle(fontSize: 11, color: Colors.white70),
              horizontalRuleDecoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white24)),
              ),
            ),
          ),
        );
      }

      widgets.add(const SizedBox(height: 8));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }

  static final RegExp _pickupLineReg = RegExp(r'^(\d+)番\s*(.*)$');

  ///
  Widget _buildPickupRow(String line) {
    final RegExpMatch? m = _pickupLineReg.firstMatch(line);

    if (m != null) {
      final int? horseNum = int.tryParse(m.group(1)!);
      final int? rank = _pickupFinishingPosition(horseNum);
      final Color nameColor = rank != null ? const Color(0xFFFBB6CE) : Colors.white;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 36,
              child: Text('${m.group(1)}番', style: const TextStyle(fontSize: 11, color: Colors.white70)),
            ),
            Expanded(
              child: Text(m.group(2)?.trim() ?? '', style: TextStyle(fontSize: 11, color: nameColor)),
            ),
            if (rank != null)
              Container(
                width: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: raceRankColor(rank, fallback: Colors.grey.withValues(alpha: 0.3))),
                child: Text(rank.toString(), style: const TextStyle(fontSize: 11, color: Colors.white)),
              ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(line, style: const TextStyle(fontSize: 11, color: Colors.white)),
    );
  }
}
