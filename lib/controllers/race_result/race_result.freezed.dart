// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'race_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$RaceResultState {
  List<RaceResultModel> get raceResultList =>
      throw _privateConstructorUsedError;
  Map<String, List<RaceResultModel>> get raceResultMap =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $RaceResultStateCopyWith<RaceResultState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RaceResultStateCopyWith<$Res> {
  factory $RaceResultStateCopyWith(
          RaceResultState value, $Res Function(RaceResultState) then) =
      _$RaceResultStateCopyWithImpl<$Res, RaceResultState>;
  @useResult
  $Res call(
      {List<RaceResultModel> raceResultList,
      Map<String, List<RaceResultModel>> raceResultMap});
}

/// @nodoc
class _$RaceResultStateCopyWithImpl<$Res, $Val extends RaceResultState>
    implements $RaceResultStateCopyWith<$Res> {
  _$RaceResultStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? raceResultList = null,
    Object? raceResultMap = null,
  }) {
    return _then(_value.copyWith(
      raceResultList: null == raceResultList
          ? _value.raceResultList
          : raceResultList // ignore: cast_nullable_to_non_nullable
              as List<RaceResultModel>,
      raceResultMap: null == raceResultMap
          ? _value.raceResultMap
          : raceResultMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<RaceResultModel>>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RaceResultStateImplCopyWith<$Res>
    implements $RaceResultStateCopyWith<$Res> {
  factory _$$RaceResultStateImplCopyWith(_$RaceResultStateImpl value,
          $Res Function(_$RaceResultStateImpl) then) =
      __$$RaceResultStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<RaceResultModel> raceResultList,
      Map<String, List<RaceResultModel>> raceResultMap});
}

/// @nodoc
class __$$RaceResultStateImplCopyWithImpl<$Res>
    extends _$RaceResultStateCopyWithImpl<$Res, _$RaceResultStateImpl>
    implements _$$RaceResultStateImplCopyWith<$Res> {
  __$$RaceResultStateImplCopyWithImpl(
      _$RaceResultStateImpl _value, $Res Function(_$RaceResultStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? raceResultList = null,
    Object? raceResultMap = null,
  }) {
    return _then(_$RaceResultStateImpl(
      raceResultList: null == raceResultList
          ? _value._raceResultList
          : raceResultList // ignore: cast_nullable_to_non_nullable
              as List<RaceResultModel>,
      raceResultMap: null == raceResultMap
          ? _value._raceResultMap
          : raceResultMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<RaceResultModel>>,
    ));
  }
}

/// @nodoc

class _$RaceResultStateImpl implements _RaceResultState {
  const _$RaceResultStateImpl(
      {final List<RaceResultModel> raceResultList = const <RaceResultModel>[],
      final Map<String, List<RaceResultModel>> raceResultMap =
          const <String, List<RaceResultModel>>{}})
      : _raceResultList = raceResultList,
        _raceResultMap = raceResultMap;

  final List<RaceResultModel> _raceResultList;
  @override
  @JsonKey()
  List<RaceResultModel> get raceResultList {
    if (_raceResultList is EqualUnmodifiableListView) return _raceResultList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_raceResultList);
  }

  final Map<String, List<RaceResultModel>> _raceResultMap;
  @override
  @JsonKey()
  Map<String, List<RaceResultModel>> get raceResultMap {
    if (_raceResultMap is EqualUnmodifiableMapView) return _raceResultMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_raceResultMap);
  }

  @override
  String toString() {
    return 'RaceResultState(raceResultList: $raceResultList, raceResultMap: $raceResultMap)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RaceResultStateImpl &&
            const DeepCollectionEquality()
                .equals(other._raceResultList, _raceResultList) &&
            const DeepCollectionEquality()
                .equals(other._raceResultMap, _raceResultMap));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_raceResultList),
      const DeepCollectionEquality().hash(_raceResultMap));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RaceResultStateImplCopyWith<_$RaceResultStateImpl> get copyWith =>
      __$$RaceResultStateImplCopyWithImpl<_$RaceResultStateImpl>(
          this, _$identity);
}

abstract class _RaceResultState implements RaceResultState {
  const factory _RaceResultState(
          {final List<RaceResultModel> raceResultList,
          final Map<String, List<RaceResultModel>> raceResultMap}) =
      _$RaceResultStateImpl;

  @override
  List<RaceResultModel> get raceResultList;
  @override
  Map<String, List<RaceResultModel>> get raceResultMap;
  @override
  @JsonKey(ignore: true)
  _$$RaceResultStateImplCopyWith<_$RaceResultStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
