// =============================================================================
// ファイル名   : admin_menu_alert.dart
// 概要         : 管理者メニュー。利用者リスト・プッシュ通知ユーザー・データ件数・開発者向けお知らせ・
//                AI 分析の取得状況の各画面を開く。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-06-25
// 最終更新日   : 2026-11-17
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../extensions/extensions.dart';
import '../parts/odds_finder_dialog.dart';
import 'ai_analysis_get_status_alert.dart';
import 'data_count_display_alert.dart';
import 'developer_news_minutes_display_alert.dart';
import 'login_user_list_display_alert.dart';
import 'push_notifier_user_list_display_alert.dart';

/// 管理者メニューの画面。
class AdminMenuAlert extends ConsumerStatefulWidget {
  const AdminMenuAlert({super.key, required this.loggedInUserId});

  final String loggedInUserId;

  @override
  ConsumerState<AdminMenuAlert> createState() => _AdminMenuAlertState();
}

/// 管理者メニューの画面の状態。
class _AdminMenuAlertState extends ConsumerState<AdminMenuAlert> {
  /// 管理者メニューの画面（各画面を開くボタンの一覧）を組み立てる。
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

                _buildMenuButton(
                  label: '利用者リスト',
                  onTap: () => OddsFinderDialog(
                    context: context,
                    widget: LoginUserListDisplayAlert(loggedInUserId: widget.loggedInUserId),
                  ),
                ),

                SizedBox(height: context.screenSize.height * 0.02),

                _buildMenuButton(
                  label: 'プッシュ通知ユーザーリスト',
                  onTap: () => OddsFinderDialog(
                    context: context,
                    widget: PushNotifierUserListDisplayAlert(loggedInUserId: widget.loggedInUserId),
                  ),
                ),

                SizedBox(height: context.screenSize.height * 0.02),

                _buildMenuButton(
                  label: 'サマリーテーブル確認',
                  color: Colors.yellowAccent.withValues(alpha: 0.1),
                  onTap: () => OddsFinderDialog(context: context, widget: const DataCountDisplayAlert()),
                ),

                SizedBox(height: context.screenSize.height * 0.02),

                _buildMenuButton(
                  label: 'developer news',
                  color: Colors.purpleAccent.withValues(alpha: 0.1),
                  onTap: () => OddsFinderDialog(context: context, widget: const DeveloperNewsMinutesDisplayAlert()),
                ),

                SizedBox(height: context.screenSize.height * 0.02),

                _buildMenuButton(
                  label: 'ai analysis',
                  color: Colors.lightBlueAccent.withValues(alpha: 0.1),
                  onTap: () => OddsFinderDialog(context: context, widget: const AiAnalysisGetStatusAlert()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// メニューのボタン1つぶんを表示する。[color] を渡すと背景に色を付ける。
  Widget _buildMenuButton({required String label, required VoidCallback onTap, Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: context.screenSize.height * 0.1,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(5),
          color: color,
        ),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Center(child: Text(label, style: const TextStyle(fontSize: 12))),
      ),
    );
  }
}
