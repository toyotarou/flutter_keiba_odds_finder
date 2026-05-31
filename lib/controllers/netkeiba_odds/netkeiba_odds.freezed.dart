// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'netkeiba_odds.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$NetkeibaOddsState {
  List<NetkeibaOddsModel> get netkeibaOddsList =>
      throw _privateConstructorUsedError;
  Map<String, List<NetkeibaOddsModel>> get netkeibaOddsMap =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $NetkeibaOddsStateCopyWith<NetkeibaOddsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NetkeibaOddsStateCopyWith<$Res> {
  factory $NetkeibaOddsStateCopyWith(
          NetkeibaOddsState value, $Res Function(NetkeibaOddsState) then) =
      _$NetkeibaOddsStateCopyWithImpl<$Res, NetkeibaOddsState>;
  @useResult
  $Res call(
      {List<NetkeibaOddsModel> netkeibaOddsList,
      Map<String, List<NetkeibaOddsModel>> netkeibaOddsMap});
}

/// @nodoc
class _$NetkeibaOddsStateCopyWithImpl<$Res, $Val extends NetkeibaOddsState>
    implements $NetkeibaOddsStateCopyWith<$Res> {
  _$NetkeibaOddsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? netkeibaOddsList = null,
    Object? netkeibaOddsMap = null,
  }) {
    return _then(_value.copyWith(
      netkeibaOddsList: null == netkeibaOddsList
          ? _value.netkeibaOddsList
          : netkeibaOddsList // ignore: cast_nullable_to_non_nullable
              as List<NetkeibaOddsModel>,
      netkeibaOddsMap: null == netkeibaOddsMap
          ? _value.netkeibaOddsMap
          : netkeibaOddsMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<NetkeibaOddsModel>>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NetkeibaOddsStateImplCopyWith<$Res>
    implements $NetkeibaOddsStateCopyWith<$Res> {
  factory _$$NetkeibaOddsStateImplCopyWith(_$NetkeibaOddsStateImpl value,
          $Res Function(_$NetkeibaOddsStateImpl) then) =
      __$$NetkeibaOddsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<NetkeibaOddsModel> netkeibaOddsList,
      Map<String, List<NetkeibaOddsModel>> netkeibaOddsMap});
}

/// @nodoc
class __$$NetkeibaOddsStateImplCopyWithImpl<$Res>
    extends _$NetkeibaOddsStateCopyWithImpl<$Res, _$NetkeibaOddsStateImpl>
    implements _$$NetkeibaOddsStateImplCopyWith<$Res> {
  __$$NetkeibaOddsStateImplCopyWithImpl(_$NetkeibaOddsStateImpl _value,
      $Res Function(_$NetkeibaOddsStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? netkeibaOddsList = null,
    Object? netkeibaOddsMap = null,
  }) {
    return _then(_$NetkeibaOddsStateImpl(
      netkeibaOddsList: null == netkeibaOddsList
          ? _value._netkeibaOddsList
          : netkeibaOddsList // ignore: cast_nullable_to_non_nullable
              as List<NetkeibaOddsModel>,
      netkeibaOddsMap: null == netkeibaOddsMap
          ? _value._netkeibaOddsMap
          : netkeibaOddsMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<NetkeibaOddsModel>>,
    ));
  }
}

/// @nodoc

class _$NetkeibaOddsStateImpl implements _NetkeibaOddsState {
  const _$NetkeibaOddsStateImpl(
      {final List<NetkeibaOddsModel> netkeibaOddsList =
          const <NetkeibaOddsModel>[],
      final Map<String, List<NetkeibaOddsModel>> netkeibaOddsMap =
          const <String, List<NetkeibaOddsModel>>{}})
      : _netkeibaOddsList = netkeibaOddsList,
        _netkeibaOddsMap = netkeibaOddsMap;

  final List<NetkeibaOddsModel> _netkeibaOddsList;
  @override
  @JsonKey()
  List<NetkeibaOddsModel> get netkeibaOddsList {
    if (_netkeibaOddsList is EqualUnmodifiableListView)
      return _netkeibaOddsList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_netkeibaOddsList);
  }

  final Map<String, List<NetkeibaOddsModel>> _netkeibaOddsMap;
  @override
  @JsonKey()
  Map<String, List<NetkeibaOddsModel>> get netkeibaOddsMap {
    if (_netkeibaOddsMap is EqualUnmodifiableMapView) return _netkeibaOddsMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_netkeibaOddsMap);
  }

  @override
  String toString() {
    return 'NetkeibaOddsState(netkeibaOddsList: $netkeibaOddsList, netkeibaOddsMap: $netkeibaOddsMap)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetkeibaOddsStateImpl &&
            const DeepCollectionEquality()
                .equals(other._netkeibaOddsList, _netkeibaOddsList) &&
            const DeepCollectionEquality()
                .equals(other._netkeibaOddsMap, _netkeibaOddsMap));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_netkeibaOddsList),
      const DeepCollectionEquality().hash(_netkeibaOddsMap));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NetkeibaOddsStateImplCopyWith<_$NetkeibaOddsStateImpl> get copyWith =>
      __$$NetkeibaOddsStateImplCopyWithImpl<_$NetkeibaOddsStateImpl>(
          this, _$identity);
}

abstract class _NetkeibaOddsState implements NetkeibaOddsState {
  const factory _NetkeibaOddsState(
          {final List<NetkeibaOddsModel> netkeibaOddsList,
          final Map<String, List<NetkeibaOddsModel>> netkeibaOddsMap}) =
      _$NetkeibaOddsStateImpl;

  @override
  List<NetkeibaOddsModel> get netkeibaOddsList;
  @override
  Map<String, List<NetkeibaOddsModel>> get netkeibaOddsMap;
  @override
  @JsonKey(ignore: true)
  _$$NetkeibaOddsStateImplCopyWith<_$NetkeibaOddsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
