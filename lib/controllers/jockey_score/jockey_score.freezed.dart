// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'jockey_score.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$JockeyScoreState {
  List<ScoreModel> get jockeyScoreList => throw _privateConstructorUsedError;
  Map<String, ScoreModel> get jockeyScoreMap =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $JockeyScoreStateCopyWith<JockeyScoreState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JockeyScoreStateCopyWith<$Res> {
  factory $JockeyScoreStateCopyWith(
          JockeyScoreState value, $Res Function(JockeyScoreState) then) =
      _$JockeyScoreStateCopyWithImpl<$Res, JockeyScoreState>;
  @useResult
  $Res call(
      {List<ScoreModel> jockeyScoreList,
      Map<String, ScoreModel> jockeyScoreMap});
}

/// @nodoc
class _$JockeyScoreStateCopyWithImpl<$Res, $Val extends JockeyScoreState>
    implements $JockeyScoreStateCopyWith<$Res> {
  _$JockeyScoreStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jockeyScoreList = null,
    Object? jockeyScoreMap = null,
  }) {
    return _then(_value.copyWith(
      jockeyScoreList: null == jockeyScoreList
          ? _value.jockeyScoreList
          : jockeyScoreList // ignore: cast_nullable_to_non_nullable
              as List<ScoreModel>,
      jockeyScoreMap: null == jockeyScoreMap
          ? _value.jockeyScoreMap
          : jockeyScoreMap // ignore: cast_nullable_to_non_nullable
              as Map<String, ScoreModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$JockeyScoreStateImplCopyWith<$Res>
    implements $JockeyScoreStateCopyWith<$Res> {
  factory _$$JockeyScoreStateImplCopyWith(_$JockeyScoreStateImpl value,
          $Res Function(_$JockeyScoreStateImpl) then) =
      __$$JockeyScoreStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<ScoreModel> jockeyScoreList,
      Map<String, ScoreModel> jockeyScoreMap});
}

/// @nodoc
class __$$JockeyScoreStateImplCopyWithImpl<$Res>
    extends _$JockeyScoreStateCopyWithImpl<$Res, _$JockeyScoreStateImpl>
    implements _$$JockeyScoreStateImplCopyWith<$Res> {
  __$$JockeyScoreStateImplCopyWithImpl(_$JockeyScoreStateImpl _value,
      $Res Function(_$JockeyScoreStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jockeyScoreList = null,
    Object? jockeyScoreMap = null,
  }) {
    return _then(_$JockeyScoreStateImpl(
      jockeyScoreList: null == jockeyScoreList
          ? _value._jockeyScoreList
          : jockeyScoreList // ignore: cast_nullable_to_non_nullable
              as List<ScoreModel>,
      jockeyScoreMap: null == jockeyScoreMap
          ? _value._jockeyScoreMap
          : jockeyScoreMap // ignore: cast_nullable_to_non_nullable
              as Map<String, ScoreModel>,
    ));
  }
}

/// @nodoc

class _$JockeyScoreStateImpl implements _JockeyScoreState {
  const _$JockeyScoreStateImpl(
      {final List<ScoreModel> jockeyScoreList = const <ScoreModel>[],
      final Map<String, ScoreModel> jockeyScoreMap =
          const <String, ScoreModel>{}})
      : _jockeyScoreList = jockeyScoreList,
        _jockeyScoreMap = jockeyScoreMap;

  final List<ScoreModel> _jockeyScoreList;
  @override
  @JsonKey()
  List<ScoreModel> get jockeyScoreList {
    if (_jockeyScoreList is EqualUnmodifiableListView) return _jockeyScoreList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_jockeyScoreList);
  }

  final Map<String, ScoreModel> _jockeyScoreMap;
  @override
  @JsonKey()
  Map<String, ScoreModel> get jockeyScoreMap {
    if (_jockeyScoreMap is EqualUnmodifiableMapView) return _jockeyScoreMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_jockeyScoreMap);
  }

  @override
  String toString() {
    return 'JockeyScoreState(jockeyScoreList: $jockeyScoreList, jockeyScoreMap: $jockeyScoreMap)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JockeyScoreStateImpl &&
            const DeepCollectionEquality()
                .equals(other._jockeyScoreList, _jockeyScoreList) &&
            const DeepCollectionEquality()
                .equals(other._jockeyScoreMap, _jockeyScoreMap));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_jockeyScoreList),
      const DeepCollectionEquality().hash(_jockeyScoreMap));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$JockeyScoreStateImplCopyWith<_$JockeyScoreStateImpl> get copyWith =>
      __$$JockeyScoreStateImplCopyWithImpl<_$JockeyScoreStateImpl>(
          this, _$identity);
}

abstract class _JockeyScoreState implements JockeyScoreState {
  const factory _JockeyScoreState(
      {final List<ScoreModel> jockeyScoreList,
      final Map<String, ScoreModel> jockeyScoreMap}) = _$JockeyScoreStateImpl;

  @override
  List<ScoreModel> get jockeyScoreList;
  @override
  Map<String, ScoreModel> get jockeyScoreMap;
  @override
  @JsonKey(ignore: true)
  _$$JockeyScoreStateImplCopyWith<_$JockeyScoreStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
