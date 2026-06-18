// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LoginUserState {
  List<LoginUserModel> get loginUserList => throw _privateConstructorUsedError;
  Map<String, List<LoginUserModel>> get loginUserMap =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $LoginUserStateCopyWith<LoginUserState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginUserStateCopyWith<$Res> {
  factory $LoginUserStateCopyWith(
          LoginUserState value, $Res Function(LoginUserState) then) =
      _$LoginUserStateCopyWithImpl<$Res, LoginUserState>;
  @useResult
  $Res call(
      {List<LoginUserModel> loginUserList,
      Map<String, List<LoginUserModel>> loginUserMap});
}

/// @nodoc
class _$LoginUserStateCopyWithImpl<$Res, $Val extends LoginUserState>
    implements $LoginUserStateCopyWith<$Res> {
  _$LoginUserStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loginUserList = null,
    Object? loginUserMap = null,
  }) {
    return _then(_value.copyWith(
      loginUserList: null == loginUserList
          ? _value.loginUserList
          : loginUserList // ignore: cast_nullable_to_non_nullable
              as List<LoginUserModel>,
      loginUserMap: null == loginUserMap
          ? _value.loginUserMap
          : loginUserMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<LoginUserModel>>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LoginUserStateImplCopyWith<$Res>
    implements $LoginUserStateCopyWith<$Res> {
  factory _$$LoginUserStateImplCopyWith(_$LoginUserStateImpl value,
          $Res Function(_$LoginUserStateImpl) then) =
      __$$LoginUserStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<LoginUserModel> loginUserList,
      Map<String, List<LoginUserModel>> loginUserMap});
}

/// @nodoc
class __$$LoginUserStateImplCopyWithImpl<$Res>
    extends _$LoginUserStateCopyWithImpl<$Res, _$LoginUserStateImpl>
    implements _$$LoginUserStateImplCopyWith<$Res> {
  __$$LoginUserStateImplCopyWithImpl(
      _$LoginUserStateImpl _value, $Res Function(_$LoginUserStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loginUserList = null,
    Object? loginUserMap = null,
  }) {
    return _then(_$LoginUserStateImpl(
      loginUserList: null == loginUserList
          ? _value._loginUserList
          : loginUserList // ignore: cast_nullable_to_non_nullable
              as List<LoginUserModel>,
      loginUserMap: null == loginUserMap
          ? _value._loginUserMap
          : loginUserMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<LoginUserModel>>,
    ));
  }
}

/// @nodoc

class _$LoginUserStateImpl implements _LoginUserState {
  const _$LoginUserStateImpl(
      {final List<LoginUserModel> loginUserList = const <LoginUserModel>[],
      final Map<String, List<LoginUserModel>> loginUserMap =
          const <String, List<LoginUserModel>>{}})
      : _loginUserList = loginUserList,
        _loginUserMap = loginUserMap;

  final List<LoginUserModel> _loginUserList;
  @override
  @JsonKey()
  List<LoginUserModel> get loginUserList {
    if (_loginUserList is EqualUnmodifiableListView) return _loginUserList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_loginUserList);
  }

  final Map<String, List<LoginUserModel>> _loginUserMap;
  @override
  @JsonKey()
  Map<String, List<LoginUserModel>> get loginUserMap {
    if (_loginUserMap is EqualUnmodifiableMapView) return _loginUserMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_loginUserMap);
  }

  @override
  String toString() {
    return 'LoginUserState(loginUserList: $loginUserList, loginUserMap: $loginUserMap)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginUserStateImpl &&
            const DeepCollectionEquality()
                .equals(other._loginUserList, _loginUserList) &&
            const DeepCollectionEquality()
                .equals(other._loginUserMap, _loginUserMap));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_loginUserList),
      const DeepCollectionEquality().hash(_loginUserMap));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginUserStateImplCopyWith<_$LoginUserStateImpl> get copyWith =>
      __$$LoginUserStateImplCopyWithImpl<_$LoginUserStateImpl>(
          this, _$identity);
}

abstract class _LoginUserState implements LoginUserState {
  const factory _LoginUserState(
          {final List<LoginUserModel> loginUserList,
          final Map<String, List<LoginUserModel>> loginUserMap}) =
      _$LoginUserStateImpl;

  @override
  List<LoginUserModel> get loginUserList;
  @override
  Map<String, List<LoginUserModel>> get loginUserMap;
  @override
  @JsonKey(ignore: true)
  _$$LoginUserStateImplCopyWith<_$LoginUserStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
