// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SummaryState {
  List<SummaryModel> get summaryList => throw _privateConstructorUsedError;
  Map<String, List<SummaryModel>> get summaryMap =>
      throw _privateConstructorUsedError;
  Map<String, List<String>> get summaryDateBashoMap =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SummaryStateCopyWith<SummaryState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SummaryStateCopyWith<$Res> {
  factory $SummaryStateCopyWith(
          SummaryState value, $Res Function(SummaryState) then) =
      _$SummaryStateCopyWithImpl<$Res, SummaryState>;
  @useResult
  $Res call(
      {List<SummaryModel> summaryList,
      Map<String, List<SummaryModel>> summaryMap,
      Map<String, List<String>> summaryDateBashoMap});
}

/// @nodoc
class _$SummaryStateCopyWithImpl<$Res, $Val extends SummaryState>
    implements $SummaryStateCopyWith<$Res> {
  _$SummaryStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? summaryList = null,
    Object? summaryMap = null,
    Object? summaryDateBashoMap = null,
  }) {
    return _then(_value.copyWith(
      summaryList: null == summaryList
          ? _value.summaryList
          : summaryList // ignore: cast_nullable_to_non_nullable
              as List<SummaryModel>,
      summaryMap: null == summaryMap
          ? _value.summaryMap
          : summaryMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<SummaryModel>>,
      summaryDateBashoMap: null == summaryDateBashoMap
          ? _value.summaryDateBashoMap
          : summaryDateBashoMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SummaryStateImplCopyWith<$Res>
    implements $SummaryStateCopyWith<$Res> {
  factory _$$SummaryStateImplCopyWith(
          _$SummaryStateImpl value, $Res Function(_$SummaryStateImpl) then) =
      __$$SummaryStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<SummaryModel> summaryList,
      Map<String, List<SummaryModel>> summaryMap,
      Map<String, List<String>> summaryDateBashoMap});
}

/// @nodoc
class __$$SummaryStateImplCopyWithImpl<$Res>
    extends _$SummaryStateCopyWithImpl<$Res, _$SummaryStateImpl>
    implements _$$SummaryStateImplCopyWith<$Res> {
  __$$SummaryStateImplCopyWithImpl(
      _$SummaryStateImpl _value, $Res Function(_$SummaryStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? summaryList = null,
    Object? summaryMap = null,
    Object? summaryDateBashoMap = null,
  }) {
    return _then(_$SummaryStateImpl(
      summaryList: null == summaryList
          ? _value._summaryList
          : summaryList // ignore: cast_nullable_to_non_nullable
              as List<SummaryModel>,
      summaryMap: null == summaryMap
          ? _value._summaryMap
          : summaryMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<SummaryModel>>,
      summaryDateBashoMap: null == summaryDateBashoMap
          ? _value._summaryDateBashoMap
          : summaryDateBashoMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>,
    ));
  }
}

/// @nodoc

class _$SummaryStateImpl implements _SummaryState {
  const _$SummaryStateImpl(
      {final List<SummaryModel> summaryList = const <SummaryModel>[],
      final Map<String, List<SummaryModel>> summaryMap =
          const <String, List<SummaryModel>>{},
      final Map<String, List<String>> summaryDateBashoMap =
          const <String, List<String>>{}})
      : _summaryList = summaryList,
        _summaryMap = summaryMap,
        _summaryDateBashoMap = summaryDateBashoMap;

  final List<SummaryModel> _summaryList;
  @override
  @JsonKey()
  List<SummaryModel> get summaryList {
    if (_summaryList is EqualUnmodifiableListView) return _summaryList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_summaryList);
  }

  final Map<String, List<SummaryModel>> _summaryMap;
  @override
  @JsonKey()
  Map<String, List<SummaryModel>> get summaryMap {
    if (_summaryMap is EqualUnmodifiableMapView) return _summaryMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_summaryMap);
  }

  final Map<String, List<String>> _summaryDateBashoMap;
  @override
  @JsonKey()
  Map<String, List<String>> get summaryDateBashoMap {
    if (_summaryDateBashoMap is EqualUnmodifiableMapView)
      return _summaryDateBashoMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_summaryDateBashoMap);
  }

  @override
  String toString() {
    return 'SummaryState(summaryList: $summaryList, summaryMap: $summaryMap, summaryDateBashoMap: $summaryDateBashoMap)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SummaryStateImpl &&
            const DeepCollectionEquality()
                .equals(other._summaryList, _summaryList) &&
            const DeepCollectionEquality()
                .equals(other._summaryMap, _summaryMap) &&
            const DeepCollectionEquality()
                .equals(other._summaryDateBashoMap, _summaryDateBashoMap));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_summaryList),
      const DeepCollectionEquality().hash(_summaryMap),
      const DeepCollectionEquality().hash(_summaryDateBashoMap));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SummaryStateImplCopyWith<_$SummaryStateImpl> get copyWith =>
      __$$SummaryStateImplCopyWithImpl<_$SummaryStateImpl>(this, _$identity);
}

abstract class _SummaryState implements SummaryState {
  const factory _SummaryState(
          {final List<SummaryModel> summaryList,
          final Map<String, List<SummaryModel>> summaryMap,
          final Map<String, List<String>> summaryDateBashoMap}) =
      _$SummaryStateImpl;

  @override
  List<SummaryModel> get summaryList;
  @override
  Map<String, List<SummaryModel>> get summaryMap;
  @override
  Map<String, List<String>> get summaryDateBashoMap;
  @override
  @JsonKey(ignore: true)
  _$$SummaryStateImplCopyWith<_$SummaryStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
