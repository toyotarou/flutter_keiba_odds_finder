// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'horse.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$HorseState {
  List<HorseModel> get horseList => throw _privateConstructorUsedError;
  Map<String, List<HorseModel>> get horseMap =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $HorseStateCopyWith<HorseState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HorseStateCopyWith<$Res> {
  factory $HorseStateCopyWith(
          HorseState value, $Res Function(HorseState) then) =
      _$HorseStateCopyWithImpl<$Res, HorseState>;
  @useResult
  $Res call(
      {List<HorseModel> horseList, Map<String, List<HorseModel>> horseMap});
}

/// @nodoc
class _$HorseStateCopyWithImpl<$Res, $Val extends HorseState>
    implements $HorseStateCopyWith<$Res> {
  _$HorseStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? horseList = null,
    Object? horseMap = null,
  }) {
    return _then(_value.copyWith(
      horseList: null == horseList
          ? _value.horseList
          : horseList // ignore: cast_nullable_to_non_nullable
              as List<HorseModel>,
      horseMap: null == horseMap
          ? _value.horseMap
          : horseMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<HorseModel>>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HorseStateImplCopyWith<$Res>
    implements $HorseStateCopyWith<$Res> {
  factory _$$HorseStateImplCopyWith(
          _$HorseStateImpl value, $Res Function(_$HorseStateImpl) then) =
      __$$HorseStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<HorseModel> horseList, Map<String, List<HorseModel>> horseMap});
}

/// @nodoc
class __$$HorseStateImplCopyWithImpl<$Res>
    extends _$HorseStateCopyWithImpl<$Res, _$HorseStateImpl>
    implements _$$HorseStateImplCopyWith<$Res> {
  __$$HorseStateImplCopyWithImpl(
      _$HorseStateImpl _value, $Res Function(_$HorseStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? horseList = null,
    Object? horseMap = null,
  }) {
    return _then(_$HorseStateImpl(
      horseList: null == horseList
          ? _value._horseList
          : horseList // ignore: cast_nullable_to_non_nullable
              as List<HorseModel>,
      horseMap: null == horseMap
          ? _value._horseMap
          : horseMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<HorseModel>>,
    ));
  }
}

/// @nodoc

class _$HorseStateImpl implements _HorseState {
  const _$HorseStateImpl(
      {final List<HorseModel> horseList = const <HorseModel>[],
      final Map<String, List<HorseModel>> horseMap =
          const <String, List<HorseModel>>{}})
      : _horseList = horseList,
        _horseMap = horseMap;

  final List<HorseModel> _horseList;
  @override
  @JsonKey()
  List<HorseModel> get horseList {
    if (_horseList is EqualUnmodifiableListView) return _horseList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_horseList);
  }

  final Map<String, List<HorseModel>> _horseMap;
  @override
  @JsonKey()
  Map<String, List<HorseModel>> get horseMap {
    if (_horseMap is EqualUnmodifiableMapView) return _horseMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_horseMap);
  }

  @override
  String toString() {
    return 'HorseState(horseList: $horseList, horseMap: $horseMap)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HorseStateImpl &&
            const DeepCollectionEquality()
                .equals(other._horseList, _horseList) &&
            const DeepCollectionEquality().equals(other._horseMap, _horseMap));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_horseList),
      const DeepCollectionEquality().hash(_horseMap));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HorseStateImplCopyWith<_$HorseStateImpl> get copyWith =>
      __$$HorseStateImplCopyWithImpl<_$HorseStateImpl>(this, _$identity);
}

abstract class _HorseState implements HorseState {
  const factory _HorseState(
      {final List<HorseModel> horseList,
      final Map<String, List<HorseModel>> horseMap}) = _$HorseStateImpl;

  @override
  List<HorseModel> get horseList;
  @override
  Map<String, List<HorseModel>> get horseMap;
  @override
  @JsonKey(ignore: true)
  _$$HorseStateImplCopyWith<_$HorseStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
