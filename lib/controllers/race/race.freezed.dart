// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'race.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$RaceState {
  List<RaceModel> get raceList => throw _privateConstructorUsedError;
  Map<String, List<RaceModel>> get raceMap =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $RaceStateCopyWith<RaceState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RaceStateCopyWith<$Res> {
  factory $RaceStateCopyWith(RaceState value, $Res Function(RaceState) then) =
      _$RaceStateCopyWithImpl<$Res, RaceState>;
  @useResult
  $Res call({List<RaceModel> raceList, Map<String, List<RaceModel>> raceMap});
}

/// @nodoc
class _$RaceStateCopyWithImpl<$Res, $Val extends RaceState>
    implements $RaceStateCopyWith<$Res> {
  _$RaceStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? raceList = null,
    Object? raceMap = null,
  }) {
    return _then(_value.copyWith(
      raceList: null == raceList
          ? _value.raceList
          : raceList // ignore: cast_nullable_to_non_nullable
              as List<RaceModel>,
      raceMap: null == raceMap
          ? _value.raceMap
          : raceMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<RaceModel>>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RaceStateImplCopyWith<$Res>
    implements $RaceStateCopyWith<$Res> {
  factory _$$RaceStateImplCopyWith(
          _$RaceStateImpl value, $Res Function(_$RaceStateImpl) then) =
      __$$RaceStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<RaceModel> raceList, Map<String, List<RaceModel>> raceMap});
}

/// @nodoc
class __$$RaceStateImplCopyWithImpl<$Res>
    extends _$RaceStateCopyWithImpl<$Res, _$RaceStateImpl>
    implements _$$RaceStateImplCopyWith<$Res> {
  __$$RaceStateImplCopyWithImpl(
      _$RaceStateImpl _value, $Res Function(_$RaceStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? raceList = null,
    Object? raceMap = null,
  }) {
    return _then(_$RaceStateImpl(
      raceList: null == raceList
          ? _value._raceList
          : raceList // ignore: cast_nullable_to_non_nullable
              as List<RaceModel>,
      raceMap: null == raceMap
          ? _value._raceMap
          : raceMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<RaceModel>>,
    ));
  }
}

/// @nodoc

class _$RaceStateImpl implements _RaceState {
  const _$RaceStateImpl(
      {final List<RaceModel> raceList = const <RaceModel>[],
      final Map<String, List<RaceModel>> raceMap =
          const <String, List<RaceModel>>{}})
      : _raceList = raceList,
        _raceMap = raceMap;

  final List<RaceModel> _raceList;
  @override
  @JsonKey()
  List<RaceModel> get raceList {
    if (_raceList is EqualUnmodifiableListView) return _raceList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_raceList);
  }

  final Map<String, List<RaceModel>> _raceMap;
  @override
  @JsonKey()
  Map<String, List<RaceModel>> get raceMap {
    if (_raceMap is EqualUnmodifiableMapView) return _raceMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_raceMap);
  }

  @override
  String toString() {
    return 'RaceState(raceList: $raceList, raceMap: $raceMap)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RaceStateImpl &&
            const DeepCollectionEquality().equals(other._raceList, _raceList) &&
            const DeepCollectionEquality().equals(other._raceMap, _raceMap));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_raceList),
      const DeepCollectionEquality().hash(_raceMap));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RaceStateImplCopyWith<_$RaceStateImpl> get copyWith =>
      __$$RaceStateImplCopyWithImpl<_$RaceStateImpl>(this, _$identity);
}

abstract class _RaceState implements RaceState {
  const factory _RaceState(
      {final List<RaceModel> raceList,
      final Map<String, List<RaceModel>> raceMap}) = _$RaceStateImpl;

  @override
  List<RaceModel> get raceList;
  @override
  Map<String, List<RaceModel>> get raceMap;
  @override
  @JsonKey(ignore: true)
  _$$RaceStateImplCopyWith<_$RaceStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
