// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'horse_score.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$HorseScoreState {
  List<ScoreModel> get horseScoreList => throw _privateConstructorUsedError;
  Map<String, ScoreModel> get horseScoreMap =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $HorseScoreStateCopyWith<HorseScoreState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HorseScoreStateCopyWith<$Res> {
  factory $HorseScoreStateCopyWith(
          HorseScoreState value, $Res Function(HorseScoreState) then) =
      _$HorseScoreStateCopyWithImpl<$Res, HorseScoreState>;
  @useResult
  $Res call(
      {List<ScoreModel> horseScoreList, Map<String, ScoreModel> horseScoreMap});
}

/// @nodoc
class _$HorseScoreStateCopyWithImpl<$Res, $Val extends HorseScoreState>
    implements $HorseScoreStateCopyWith<$Res> {
  _$HorseScoreStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? horseScoreList = null,
    Object? horseScoreMap = null,
  }) {
    return _then(_value.copyWith(
      horseScoreList: null == horseScoreList
          ? _value.horseScoreList
          : horseScoreList // ignore: cast_nullable_to_non_nullable
              as List<ScoreModel>,
      horseScoreMap: null == horseScoreMap
          ? _value.horseScoreMap
          : horseScoreMap // ignore: cast_nullable_to_non_nullable
              as Map<String, ScoreModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HorseScoreStateImplCopyWith<$Res>
    implements $HorseScoreStateCopyWith<$Res> {
  factory _$$HorseScoreStateImplCopyWith(_$HorseScoreStateImpl value,
          $Res Function(_$HorseScoreStateImpl) then) =
      __$$HorseScoreStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<ScoreModel> horseScoreList, Map<String, ScoreModel> horseScoreMap});
}

/// @nodoc
class __$$HorseScoreStateImplCopyWithImpl<$Res>
    extends _$HorseScoreStateCopyWithImpl<$Res, _$HorseScoreStateImpl>
    implements _$$HorseScoreStateImplCopyWith<$Res> {
  __$$HorseScoreStateImplCopyWithImpl(
      _$HorseScoreStateImpl _value, $Res Function(_$HorseScoreStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? horseScoreList = null,
    Object? horseScoreMap = null,
  }) {
    return _then(_$HorseScoreStateImpl(
      horseScoreList: null == horseScoreList
          ? _value._horseScoreList
          : horseScoreList // ignore: cast_nullable_to_non_nullable
              as List<ScoreModel>,
      horseScoreMap: null == horseScoreMap
          ? _value._horseScoreMap
          : horseScoreMap // ignore: cast_nullable_to_non_nullable
              as Map<String, ScoreModel>,
    ));
  }
}

/// @nodoc

class _$HorseScoreStateImpl implements _HorseScoreState {
  const _$HorseScoreStateImpl(
      {final List<ScoreModel> horseScoreList = const <ScoreModel>[],
      final Map<String, ScoreModel> horseScoreMap =
          const <String, ScoreModel>{}})
      : _horseScoreList = horseScoreList,
        _horseScoreMap = horseScoreMap;

  final List<ScoreModel> _horseScoreList;
  @override
  @JsonKey()
  List<ScoreModel> get horseScoreList {
    if (_horseScoreList is EqualUnmodifiableListView) return _horseScoreList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_horseScoreList);
  }

  final Map<String, ScoreModel> _horseScoreMap;
  @override
  @JsonKey()
  Map<String, ScoreModel> get horseScoreMap {
    if (_horseScoreMap is EqualUnmodifiableMapView) return _horseScoreMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_horseScoreMap);
  }

  @override
  String toString() {
    return 'HorseScoreState(horseScoreList: $horseScoreList, horseScoreMap: $horseScoreMap)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HorseScoreStateImpl &&
            const DeepCollectionEquality()
                .equals(other._horseScoreList, _horseScoreList) &&
            const DeepCollectionEquality()
                .equals(other._horseScoreMap, _horseScoreMap));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_horseScoreList),
      const DeepCollectionEquality().hash(_horseScoreMap));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HorseScoreStateImplCopyWith<_$HorseScoreStateImpl> get copyWith =>
      __$$HorseScoreStateImplCopyWithImpl<_$HorseScoreStateImpl>(
          this, _$identity);
}

abstract class _HorseScoreState implements HorseScoreState {
  const factory _HorseScoreState(
      {final List<ScoreModel> horseScoreList,
      final Map<String, ScoreModel> horseScoreMap}) = _$HorseScoreStateImpl;

  @override
  List<ScoreModel> get horseScoreList;
  @override
  Map<String, ScoreModel> get horseScoreMap;
  @override
  @JsonKey(ignore: true)
  _$$HorseScoreStateImplCopyWith<_$HorseScoreStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
