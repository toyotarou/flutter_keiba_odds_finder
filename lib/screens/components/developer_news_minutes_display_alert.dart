import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../extensions/extensions.dart';
import '../../models/developer_news_model.dart';

class DeveloperNewsMinutesDisplayAlert extends ConsumerStatefulWidget {
  const DeveloperNewsMinutesDisplayAlert({super.key});

  @override
  ConsumerState<DeveloperNewsMinutesDisplayAlert> createState() => _DeveloperNewsMinutesDisplayAlertState();
}

class _DeveloperNewsMinutesDisplayAlertState extends ConsumerState<DeveloperNewsMinutesDisplayAlert>
    with ControllersMixin<DeveloperNewsMinutesDisplayAlert> {
  ///
  @override
  Widget build(BuildContext context) {
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
                const Text('developer news minutes', style: TextStyle(fontSize: 12)),
                Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 5),
                Expanded(child: displayDeveloperNewsList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///
  Widget displayDeveloperNewsList() {
    final List<Widget> list = <Widget>[];

    final Set<String> set = <String>{};

    const List<String> youbiList = <String>['月', '火', '水', '木', '金', '土', '日'];

    for (int h = 5; h <= 23; h++) {
      for (int m = 0; m <= 59; m++) {
        final String time = '$h:${m.toString().padLeft(2, '0')}';

        if (appParamState.keepDeveloperNewsTimeMap[time] != null) {
          final List<DeveloperNewsModel> sortedList = List<DeveloperNewsModel>.from(
            appParamState.keepDeveloperNewsTimeMap[time]!,
          )..sort((DeveloperNewsModel a, DeveloperNewsModel b) => a.sentDate.compareTo(b.sentDate));

          for (final DeveloperNewsModel item in sortedList) {
            if (set.add(item.kind)) {
              list.add(
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(color: Colors.yellowAccent.withValues(alpha: 0.1)),
                  child: DefaultTextStyle(
                    style: const TextStyle(fontSize: 12),
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 50, child: Text(time)),
                        Expanded(child: Text(item.kind, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ),
                ),
              );

              final List<DeveloperNewsModel> kindList = List<DeveloperNewsModel>.from(
                appParamState.keepDeveloperNewsKindMap[item.kind] ?? <DeveloperNewsModel>[],
              )..sort((DeveloperNewsModel a, DeveloperNewsModel b) => a.sentDate.compareTo(b.sentDate));

              final List<Widget> list2 = <Widget>[];

              for (final DeveloperNewsModel val in kindList) {
                if (val.diffSeconds > 0) {
                  final String youbi = youbiList[DateTime.parse(val.sentDate).weekday - 1];

                  list2.add(
                    Stack(
                      children: <Widget>[
                        Container(
                          width: context.screenSize.width / 8,
                          margin: const EdgeInsets.only(top: 2, right: 2, left: 2, bottom: 25),
                          padding: const EdgeInsets.all(2),
                          alignment: Alignment.topRight,
                          decoration: BoxDecoration(border: Border.all(color: Colors.white.withValues(alpha: 0.5))),
                          child: Text(
                            (val.diffSeconds >= 60)
                                ? '${val.diffSeconds ~/ 60}分${val.diffSeconds % 60}秒'
                                : '${val.diffSeconds % 60}秒',

                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: DefaultTextStyle(
                            style: const TextStyle(fontSize: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text('${val.sentDate.split('-')[1]}-${val.sentDate.split('-')[2]}'),
                                Text(youbi),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }

              list.add(
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: list2),
                ),
              );

              list.add(const SizedBox(height: 20));
            }
          }
        }
      }
    }

    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: list),
    );
  }
}
