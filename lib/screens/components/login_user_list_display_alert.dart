import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../models/login_user_model.dart';

class LoginUserListDisplayAlert extends ConsumerStatefulWidget {
  const LoginUserListDisplayAlert({super.key, required this.loggedInUserId});

  final String loggedInUserId;

  @override
  ConsumerState<LoginUserListDisplayAlert> createState() => _LoginUserListDisplayAlertState();
}

class _LoginUserListDisplayAlertState extends ConsumerState<LoginUserListDisplayAlert>
    with ControllersMixin<LoginUserListDisplayAlert> {
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
                const Text('ログインユーザーリスト'),
                Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 5),

                Expanded(child: displayLoginUserList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///
  Widget displayLoginUserList() {
    final List<Widget> list = <Widget>[];

    appParamState.keepLoginUserMap.forEach((String key, LoginUserModel value) {
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
                    Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () async {
                            final int newIsAdmin = value.isAdmin == 1 ? 0 : 1;

                            await loginUserNotifier.changeAdmin(id: value.id, isAdmin: newIsAdmin);

                            final Map<String, LoginUserModel> newMap = Map<String, LoginUserModel>.from(
                              appParamState.keepLoginUserMap,
                            );

                            newMap[value.userId] = LoginUserModel(
                              id: value.id,
                              userId: value.userId,
                              isAdmin: newIsAdmin,
                              isDelete: value.isDelete,
                            );

                            appParamNotifier.setKeepLoginUserMap(map: newMap);
                          },
                          child: Container(
                            width: 40,
                            margin: const EdgeInsets.all(5),
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: (value.isAdmin == 1) ? Colors.green[900] : Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                            ),
                            child: const Center(child: Text('管理者', style: TextStyle(fontSize: 8))),
                          ),
                        ),

                        GestureDetector(
                          onTap: () async {
                            final int newIsDelete = value.isDelete == 1 ? 0 : 1;

                            await loginUserNotifier.changeDelete(id: value.id, isDelete: newIsDelete);

                            final Map<String, LoginUserModel> newMap = Map<String, LoginUserModel>.from(
                              appParamState.keepLoginUserMap,
                            );

                            newMap[value.userId] = LoginUserModel(
                              id: value.id,
                              userId: value.userId,
                              isAdmin: value.isAdmin,
                              isDelete: newIsDelete,
                            );

                            appParamNotifier.setKeepLoginUserMap(map: newMap);
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
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });

    return SingleChildScrollView(child: Column(children: list));
  }
}
