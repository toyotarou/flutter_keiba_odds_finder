// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ScheduleState {
  List<ScheduleModel> get scheduleList => throw _privateConstructorUsedError;
  Map<String, ScheduleModel> get scheduleMap =>
      throw _privateConstructorUsedError;
  Map<String, List<ScheduleModel>> get scheduleDateBashoMap =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ScheduleStateCopyWith<ScheduleState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleStateCopyWith<$Res> {
  factory $ScheduleStateCopyWith(
          ScheduleState value, $Res Function(ScheduleState) then) =
      _$ScheduleStateCopyWithImpl<$Res, ScheduleState>;
  @useResult
  $Res call(
      {List<ScheduleModel> scheduleList,
      Map<String, ScheduleModel> scheduleMap,
      Map<String, List<ScheduleModel>> scheduleDateBashoMap});
}

/// @nodoc
class _$ScheduleStateCopyWithImpl<$Res, $Val extends ScheduleState>
    implements $ScheduleStateCopyWith<$Res> {
  _$ScheduleStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scheduleList = null,
    Object? scheduleMap = null,
    Object? scheduleDateBashoMap = null,
  }) {
    return _then(_value.copyWith(
      scheduleList: null == scheduleList
          ? _value.scheduleList
          : scheduleList // ignore: cast_nullable_to_non_nullable
              as List<ScheduleModel>,
      scheduleMap: null == scheduleMap
          ? _value.scheduleMap
          : scheduleMap // ignore: cast_nullable_to_non_nullable
              as Map<String, ScheduleModel>,
      scheduleDateBashoMap: null == scheduleDateBashoMap
          ? _value.scheduleDateBashoMap
          : scheduleDateBashoMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<ScheduleModel>>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScheduleStateImplCopyWith<$Res>
    implements $ScheduleStateCopyWith<$Res> {
  factory _$$ScheduleStateImplCopyWith(
          _$ScheduleStateImpl value, $Res Function(_$ScheduleStateImpl) then) =
      __$$ScheduleStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<ScheduleModel> scheduleList,
      Map<String, ScheduleModel> scheduleMap,
      Map<String, List<ScheduleModel>> scheduleDateBashoMap});
}

/// @nodoc
class __$$ScheduleStateImplCopyWithImpl<$Res>
    extends _$ScheduleStateCopyWithImpl<$Res, _$ScheduleStateImpl>
    implements _$$ScheduleStateImplCopyWith<$Res> {
  __$$ScheduleStateImplCopyWithImpl(
      _$ScheduleStateImpl _value, $Res Function(_$ScheduleStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scheduleList = null,
    Object? scheduleMap = null,
    Object? scheduleDateBashoMap = null,
  }) {
    return _then(_$ScheduleStateImpl(
      scheduleList: null == scheduleList
          ? _value._scheduleList
          : scheduleList // ignore: cast_nullable_to_non_nullable
              as List<ScheduleModel>,
      scheduleMap: null == scheduleMap
          ? _value._scheduleMap
          : scheduleMap // ignore: cast_nullable_to_non_nullable
              as Map<String, ScheduleModel>,
      scheduleDateBashoMap: null == scheduleDateBashoMap
          ? _value._scheduleDateBashoMap
          : scheduleDateBashoMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<ScheduleModel>>,
    ));
  }
}

/// @nodoc

class _$ScheduleStateImpl implements _ScheduleState {
  const _$ScheduleStateImpl(
      {final List<ScheduleModel> scheduleList = const <ScheduleModel>[],
      final Map<String, ScheduleModel> scheduleMap =
          const <String, ScheduleModel>{},
      final Map<String, List<ScheduleModel>> scheduleDateBashoMap =
          const <String, List<ScheduleModel>>{}})
      : _scheduleList = scheduleList,
        _scheduleMap = scheduleMap,
        _scheduleDateBashoMap = scheduleDateBashoMap;

  final List<ScheduleModel> _scheduleList;
  @override
  @JsonKey()
  List<ScheduleModel> get scheduleList {
    if (_scheduleList is EqualUnmodifiableListView) return _scheduleList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_scheduleList);
  }

  final Map<String, ScheduleModel> _scheduleMap;
  @override
  @JsonKey()
  Map<String, ScheduleModel> get scheduleMap {
    if (_scheduleMap is EqualUnmodifiableMapView) return _scheduleMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_scheduleMap);
  }

  final Map<String, List<ScheduleModel>> _scheduleDateBashoMap;
  @override
  @JsonKey()
  Map<String, List<ScheduleModel>> get scheduleDateBashoMap {
    if (_scheduleDateBashoMap is EqualUnmodifiableMapView)
      return _scheduleDateBashoMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_scheduleDateBashoMap);
  }

  @override
  String toString() {
    return 'ScheduleState(scheduleList: $scheduleList, scheduleMap: $scheduleMap, scheduleDateBashoMap: $scheduleDateBashoMap)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleStateImpl &&
            const DeepCollectionEquality()
                .equals(other._scheduleList, _scheduleList) &&
            const DeepCollectionEquality()
                .equals(other._scheduleMap, _scheduleMap) &&
            const DeepCollectionEquality()
                .equals(other._scheduleDateBashoMap, _scheduleDateBashoMap));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_scheduleList),
      const DeepCollectionEquality().hash(_scheduleMap),
      const DeepCollectionEquality().hash(_scheduleDateBashoMap));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleStateImplCopyWith<_$ScheduleStateImpl> get copyWith =>
      __$$ScheduleStateImplCopyWithImpl<_$ScheduleStateImpl>(this, _$identity);
}

abstract class _ScheduleState implements ScheduleState {
  const factory _ScheduleState(
          {final List<ScheduleModel> scheduleList,
          final Map<String, ScheduleModel> scheduleMap,
          final Map<String, List<ScheduleModel>> scheduleDateBashoMap}) =
      _$ScheduleStateImpl;

  @override
  List<ScheduleModel> get scheduleList;
  @override
  Map<String, ScheduleModel> get scheduleMap;
  @override
  Map<String, List<ScheduleModel>> get scheduleDateBashoMap;
  @override
  @JsonKey(ignore: true)
  _$$ScheduleStateImplCopyWith<_$ScheduleStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
