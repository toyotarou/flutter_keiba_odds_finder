import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/horse_detail_model.dart';
import '../../models/shutsuba_history_model.dart';
import '../../utility/functions.dart';

class HorseDetailDisplayAlert extends ConsumerStatefulWidget {
  const HorseDetailDisplayAlert({super.key});

  @override
  ConsumerState<HorseDetailDisplayAlert> createState() => _HorseDetailDisplayAlertState();
}

class _HorseDetailDisplayAlertState extends ConsumerState<HorseDetailDisplayAlert>
    with ControllersMixin<HorseDetailDisplayAlert> {
  List<ShutsubaHistoryModel>? _shutsubaHistoryList;
  String _fetchedHorseName = '';

  ///
  Future<void> _fetchShutsubaHistory(String horseName) async {
    if (horseName.isEmpty) {
      return;
    }
    try {
      final dynamic response = await ref
          .read(httpClientProvider)
          .get(path: APIPath.getHorseOddsFinderShutsubaHistory, queryParameters: <String, dynamic>{'names': horseName});
      final List<dynamic> dataList = (response as Map<String, dynamic>)['data'] as List<dynamic>? ?? <dynamic>[];
      final List<ShutsubaHistoryModel> list = dataList
          .map((dynamic item) => ShutsubaHistoryModel.fromJson(item as Map<String, dynamic>))
          .where((ShutsubaHistoryModel m) => m.name == horseName)
          .toList();
      if (mounted) {
        setState(() => _shutsubaHistoryList = list);
      }
    } catch (_) {}
  }

  ///
  @override
  Widget build(BuildContext context) {
    final HorseDetailModel? detail = horseState.horseDetail;

    if (detail != null && detail.horseName != _fetchedHorseName) {
      _fetchedHorseName = detail.horseName;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _fetchShutsubaHistory(detail.horseName);
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.all(20),

            child: (detail != null)
                ? Container(
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildContent(context, detail),
                    ),
                  )
                : const Text('詳細情報が取得できませんでした。', style: TextStyle(color: Colors.yellowAccent, fontSize: 12)),
          ),
        ),
      ),
    );
  }

  ///
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
      _buildRaceRecordHeader(title: '出走レース', detail: detail),
      const SizedBox(height: 5),

      _displayShutsubaHistoryList(),
    ];
  }

  ///
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

  ///
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

  ///
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

  ///
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

  ///
  Widget _buildSectionHeader(String title) {
    return Container(
      decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.2)),
      padding: const EdgeInsets.only(left: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[Text(title), const SizedBox.shrink()],
      ),
    );
  }

  ///
  Widget _buildRaceRecordHeader({required String title, required HorseDetailModel detail}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.2)),
      padding: const EdgeInsets.only(left: 10),
      child: Text(title),
    );
  }

  ///
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

  ///
  Widget _displayShutsubaHistoryList() {
    final List<Widget> list = <Widget>[];

    if (_shutsubaHistoryList == null) {
      list.add(const Text('読み込み中...', style: TextStyle(color: Colors.white54, fontSize: 11)));
    } else if (_shutsubaHistoryList!.isEmpty) {
      list.add(const Text('出走履歴がありません。', style: TextStyle(color: Colors.white54, fontSize: 11)));
    } else {
      for (final ShutsubaHistoryModel e in _shutsubaHistoryList!) {
        list.add(
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(5),
            ),

            child: DefaultTextStyle(
              style: const TextStyle(fontSize: 10, color: Colors.white),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SizedBox(width: 60, child: Text(e.date)),

                      SizedBox(width: 60, child: Text('${e.basho} ${e.race}R')),

                      Expanded(
                        child: Text(
                          e.raceName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Container(
                            width: 50,
                            margin: const EdgeInsets.only(top: 10, left: 10),
                            padding: const EdgeInsets.all(3),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
                            child: Text('${e.popularity} / ${e.numHorses}'),
                          ),

                          const Text('人気度'),
                        ],
                      ),

                      Stack(
                        children: <Widget>[
                          Container(
                            width: 50,
                            margin: const EdgeInsets.only(top: 10, left: 10),
                            padding: const EdgeInsets.all(3),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),

                              color: raceRankColor(e.finishingPosition > 0 ? e.finishingPosition : null, alpha: 0.3),
                            ),
                            child: Text('${e.finishingPosition} / ${e.numHorses}'),
                          ),

                          const Text('着順'),
                        ],
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('${e.course} ${e.dist}'),
                                Text('${e.horseWeight} / ${e.condition}'),
                              ],
                            ),

                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
                                    padding: const EdgeInsets.all(1),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                    ),
                                    child: Text('${e.corner1}'),
                                  ),
                                ),

                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
                                    padding: const EdgeInsets.all(1),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                    ),
                                    child: Text('${e.corner2}'),
                                  ),
                                ),

                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
                                    padding: const EdgeInsets.all(1),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                    ),
                                    child: Text('${e.corner3}'),
                                  ),
                                ),

                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
                                    padding: const EdgeInsets.all(1),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                    ),
                                    child: Text('${e.corner4}'),
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[Text(e.time), Text(e.last3f)],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (e.finishingPosition == 1) ...<Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[Text('2着: ${e.finHorse}'), Text('2着との差: ${e.finTimeDiff}')],
                    ),
                  ] else ...<Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[Text('1着: ${e.finHorse}'), Text('1着との差: ${e.finTimeDiff}')],
                    ),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[Text('騎手: ${e.jockey}'), const SizedBox.shrink()],
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return Expanded(
      child: SingleChildScrollView(child: Column(children: list)),
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
