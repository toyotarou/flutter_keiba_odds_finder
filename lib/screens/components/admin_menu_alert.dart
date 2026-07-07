import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../extensions/extensions.dart';
import '../parts/odds_finder_dialog.dart';
import 'data_count_display_alert.dart';
import 'login_user_list_display_alert.dart';
import 'push_notifier_user_list_display_alert.dart';

class AdminMenuAlert extends ConsumerStatefulWidget {
  const AdminMenuAlert({super.key, required this.loggedInUserId});

  final String loggedInUserId;

  @override
  ConsumerState<AdminMenuAlert> createState() => _AdminMenuAlertState();
}

class _AdminMenuAlertState extends ConsumerState<AdminMenuAlert> {
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
                const Text('管理者メニュー', style: TextStyle(fontSize: 12)),
                Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 5),

                GestureDetector(
                  onTap: () {
                    OddsFinderDialog(
                      context: context,
                      widget: LoginUserListDisplayAlert(loggedInUserId: widget.loggedInUserId),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: context.screenSize.height * 0.2,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: const Center(child: Text('利用者リスト', style: TextStyle(fontSize: 12))),
                  ),
                ),

                SizedBox(height: context.screenSize.height * 0.02),

                GestureDetector(
                  onTap: () {
                    OddsFinderDialog(
                      context: context,
                      widget: PushNotifierUserListDisplayAlert(loggedInUserId: widget.loggedInUserId),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: context.screenSize.height * 0.2,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: const Center(child: Text('プッシュ通知ユーザーリスト', style: TextStyle(fontSize: 12))),
                  ),
                ),

                SizedBox(height: context.screenSize.height * 0.02),

                GestureDetector(
                  onTap: () {
                    // OddsFinderDialog(
                    //   context: context,
                    //   widget: PushNotifierUserListDisplayAlert(loggedInUserId: widget.loggedInUserId),
                    // );

                    ///AAA

                    OddsFinderDialog(context: context, widget: const DataCountDisplayAlert());
                  },
                  child: Container(
                    width: double.infinity,
                    height: context.screenSize.height * 0.1,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.yellowAccent.withValues(alpha: 0.1),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: const Center(child: Text('サマリーテーブル確認', style: TextStyle(fontSize: 12))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
