import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../models/race_introspection_model.dart';
import '../../models/summary_model.dart';

class RaceIntrospectionDisplayAlert extends ConsumerStatefulWidget {
  const RaceIntrospectionDisplayAlert({super.key});

  @override
  ConsumerState<RaceIntrospectionDisplayAlert> createState() => _RaceIntrospectionDisplayAlertState();
}

class _RaceIntrospectionDisplayAlertState extends ConsumerState<RaceIntrospectionDisplayAlert>
    with ControllersMixin<RaceIntrospectionDisplayAlert> {
  ///
  RaceIntrospectionModel? get _model {
    final List<SummaryModel> list = summaryState.oneRaceSummaryList;
    if (list.isEmpty) {
      return null;
    }
    final SummaryModel s = list.first;
    final int kaisuu = int.tryParse(s.kaisuu) ?? 0;
    return raceIntrospectionState.raceIntrospectionMap.values
        .where(
          (RaceIntrospectionModel e) => e.date == s.date && e.race == s.race && e.kaisuu == kaisuu && e.day == s.day,
        )
        .firstOrNull;
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
      final bool hasRankLines = contentLines.any((String l) => RegExp(r'^\d+着').hasMatch(l.trim()));

      if (hasRankLines) {
        for (final String line in contentLines) {
          final String trimmed = line.trim();
          if (trimmed.isEmpty) {
            continue;
          }
          widgets.add(_buildRankRow(trimmed));
        }
      } else if (contentLines.isNotEmpty) {
        widgets.add(
          MarkdownBody(
            data: contentLines.join('\n'),
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

  static final RegExp _rankLineReg = RegExp(r'^(\d+)着[:\s：]*(\d+)番\s*(.*)$');

  ///
  Widget _buildRankRow(String line) {
    final RegExpMatch? m = _rankLineReg.firstMatch(line);

    if (m != null) {
      final String rank = '${m.group(1)}着';
      final String number = '${m.group(2)}番';
      final String name = m.group(3)?.trim() ?? '';

      Widget? resultIcon;
      if (line.contains('（的中）')) {
        resultIcon = const Icon(Icons.radio_button_unchecked, color: Colors.greenAccent, size: 14);
      } else if (line.contains('（不的中）')) {
        resultIcon = const Icon(Icons.close, color: Colors.redAccent, size: 14);
      }

      return Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 32,
              child: Text(rank, style: const TextStyle(fontSize: 11, color: Colors.white)),
            ),
            SizedBox(
              width: 44,
              child: Text(number, style: const TextStyle(fontSize: 11, color: Colors.white)),
            ),
            Expanded(
              child: Text(name, style: const TextStyle(fontSize: 11, color: Colors.white)),
            ),
            if (resultIcon != null) resultIcon,
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
