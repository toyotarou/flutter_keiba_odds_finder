// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'odds.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OddsState {
  List<OddsModel> get oddsList => throw _privateConstructorUsedError;
  Map<String, List<OddsModel>> get oddsMap =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $OddsStateCopyWith<OddsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OddsStateCopyWith<$Res> {
  factory $OddsStateCopyWith(OddsState value, $Res Function(OddsState) then) =
      _$OddsStateCopyWithImpl<$Res, OddsState>;
  @useResult
  $Res call({List<OddsModel> oddsList, Map<String, List<OddsModel>> oddsMap});
}

/// @nodoc
class _$OddsStateCopyWithImpl<$Res, $Val extends OddsState>
    implements $OddsStateCopyWith<$Res> {
  _$OddsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? oddsList = null,
    Object? oddsMap = null,
  }) {
    return _then(_value.copyWith(
      oddsList: null == oddsList
          ? _value.oddsList
          : oddsList // ignore: cast_nullable_to_non_nullable
              as List<OddsModel>,
      oddsMap: null == oddsMap
          ? _value.oddsMap
          : oddsMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<OddsModel>>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OddsStateImplCopyWith<$Res>
    implements $OddsStateCopyWith<$Res> {
  factory _$$OddsStateImplCopyWith(
          _$OddsStateImpl value, $Res Function(_$OddsStateImpl) then) =
      __$$OddsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<OddsModel> oddsList, Map<String, List<OddsModel>> oddsMap});
}

/// @nodoc
class __$$OddsStateImplCopyWithImpl<$Res>
    extends _$OddsStateCopyWithImpl<$Res, _$OddsStateImpl>
    implements _$$OddsStateImplCopyWith<$Res> {
  __$$OddsStateImplCopyWithImpl(
      _$OddsStateImpl _value, $Res Function(_$OddsStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? oddsList = null,
    Object? oddsMap = null,
  }) {
    return _then(_$OddsStateImpl(
      oddsList: null == oddsList
          ? _value._oddsList
          : oddsList // ignore: cast_nullable_to_non_nullable
              as List<OddsModel>,
      oddsMap: null == oddsMap
          ? _value._oddsMap
          : oddsMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<OddsModel>>,
    ));
  }
}

/// @nodoc

class _$OddsStateImpl implements _OddsState {
  const _$OddsStateImpl(
      {final List<OddsModel> oddsList = const <OddsModel>[],
      final Map<String, List<OddsModel>> oddsMap =
          const <String, List<OddsModel>>{}})
      : _oddsList = oddsList,
        _oddsMap = oddsMap;

  final List<OddsModel> _oddsList;
  @override
  @JsonKey()
  List<OddsModel> get oddsList {
    if (_oddsList is EqualUnmodifiableListView) return _oddsList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_oddsList);
  }

  final Map<String, List<OddsModel>> _oddsMap;
  @override
  @JsonKey()
  Map<String, List<OddsModel>> get oddsMap {
    if (_oddsMap is EqualUnmodifiableMapView) return _oddsMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_oddsMap);
  }

  @override
  String toString() {
    return 'OddsState(oddsList: $oddsList, oddsMap: $oddsMap)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OddsStateImpl &&
            const DeepCollectionEquality().equals(other._oddsList, _oddsList) &&
            const DeepCollectionEquality().equals(other._oddsMap, _oddsMap));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_oddsList),
      const DeepCollectionEquality().hash(_oddsMap));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OddsStateImplCopyWith<_$OddsStateImpl> get copyWith =>
      __$$OddsStateImplCopyWithImpl<_$OddsStateImpl>(this, _$identity);
}

abstract class _OddsState implements OddsState {
  const factory _OddsState(
      {final List<OddsModel> oddsList,
      final Map<String, List<OddsModel>> oddsMap}) = _$OddsStateImpl;

  @override
  List<OddsModel> get oddsList;
  @override
  Map<String, List<OddsModel>> get oddsMap;
  @override
  @JsonKey(ignore: true)
  _$$OddsStateImplCopyWith<_$OddsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
