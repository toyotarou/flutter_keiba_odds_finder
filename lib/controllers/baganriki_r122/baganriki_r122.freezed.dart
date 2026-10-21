// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'baganriki_r122.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BaganrikiR122State {
  Map<String, BaganrikiR122Model> get raceMap =>
      throw _privateConstructorUsedError;
  Set<String> get loadingRaceIds => throw _privateConstructorUsedError;
  Map<String, String> get errorMap => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BaganrikiR122StateCopyWith<BaganrikiR122State> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BaganrikiR122StateCopyWith<$Res> {
  factory $BaganrikiR122StateCopyWith(
          BaganrikiR122State value, $Res Function(BaganrikiR122State) then) =
      _$BaganrikiR122StateCopyWithImpl<$Res, BaganrikiR122State>;
  @useResult
  $Res call(
      {Map<String, BaganrikiR122Model> raceMap,
      Set<String> loadingRaceIds,
      Map<String, String> errorMap});
}

/// @nodoc
class _$BaganrikiR122StateCopyWithImpl<$Res, $Val extends BaganrikiR122State>
    implements $BaganrikiR122StateCopyWith<$Res> {
  _$BaganrikiR122StateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? raceMap = null,
    Object? loadingRaceIds = null,
    Object? errorMap = null,
  }) {
    return _then(_value.copyWith(
      raceMap: null == raceMap
          ? _value.raceMap
          : raceMap // ignore: cast_nullable_to_non_nullable
              as Map<String, BaganrikiR122Model>,
      loadingRaceIds: null == loadingRaceIds
          ? _value.loadingRaceIds
          : loadingRaceIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      errorMap: null == errorMap
          ? _value.errorMap
          : errorMap // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BaganrikiR122StateImplCopyWith<$Res>
    implements $BaganrikiR122StateCopyWith<$Res> {
  factory _$$BaganrikiR122StateImplCopyWith(_$BaganrikiR122StateImpl value,
          $Res Function(_$BaganrikiR122StateImpl) then) =
      __$$BaganrikiR122StateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Map<String, BaganrikiR122Model> raceMap,
      Set<String> loadingRaceIds,
      Map<String, String> errorMap});
}

/// @nodoc
class __$$BaganrikiR122StateImplCopyWithImpl<$Res>
    extends _$BaganrikiR122StateCopyWithImpl<$Res, _$BaganrikiR122StateImpl>
    implements _$$BaganrikiR122StateImplCopyWith<$Res> {
  __$$BaganrikiR122StateImplCopyWithImpl(_$BaganrikiR122StateImpl _value,
      $Res Function(_$BaganrikiR122StateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? raceMap = null,
    Object? loadingRaceIds = null,
    Object? errorMap = null,
  }) {
    return _then(_$BaganrikiR122StateImpl(
      raceMap: null == raceMap
          ? _value._raceMap
          : raceMap // ignore: cast_nullable_to_non_nullable
              as Map<String, BaganrikiR122Model>,
      loadingRaceIds: null == loadingRaceIds
          ? _value._loadingRaceIds
          : loadingRaceIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      errorMap: null == errorMap
          ? _value._errorMap
          : errorMap // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ));
  }
}

/// @nodoc

class _$BaganrikiR122StateImpl implements _BaganrikiR122State {
  const _$BaganrikiR122StateImpl(
      {final Map<String, BaganrikiR122Model> raceMap =
          const <String, BaganrikiR122Model>{},
      final Set<String> loadingRaceIds = const <String>{},
      final Map<String, String> errorMap = const <String, String>{}})
      : _raceMap = raceMap,
        _loadingRaceIds = loadingRaceIds,
        _errorMap = errorMap;

  final Map<String, BaganrikiR122Model> _raceMap;
  @override
  @JsonKey()
  Map<String, BaganrikiR122Model> get raceMap {
    if (_raceMap is EqualUnmodifiableMapView) return _raceMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_raceMap);
  }

  final Set<String> _loadingRaceIds;
  @override
  @JsonKey()
  Set<String> get loadingRaceIds {
    if (_loadingRaceIds is EqualUnmodifiableSetView) return _loadingRaceIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_loadingRaceIds);
  }

  final Map<String, String> _errorMap;
  @override
  @JsonKey()
  Map<String, String> get errorMap {
    if (_errorMap is EqualUnmodifiableMapView) return _errorMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_errorMap);
  }

  @override
  String toString() {
    return 'BaganrikiR122State(raceMap: $raceMap, loadingRaceIds: $loadingRaceIds, errorMap: $errorMap)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BaganrikiR122StateImpl &&
            const DeepCollectionEquality().equals(other._raceMap, _raceMap) &&
            const DeepCollectionEquality()
                .equals(other._loadingRaceIds, _loadingRaceIds) &&
            const DeepCollectionEquality().equals(other._errorMap, _errorMap));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_raceMap),
      const DeepCollectionEquality().hash(_loadingRaceIds),
      const DeepCollectionEquality().hash(_errorMap));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BaganrikiR122StateImplCopyWith<_$BaganrikiR122StateImpl> get copyWith =>
      __$$BaganrikiR122StateImplCopyWithImpl<_$BaganrikiR122StateImpl>(
          this, _$identity);
}

abstract class _BaganrikiR122State implements BaganrikiR122State {
  const factory _BaganrikiR122State(
      {final Map<String, BaganrikiR122Model> raceMap,
      final Set<String> loadingRaceIds,
      final Map<String, String> errorMap}) = _$BaganrikiR122StateImpl;

  @override
  Map<String, BaganrikiR122Model> get raceMap;
  @override
  Set<String> get loadingRaceIds;
  @override
  Map<String, String> get errorMap;
  @override
  @JsonKey(ignore: true)
  _$$BaganrikiR122StateImplCopyWith<_$BaganrikiR122StateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
