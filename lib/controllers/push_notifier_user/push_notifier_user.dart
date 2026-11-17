// =============================================================================
// ファイル名   : push_notifier_user.dart
// 概要         : プッシュ通知の送信対象ユーザーを API から取得して保持する Riverpod の Notifier と、その状態クラス。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-06-22
// 最終更新日   : 2026-11-17
// =============================================================================

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/push_notifier_user_model.dart';
import '../../utility/utility.dart';

part 'push_notifier_user.freezed.dart';

part 'push_notifier_user.g.dart';

/// プッシュ通知の送信対象ユーザーの状態。
@freezed
class PushNotifierUserState with _$PushNotifierUserState {
  const factory PushNotifierUserState({
    @Default(<PushNotifierUserModel>[]) List<PushNotifierUserModel> pushNotifierUserList,
    @Default(<String, PushNotifierUserModel>{}) Map<String, PushNotifierUserModel> pushNotifierUserMap,
  }) = _PushNotifierUserState;
}

/// プッシュ通知の送信対象ユーザーを API から取得して保持する Notifier。
@riverpod
class PushNotifierUser extends _$PushNotifierUser {
  final Utility utility = Utility();

  /// 状態の初期値を返す。
  @override
  PushNotifierUserState build() => const PushNotifierUserState();

  //============================================== api

  /// API からプッシュ通知の送信対象ユーザーを全件取得し、新しい状態を作って返す。
  /// 取得に失敗したときはエラーを表示し、例外を呼び出し元へ投げ直す。
  Future<PushNotifierUserState> fetchAllPushNotifierUserData() async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      final List<PushNotifierUserModel> list = <PushNotifierUserModel>[];
      final Map<String, PushNotifierUserModel> map = <String, PushNotifierUserModel>{};

      // ignore: always_specify_types
      await client.get(path: APIPath.getHorseOddsFinderPushSubscriptions).then((value) {
        // ignore: avoid_dynamic_calls
        for (int i = 0; i < value['data'].length.toString().toInt(); i++) {
          // ignore: avoid_dynamic_calls
          final PushNotifierUserModel val = PushNotifierUserModel.fromJson(value['data'][i] as Map<String, dynamic>);

          list.add(val);

          map[val.userId] = val;
        }
      });

      return state.copyWith(pushNotifierUserList: list, pushNotifierUserMap: map);
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow; // これにより呼び出し元でキャッチできる
    }
  }

  /// プッシュ通知の送信対象ユーザーを全件取得して状態に反映する。失敗したときは状態を変えない。
  Future<void> getAllPushNotifierUserData() async {
    try {
      final PushNotifierUserState newState = await fetchAllPushNotifierUserData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api

  /// 指定したプッシュ通知送信対象ユーザーの削除フラグを変更する。失敗したときはエラーを表示する。
  Future<void> changePushNotifierUserDelete({required int id, required int isDelete}) async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      await client.post(
        path: APIPath.changePushNotifierUserDelete,
        body: <String, dynamic>{'id': id, 'is_delete': isDelete},
      );
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
    }
  }

  //============================================== api

  /// ホーム画面の「通知」スイッチ用。ログインユーザーの push 受信設定を取得する
  /// 戻り値: isReceive（true=受信 / false=非受信）, count（登録端末数。0 なら通知が許可されていない）
  /// 取得に失敗したときは null
  Future<({bool isReceive, int count})?> fetchMyPushReceive({required String userId}) async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      // ignore: always_specify_types
      final value = await client.get(path: APIPath.getMyPushReceive, queryParameters: <String, dynamic>{'user_id': userId});

      // ignore: avoid_dynamic_calls
      final int isReceive = (value['is_receive'] ?? 1).toString().toInt();
      // ignore: avoid_dynamic_calls
      final int count = (value['count'] ?? 0).toString().toInt();

      return (isReceive: isReceive == 1, count: count);
    } catch (e) {
      return null;
    }
  }
  /// ホーム画面の「通知」スイッチ用。ログインユーザーの全端末の受信/非受信を切り替える
  Future<bool> changeMyPushReceive({required String userId, required bool isReceive}) async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      await client.post(
        path: APIPath.changeMyPushReceive,
        body: <String, dynamic>{'user_id': userId, 'is_receive': isReceive ? 1 : 0},
      );
      return true;
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      return false;
    }
  }
}
