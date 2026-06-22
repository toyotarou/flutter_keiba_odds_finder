import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/push_notifier_user_model.dart';
import '../../utility/utility.dart';

part 'push_notifier_user.freezed.dart';

part 'push_notifier_user.g.dart';

@freezed
class PushNotifierUserState with _$PushNotifierUserState {
  const factory PushNotifierUserState({
    @Default(<PushNotifierUserModel>[]) List<PushNotifierUserModel> pushNotifierUserList,
    @Default(<String, PushNotifierUserModel>{}) Map<String, PushNotifierUserModel> pushNotifierUserMap,
  }) = _PushNotifierUserState;
}

@riverpod
class PushNotifierUser extends _$PushNotifierUser {
  final Utility utility = Utility();

  ///
  @override
  PushNotifierUserState build() => const PushNotifierUserState();

  //============================================== api

  ///
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

  ///
  Future<void> getAllPushNotifierUserData() async {
    try {
      final PushNotifierUserState newState = await fetchAllPushNotifierUserData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api

  ///
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
}
