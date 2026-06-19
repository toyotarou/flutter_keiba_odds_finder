import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/login_user_model.dart';
import '../../utility/utility.dart';

part 'login_user.freezed.dart';

part 'login_user.g.dart';

@freezed
class LoginUserState with _$LoginUserState {
  const factory LoginUserState({
    @Default(<LoginUserModel>[]) List<LoginUserModel> loginUserList,
    @Default(<String, LoginUserModel>{}) Map<String, LoginUserModel> loginUserMap,
  }) = _LoginUserState;
}

@riverpod
class LoginUser extends _$LoginUser {
  final Utility utility = Utility();

  ///
  @override
  LoginUserState build() => const LoginUserState();

  //============================================== api

  ///
  Future<LoginUserState> fetchAllLoginUserData() async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      final List<LoginUserModel> list = <LoginUserModel>[];

      final Map<String, LoginUserModel> map = <String, LoginUserModel>{};

      // ignore: always_specify_types
      await client.get(path: APIPath.getHorseOddsFinderLoginUsers).then((value) {
        // ignore: avoid_dynamic_calls
        for (int i = 0; i < value['data'].length.toString().toInt(); i++) {
          // ignore: avoid_dynamic_calls
          final LoginUserModel val = LoginUserModel.fromJson(value['data'][i] as Map<String, dynamic>);

          list.add(val);

          map[val.userId] = val;
        }
      });

      return state.copyWith(loginUserList: list, loginUserMap: map);
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow; // これにより呼び出し元でキャッチできる
    }
  }

  ///
  Future<void> getAllLoginUserData() async {
    try {
      final LoginUserState newState = await fetchAllLoginUserData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api

  ///
  Future<void> changeAdmin({required int id, required int isAdmin}) async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      await client.post(path: APIPath.changeAdmin, body: <String, dynamic>{'id': id, 'is_admin': isAdmin});
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
    }
  }

  ///
  Future<void> changeDelete({required int id, required int isDelete}) async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      await client.post(path: APIPath.changeDelete, body: <String, dynamic>{'id': id, 'is_delete': isDelete});
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
    }
  }
}
