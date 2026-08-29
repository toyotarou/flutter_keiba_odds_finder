// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_analysis.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AiAnalysisState {
  List<AiAnalysisModel> get aiAnalysisList =>
      throw _privateConstructorUsedError;
  Map<String, List<AiAnalysisModel>> get aiAnalysisMap =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AiAnalysisStateCopyWith<AiAnalysisState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiAnalysisStateCopyWith<$Res> {
  factory $AiAnalysisStateCopyWith(
          AiAnalysisState value, $Res Function(AiAnalysisState) then) =
      _$AiAnalysisStateCopyWithImpl<$Res, AiAnalysisState>;
  @useResult
  $Res call(
      {List<AiAnalysisModel> aiAnalysisList,
      Map<String, List<AiAnalysisModel>> aiAnalysisMap});
}

/// @nodoc
class _$AiAnalysisStateCopyWithImpl<$Res, $Val extends AiAnalysisState>
    implements $AiAnalysisStateCopyWith<$Res> {
  _$AiAnalysisStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? aiAnalysisList = null,
    Object? aiAnalysisMap = null,
  }) {
    return _then(_value.copyWith(
      aiAnalysisList: null == aiAnalysisList
          ? _value.aiAnalysisList
          : aiAnalysisList // ignore: cast_nullable_to_non_nullable
              as List<AiAnalysisModel>,
      aiAnalysisMap: null == aiAnalysisMap
          ? _value.aiAnalysisMap
          : aiAnalysisMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<AiAnalysisModel>>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AiAnalysisStateImplCopyWith<$Res>
    implements $AiAnalysisStateCopyWith<$Res> {
  factory _$$AiAnalysisStateImplCopyWith(_$AiAnalysisStateImpl value,
          $Res Function(_$AiAnalysisStateImpl) then) =
      __$$AiAnalysisStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<AiAnalysisModel> aiAnalysisList,
      Map<String, List<AiAnalysisModel>> aiAnalysisMap});
}

/// @nodoc
class __$$AiAnalysisStateImplCopyWithImpl<$Res>
    extends _$AiAnalysisStateCopyWithImpl<$Res, _$AiAnalysisStateImpl>
    implements _$$AiAnalysisStateImplCopyWith<$Res> {
  __$$AiAnalysisStateImplCopyWithImpl(
      _$AiAnalysisStateImpl _value, $Res Function(_$AiAnalysisStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? aiAnalysisList = null,
    Object? aiAnalysisMap = null,
  }) {
    return _then(_$AiAnalysisStateImpl(
      aiAnalysisList: null == aiAnalysisList
          ? _value._aiAnalysisList
          : aiAnalysisList // ignore: cast_nullable_to_non_nullable
              as List<AiAnalysisModel>,
      aiAnalysisMap: null == aiAnalysisMap
          ? _value._aiAnalysisMap
          : aiAnalysisMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<AiAnalysisModel>>,
    ));
  }
}

/// @nodoc

class _$AiAnalysisStateImpl implements _AiAnalysisState {
  const _$AiAnalysisStateImpl(
      {final List<AiAnalysisModel> aiAnalysisList = const <AiAnalysisModel>[],
      final Map<String, List<AiAnalysisModel>> aiAnalysisMap =
          const <String, List<AiAnalysisModel>>{}})
      : _aiAnalysisList = aiAnalysisList,
        _aiAnalysisMap = aiAnalysisMap;

  final List<AiAnalysisModel> _aiAnalysisList;
  @override
  @JsonKey()
  List<AiAnalysisModel> get aiAnalysisList {
    if (_aiAnalysisList is EqualUnmodifiableListView) return _aiAnalysisList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_aiAnalysisList);
  }

  final Map<String, List<AiAnalysisModel>> _aiAnalysisMap;
  @override
  @JsonKey()
  Map<String, List<AiAnalysisModel>> get aiAnalysisMap {
    if (_aiAnalysisMap is EqualUnmodifiableMapView) return _aiAnalysisMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_aiAnalysisMap);
  }

  @override
  String toString() {
    return 'AiAnalysisState(aiAnalysisList: $aiAnalysisList, aiAnalysisMap: $aiAnalysisMap)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiAnalysisStateImpl &&
            const DeepCollectionEquality()
                .equals(other._aiAnalysisList, _aiAnalysisList) &&
            const DeepCollectionEquality()
                .equals(other._aiAnalysisMap, _aiAnalysisMap));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_aiAnalysisList),
      const DeepCollectionEquality().hash(_aiAnalysisMap));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AiAnalysisStateImplCopyWith<_$AiAnalysisStateImpl> get copyWith =>
      __$$AiAnalysisStateImplCopyWithImpl<_$AiAnalysisStateImpl>(
          this, _$identity);
}

abstract class _AiAnalysisState implements AiAnalysisState {
  const factory _AiAnalysisState(
          {final List<AiAnalysisModel> aiAnalysisList,
          final Map<String, List<AiAnalysisModel>> aiAnalysisMap}) =
      _$AiAnalysisStateImpl;

  @override
  List<AiAnalysisModel> get aiAnalysisList;
  @override
  Map<String, List<AiAnalysisModel>> get aiAnalysisMap;
  @override
  @JsonKey(ignore: true)
  _$$AiAnalysisStateImplCopyWith<_$AiAnalysisStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
