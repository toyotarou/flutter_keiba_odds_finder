import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../extensions/extensions.dart';
import '../../models/horse_detail_model.dart';

class HorseDetailDisplayAlert extends ConsumerStatefulWidget {
  const HorseDetailDisplayAlert({super.key});

  @override
  ConsumerState<HorseDetailDisplayAlert> createState() => _HorseDetailDisplayAlertState();
}

class _HorseDetailDisplayAlertState extends ConsumerState<HorseDetailDisplayAlert>
    with ControllersMixin<HorseDetailDisplayAlert> {
  @override
  Widget build(BuildContext context) {
    final HorseDetailModel? detail = horseState.horseDetail;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[Text('詳細情報'), SizedBox.shrink()],
                ),
                Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 5),

                if (detail != null)
                  ..._buildContent(context, detail)
                else
                  const Text('詳細情報が取得できませんでした。', style: TextStyle(color: Colors.yellowAccent, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent(BuildContext context, HorseDetailModel detail) {
    return <Widget>[
      _buildBasicInfo(detail),
      Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 2),

      _buildInfoRow(label: '調教師名', value: detail.profile.trainer),
      const SizedBox(height: 5),
      _buildInfoRow(label: '総賞金', value: detail.prize.totalPrize.toCurrency(), layerDispValue: '円'),
      const SizedBox(height: 5),
      _buildInfoRow(label: '生産牧場', value: detail.profile.breeder),
      const SizedBox(height: 5),
      _buildInfoRow(label: '産地', value: detail.profile.origin),

      const SizedBox(height: 10),
      _buildSectionHeader('血統'),
      const SizedBox(height: 10),
      _buildPedigree(detail.profile),
      const SizedBox(height: 20),
      _buildSectionHeader('出走レース'),
      const SizedBox(height: 5),
      _buildRaceList(context, detail.races),
    ];
  }

  // ── 基本情報（馬名・属性） ────────────────────────────────────────

  Widget _buildBasicInfo(HorseDetailModel detail) {
    return DefaultTextStyle(
      style: const TextStyle(color: Colors.white, fontSize: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DefaultTextStyle(
            style: const TextStyle(color: Colors.white, fontSize: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[Text(detail.cname), Text(detail.profile.owner)],
            ),
          ),
          Text(detail.horseName, style: const TextStyle(color: Colors.white, fontSize: 26)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(detail.horseNameEn),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(detail.profile.sex),
                      Text(detail.profile.age),
                      const Text(' / '),
                      Text(detail.profile.coatColor),
                    ],
                  ),
                  Text(detail.profile.birthDate),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── ラベル+値 の横並び行 ─────────────────────────────────────────

  Widget _buildInfoRow({required String label, required String value, String? layerDispValue}) {
    return DefaultTextStyle(
      style: const TextStyle(fontSize: 12),
      child: Row(
        children: <Widget>[
          _labelCell(label),
          Expanded(
            flex: 2,
            child: _valueCell(text: value, layerDispValue: layerDispValue),
          ),
        ],
      ),
    );
  }

  Widget _labelCell(String text) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.2)),
        padding: const EdgeInsets.all(3),

        alignment: Alignment.center,
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _valueCell({required String text, String? layerDispValue}) {
    return Stack(
      children: <Widget>[
        if (layerDispValue != null)
          Positioned(
            right: 10,
            top: 0,
            bottom: 0,
            child: Center(
              child: Text(layerDispValue, style: const TextStyle(color: Colors.white)),
            ),
          ),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.4))),
          ),
          padding: const EdgeInsets.only(left: 10, top: 3, bottom: 3),
          child: Text(text, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.2)),
      alignment: Alignment.center,
      child: Text(title),
    );
  }

  // ── 血統 ──────────────────────────────────────────────────────────

  Widget _buildPedigree(HorseDetailProfileModel profile) {
    return DefaultTextStyle(
      style: const TextStyle(fontSize: 10, color: Colors.white),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _RoleAvatar(label: '母'),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(profile.mother)]),
              ),
              const SizedBox(width: 5),
              const Icon(Icons.arrow_back),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[Text(profile.maternalSire), Text(profile.maternalDam)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              const _RoleAvatar(label: '父'),
              const SizedBox(width: 10),
              Expanded(child: Text(profile.father)),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ],
      ),
    );
  }

  // ── 出走レース一覧 ────────────────────────────────────────────────

  Widget _buildRaceList(BuildContext context, List<HorseDetailRaceHistoryModel> races) {
    return SizedBox(
      height: context.screenSize.height / 5,
      child: ListView.separated(
        itemCount: races.length,
        separatorBuilder: (_, __) => Divider(color: Colors.white.withValues(alpha: 0.5), height: 5),
        itemBuilder: (_, int index) => _buildRaceItem(races[index]),
      ),
    );
  }

  Widget _buildRaceItem(HorseDetailRaceHistoryModel e) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.white, fontSize: 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 日付・場・レース名
            Row(
              children: <Widget>[
                Text(e.date, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                const SizedBox(width: 6),
                Text(e.basho, style: const TextStyle(color: Colors.greenAccent, fontSize: 10)),
                const SizedBox(width: 6),
                Expanded(child: Text(e.raceName, maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 3),

            // 距離・馬場・頭数
            Row(
              children: <Widget>[
                Text(e.distance),
                const SizedBox(width: 6),
                Text(e.baba),
                const SizedBox(width: 6),
                Text('${e.numHorses}頭'),
              ],
            ),
            const SizedBox(height: 3),
            // 着順・人気・騎手・タイム
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.2)),
                  child: Text('${e.chakujun}着'),
                ),
                const SizedBox(width: 6),
                Text('${e.ninki}人気'),
                const SizedBox(width: 6),
                Expanded(child: Text(e.jockey, maxLines: 1, overflow: TextOverflow.ellipsis)),
                Text(e.time, style: const TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 3),
            // 斤量・馬体重・1着馬
            Row(
              children: <Widget>[
                Text('${e.futan}kg'),
                const SizedBox(width: 6),
                Text('馬体重 ${e.bataiju}'),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    e.chakuma,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── 父・母ラベル用アバター ────────────────────────────────────────────

class _RoleAvatar extends StatelessWidget {
  const _RoleAvatar({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 10,
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
    );
  }
}
