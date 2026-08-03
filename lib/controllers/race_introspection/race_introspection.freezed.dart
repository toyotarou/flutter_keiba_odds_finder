// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'race_introspection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$RaceIntrospectionState {
  List<RaceIntrospectionModel> get raceIntrospectionList =>
      throw _privateConstructorUsedError;
  Map<String, RaceIntrospectionModel> get raceIntrospectionMap =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $RaceIntrospectionStateCopyWith<RaceIntrospectionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RaceIntrospectionStateCopyWith<$Res> {
  factory $RaceIntrospectionStateCopyWith(RaceIntrospectionState value,
          $Res Function(RaceIntrospectionState) then) =
      _$RaceIntrospectionStateCopyWithImpl<$Res, RaceIntrospectionState>;
  @useResult
  $Res call(
      {List<RaceIntrospectionModel> raceIntrospectionList,
      Map<String, RaceIntrospectionModel> raceIntrospectionMap});
}

/// @nodoc
class _$RaceIntrospectionStateCopyWithImpl<$Res,
        $Val extends RaceIntrospectionState>
    implements $RaceIntrospectionStateCopyWith<$Res> {
  _$RaceIntrospectionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? raceIntrospectionList = null,
    Object? raceIntrospectionMap = null,
  }) {
    return _then(_value.copyWith(
      raceIntrospectionList: null == raceIntrospectionList
          ? _value.raceIntrospectionList
          : raceIntrospectionList // ignore: cast_nullable_to_non_nullable
              as List<RaceIntrospectionModel>,
      raceIntrospectionMap: null == raceIntrospectionMap
          ? _value.raceIntrospectionMap
          : raceIntrospectionMap // ignore: cast_nullable_to_non_nullable
              as Map<String, RaceIntrospectionModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RaceIntrospectionStateImplCopyWith<$Res>
    implements $RaceIntrospectionStateCopyWith<$Res> {
  factory _$$RaceIntrospectionStateImplCopyWith(
          _$RaceIntrospectionStateImpl value,
          $Res Function(_$RaceIntrospectionStateImpl) then) =
      __$$RaceIntrospectionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<RaceIntrospectionModel> raceIntrospectionList,
      Map<String, RaceIntrospectionModel> raceIntrospectionMap});
}

/// @nodoc
class __$$RaceIntrospectionStateImplCopyWithImpl<$Res>
    extends _$RaceIntrospectionStateCopyWithImpl<$Res,
        _$RaceIntrospectionStateImpl>
    implements _$$RaceIntrospectionStateImplCopyWith<$Res> {
  __$$RaceIntrospectionStateImplCopyWithImpl(
      _$RaceIntrospectionStateImpl _value,
      $Res Function(_$RaceIntrospectionStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? raceIntrospectionList = null,
    Object? raceIntrospectionMap = null,
  }) {
    return _then(_$RaceIntrospectionStateImpl(
      raceIntrospectionList: null == raceIntrospectionList
          ? _value._raceIntrospectionList
          : raceIntrospectionList // ignore: cast_nullable_to_non_nullable
              as List<RaceIntrospectionModel>,
      raceIntrospectionMap: null == raceIntrospectionMap
          ? _value._raceIntrospectionMap
          : raceIntrospectionMap // ignore: cast_nullable_to_non_nullable
              as Map<String, RaceIntrospectionModel>,
    ));
  }
}

/// @nodoc

class _$RaceIntrospectionStateImpl implements _RaceIntrospectionState {
  const _$RaceIntrospectionStateImpl(
      {final List<RaceIntrospectionModel> raceIntrospectionList =
          const <RaceIntrospectionModel>[],
      final Map<String, RaceIntrospectionModel> raceIntrospectionMap =
          const <String, RaceIntrospectionModel>{}})
      : _raceIntrospectionList = raceIntrospectionList,
        _raceIntrospectionMap = raceIntrospectionMap;

  final List<RaceIntrospectionModel> _raceIntrospectionList;
  @override
  @JsonKey()
  List<RaceIntrospectionModel> get raceIntrospectionList {
    if (_raceIntrospectionList is EqualUnmodifiableListView)
      return _raceIntrospectionList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_raceIntrospectionList);
  }

  final Map<String, RaceIntrospectionModel> _raceIntrospectionMap;
  @override
  @JsonKey()
  Map<String, RaceIntrospectionModel> get raceIntrospectionMap {
    if (_raceIntrospectionMap is EqualUnmodifiableMapView)
      return _raceIntrospectionMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_raceIntrospectionMap);
  }

  @override
  String toString() {
    return 'RaceIntrospectionState(raceIntrospectionList: $raceIntrospectionList, raceIntrospectionMap: $raceIntrospectionMap)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RaceIntrospectionStateImpl &&
            const DeepCollectionEquality()
                .equals(other._raceIntrospectionList, _raceIntrospectionList) &&
            const DeepCollectionEquality()
                .equals(other._raceIntrospectionMap, _raceIntrospectionMap));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_raceIntrospectionList),
      const DeepCollectionEquality().hash(_raceIntrospectionMap));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RaceIntrospectionStateImplCopyWith<_$RaceIntrospectionStateImpl>
      get copyWith => __$$RaceIntrospectionStateImplCopyWithImpl<
          _$RaceIntrospectionStateImpl>(this, _$identity);
}

abstract class _RaceIntrospectionState implements RaceIntrospectionState {
  const factory _RaceIntrospectionState(
          {final List<RaceIntrospectionModel> raceIntrospectionList,
          final Map<String, RaceIntrospectionModel> raceIntrospectionMap}) =
      _$RaceIntrospectionStateImpl;

  @override
  List<RaceIntrospectionModel> get raceIntrospectionList;
  @override
  Map<String, RaceIntrospectionModel> get raceIntrospectionMap;
  @override
  @JsonKey(ignore: true)
  _$$RaceIntrospectionStateImplCopyWith<_$RaceIntrospectionStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
