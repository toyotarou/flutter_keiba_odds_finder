// =============================================================================
// ファイル名   : login_user.dart
// 概要         : ログインユーザーを API から取得して保持する Riverpod の Notifier と、その状態クラス。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-06-18
// 最終更新日   : 2026-11-17
// =============================================================================

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/login_user_model.dart';
import '../../utility/utility.dart';

part 'login_user.freezed.dart';

part 'login_user.g.dart';

/// ログインユーザーの状態。
@freezed
class LoginUserState with _$LoginUserState {
  const factory LoginUserState({
    @Default(<LoginUserModel>[]) List<LoginUserModel> loginUserList,
    @Default(<String, LoginUserModel>{}) Map<String, LoginUserModel> loginUserMap,
  }) = _LoginUserState;
}

/// ログインユーザーを API から取得して保持する Notifier。
@riverpod
class LoginUser extends _$LoginUser {
  final Utility utility = Utility();

  /// 状態の初期値を返す。
  @override
  LoginUserState build() => const LoginUserState();

  //============================================== api

  /// API からログインユーザーを全件取得し、新しい状態を作って返す。
  /// 取得に失敗したときはエラーを表示し、例外を呼び出し元へ投げ直す。
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

  /// ログインユーザーを全件取得して状態に反映する。失敗したときは状態を変えない。
  Future<void> getAllLoginUserData() async {
    try {
      final LoginUserState newState = await fetchAllLoginUserData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api

  /// 指定したユーザーの管理者フラグを変更する。失敗したときはエラーを表示する。
  Future<void> changeAdmin({required int id, required int isAdmin}) async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      await client.post(path: APIPath.changeAdmin, body: <String, dynamic>{'id': id, 'is_admin': isAdmin});
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
    }
  }

  /// 指定したユーザーの削除フラグを変更する。失敗したときはエラーを表示する。
  Future<void> changeDelete({required int id, required int isDelete}) async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      await client.post(path: APIPath.changeDelete, body: <String, dynamic>{'id': id, 'is_delete': isDelete});
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
    }
  }
}
