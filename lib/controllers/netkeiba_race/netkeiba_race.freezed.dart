// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'netkeiba_race.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$NetkeibaRaceState {
  List<NetkeibaRaceModel> get netkeibaRaceList =>
      throw _privateConstructorUsedError;
  Map<String, List<NetkeibaRaceModel>> get netkeibaRaceMap =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $NetkeibaRaceStateCopyWith<NetkeibaRaceState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NetkeibaRaceStateCopyWith<$Res> {
  factory $NetkeibaRaceStateCopyWith(
          NetkeibaRaceState value, $Res Function(NetkeibaRaceState) then) =
      _$NetkeibaRaceStateCopyWithImpl<$Res, NetkeibaRaceState>;
  @useResult
  $Res call(
      {List<NetkeibaRaceModel> netkeibaRaceList,
      Map<String, List<NetkeibaRaceModel>> netkeibaRaceMap});
}

/// @nodoc
class _$NetkeibaRaceStateCopyWithImpl<$Res, $Val extends NetkeibaRaceState>
    implements $NetkeibaRaceStateCopyWith<$Res> {
  _$NetkeibaRaceStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? netkeibaRaceList = null,
    Object? netkeibaRaceMap = null,
  }) {
    return _then(_value.copyWith(
      netkeibaRaceList: null == netkeibaRaceList
          ? _value.netkeibaRaceList
          : netkeibaRaceList // ignore: cast_nullable_to_non_nullable
              as List<NetkeibaRaceModel>,
      netkeibaRaceMap: null == netkeibaRaceMap
          ? _value.netkeibaRaceMap
          : netkeibaRaceMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<NetkeibaRaceModel>>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NetkeibaRaceStateImplCopyWith<$Res>
    implements $NetkeibaRaceStateCopyWith<$Res> {
  factory _$$NetkeibaRaceStateImplCopyWith(_$NetkeibaRaceStateImpl value,
          $Res Function(_$NetkeibaRaceStateImpl) then) =
      __$$NetkeibaRaceStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<NetkeibaRaceModel> netkeibaRaceList,
      Map<String, List<NetkeibaRaceModel>> netkeibaRaceMap});
}

/// @nodoc
class __$$NetkeibaRaceStateImplCopyWithImpl<$Res>
    extends _$NetkeibaRaceStateCopyWithImpl<$Res, _$NetkeibaRaceStateImpl>
    implements _$$NetkeibaRaceStateImplCopyWith<$Res> {
  __$$NetkeibaRaceStateImplCopyWithImpl(_$NetkeibaRaceStateImpl _value,
      $Res Function(_$NetkeibaRaceStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? netkeibaRaceList = null,
    Object? netkeibaRaceMap = null,
  }) {
    return _then(_$NetkeibaRaceStateImpl(
      netkeibaRaceList: null == netkeibaRaceList
          ? _value._netkeibaRaceList
          : netkeibaRaceList // ignore: cast_nullable_to_non_nullable
              as List<NetkeibaRaceModel>,
      netkeibaRaceMap: null == netkeibaRaceMap
          ? _value._netkeibaRaceMap
          : netkeibaRaceMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<NetkeibaRaceModel>>,
    ));
  }
}

/// @nodoc

class _$NetkeibaRaceStateImpl implements _NetkeibaRaceState {
  const _$NetkeibaRaceStateImpl(
      {final List<NetkeibaRaceModel> netkeibaRaceList =
          const <NetkeibaRaceModel>[],
      final Map<String, List<NetkeibaRaceModel>> netkeibaRaceMap =
          const <String, List<NetkeibaRaceModel>>{}})
      : _netkeibaRaceList = netkeibaRaceList,
        _netkeibaRaceMap = netkeibaRaceMap;

  final List<NetkeibaRaceModel> _netkeibaRaceList;
  @override
  @JsonKey()
  List<NetkeibaRaceModel> get netkeibaRaceList {
    if (_netkeibaRaceList is EqualUnmodifiableListView)
      return _netkeibaRaceList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_netkeibaRaceList);
  }

  final Map<String, List<NetkeibaRaceModel>> _netkeibaRaceMap;
  @override
  @JsonKey()
  Map<String, List<NetkeibaRaceModel>> get netkeibaRaceMap {
    if (_netkeibaRaceMap is EqualUnmodifiableMapView) return _netkeibaRaceMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_netkeibaRaceMap);
  }

  @override
  String toString() {
    return 'NetkeibaRaceState(netkeibaRaceList: $netkeibaRaceList, netkeibaRaceMap: $netkeibaRaceMap)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetkeibaRaceStateImpl &&
            const DeepCollectionEquality()
                .equals(other._netkeibaRaceList, _netkeibaRaceList) &&
            const DeepCollectionEquality()
                .equals(other._netkeibaRaceMap, _netkeibaRaceMap));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_netkeibaRaceList),
      const DeepCollectionEquality().hash(_netkeibaRaceMap));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NetkeibaRaceStateImplCopyWith<_$NetkeibaRaceStateImpl> get copyWith =>
      __$$NetkeibaRaceStateImplCopyWithImpl<_$NetkeibaRaceStateImpl>(
          this, _$identity);
}

abstract class _NetkeibaRaceState implements NetkeibaRaceState {
  const factory _NetkeibaRaceState(
          {final List<NetkeibaRaceModel> netkeibaRaceList,
          final Map<String, List<NetkeibaRaceModel>> netkeibaRaceMap}) =
      _$NetkeibaRaceStateImpl;

  @override
  List<NetkeibaRaceModel> get netkeibaRaceList;
  @override
  Map<String, List<NetkeibaRaceModel>> get netkeibaRaceMap;
  @override
  @JsonKey(ignore: true)
  _$$NetkeibaRaceStateImplCopyWith<_$NetkeibaRaceStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
