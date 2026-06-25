import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../models/push_notifier_user_model.dart';
import '../parts/error_confirm_dialog.dart';

class PushNotifierUserListDisplayAlert extends ConsumerStatefulWidget {
  const PushNotifierUserListDisplayAlert({super.key, required this.loggedInUserId});

  final String loggedInUserId;

  @override
  ConsumerState<PushNotifierUserListDisplayAlert> createState() => _PushNotifierUserListDisplayAlertState();
}

class _PushNotifierUserListDisplayAlertState extends ConsumerState<PushNotifierUserListDisplayAlert>
    with ControllersMixin<PushNotifierUserListDisplayAlert> {
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
                const Text('プッシュ通知ユーザーリスト', style: TextStyle(fontSize: 12)),
                Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 5),
                Expanded(child: displayPushNotifierUserList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///
  Widget displayPushNotifierUserList() {
    final List<Widget> list = <Widget>[];

    for (final PushNotifierUserModel value in appParamState.keepPushNotifierUserList) {
      list.add(
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
          ),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Stack(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 12,
                    child: Text(value.id.toString(), style: const TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(value.userId)),
                ],
              ),
              Positioned(
                right: 5,
                left: 5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const SizedBox.shrink(),
                    GestureDetector(
                      onTap: () async {
                        if (value.userId == widget.loggedInUserId) {
                          errorConfirmDialog(context: context, title: 'エラー', content: 'ご自身の有効/無効を切り替えることはできません');
                          return;
                        }

                        final int newIsDelete = value.isDelete == 1 ? 0 : 1;

                        await pushNotifierUserNotifier.changePushNotifierUserDelete(
                          id: value.id,
                          isDelete: newIsDelete,
                        );

                        final List<PushNotifierUserModel> newList = appParamState.keepPushNotifierUserList.map((
                          PushNotifierUserModel e,
                        ) {
                          if (e.id == value.id) {
                            return PushNotifierUserModel(id: e.id, userId: e.userId, isDelete: newIsDelete);
                          }
                          return e;
                        }).toList();

                        appParamNotifier.setKeepPushNotifierUserList(list: newList);
                      },
                      child: Container(
                        width: 40,
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: (value.isDelete == 0) ? Colors.green[900] : Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                        ),
                        child: const Center(child: Text('有効', style: TextStyle(fontSize: 8))),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(child: Column(children: list));
  }
}
