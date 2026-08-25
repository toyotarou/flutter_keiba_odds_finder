// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'developer_news.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DeveloperNewsState {
  List<DeveloperNewsModel> get developerNewsList =>
      throw _privateConstructorUsedError;
  Map<String, List<DeveloperNewsModel>> get developerNewsKindMap =>
      throw _privateConstructorUsedError;
  Map<String, List<DeveloperNewsModel>> get developerNewsTimeMap =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DeveloperNewsStateCopyWith<DeveloperNewsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeveloperNewsStateCopyWith<$Res> {
  factory $DeveloperNewsStateCopyWith(
          DeveloperNewsState value, $Res Function(DeveloperNewsState) then) =
      _$DeveloperNewsStateCopyWithImpl<$Res, DeveloperNewsState>;
  @useResult
  $Res call(
      {List<DeveloperNewsModel> developerNewsList,
      Map<String, List<DeveloperNewsModel>> developerNewsKindMap,
      Map<String, List<DeveloperNewsModel>> developerNewsTimeMap});
}

/// @nodoc
class _$DeveloperNewsStateCopyWithImpl<$Res, $Val extends DeveloperNewsState>
    implements $DeveloperNewsStateCopyWith<$Res> {
  _$DeveloperNewsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? developerNewsList = null,
    Object? developerNewsKindMap = null,
    Object? developerNewsTimeMap = null,
  }) {
    return _then(_value.copyWith(
      developerNewsList: null == developerNewsList
          ? _value.developerNewsList
          : developerNewsList // ignore: cast_nullable_to_non_nullable
              as List<DeveloperNewsModel>,
      developerNewsKindMap: null == developerNewsKindMap
          ? _value.developerNewsKindMap
          : developerNewsKindMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<DeveloperNewsModel>>,
      developerNewsTimeMap: null == developerNewsTimeMap
          ? _value.developerNewsTimeMap
          : developerNewsTimeMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<DeveloperNewsModel>>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeveloperNewsStateImplCopyWith<$Res>
    implements $DeveloperNewsStateCopyWith<$Res> {
  factory _$$DeveloperNewsStateImplCopyWith(_$DeveloperNewsStateImpl value,
          $Res Function(_$DeveloperNewsStateImpl) then) =
      __$$DeveloperNewsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<DeveloperNewsModel> developerNewsList,
      Map<String, List<DeveloperNewsModel>> developerNewsKindMap,
      Map<String, List<DeveloperNewsModel>> developerNewsTimeMap});
}

/// @nodoc
class __$$DeveloperNewsStateImplCopyWithImpl<$Res>
    extends _$DeveloperNewsStateCopyWithImpl<$Res, _$DeveloperNewsStateImpl>
    implements _$$DeveloperNewsStateImplCopyWith<$Res> {
  __$$DeveloperNewsStateImplCopyWithImpl(_$DeveloperNewsStateImpl _value,
      $Res Function(_$DeveloperNewsStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? developerNewsList = null,
    Object? developerNewsKindMap = null,
    Object? developerNewsTimeMap = null,
  }) {
    return _then(_$DeveloperNewsStateImpl(
      developerNewsList: null == developerNewsList
          ? _value._developerNewsList
          : developerNewsList // ignore: cast_nullable_to_non_nullable
              as List<DeveloperNewsModel>,
      developerNewsKindMap: null == developerNewsKindMap
          ? _value._developerNewsKindMap
          : developerNewsKindMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<DeveloperNewsModel>>,
      developerNewsTimeMap: null == developerNewsTimeMap
          ? _value._developerNewsTimeMap
          : developerNewsTimeMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<DeveloperNewsModel>>,
    ));
  }
}

/// @nodoc

class _$DeveloperNewsStateImpl implements _DeveloperNewsState {
  const _$DeveloperNewsStateImpl(
      {final List<DeveloperNewsModel> developerNewsList =
          const <DeveloperNewsModel>[],
      final Map<String, List<DeveloperNewsModel>> developerNewsKindMap =
          const <String, List<DeveloperNewsModel>>{},
      final Map<String, List<DeveloperNewsModel>> developerNewsTimeMap =
          const <String, List<DeveloperNewsModel>>{}})
      : _developerNewsList = developerNewsList,
        _developerNewsKindMap = developerNewsKindMap,
        _developerNewsTimeMap = developerNewsTimeMap;

  final List<DeveloperNewsModel> _developerNewsList;
  @override
  @JsonKey()
  List<DeveloperNewsModel> get developerNewsList {
    if (_developerNewsList is EqualUnmodifiableListView)
      return _developerNewsList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_developerNewsList);
  }

  final Map<String, List<DeveloperNewsModel>> _developerNewsKindMap;
  @override
  @JsonKey()
  Map<String, List<DeveloperNewsModel>> get developerNewsKindMap {
    if (_developerNewsKindMap is EqualUnmodifiableMapView)
      return _developerNewsKindMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_developerNewsKindMap);
  }

  final Map<String, List<DeveloperNewsModel>> _developerNewsTimeMap;
  @override
  @JsonKey()
  Map<String, List<DeveloperNewsModel>> get developerNewsTimeMap {
    if (_developerNewsTimeMap is EqualUnmodifiableMapView)
      return _developerNewsTimeMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_developerNewsTimeMap);
  }

  @override
  String toString() {
    return 'DeveloperNewsState(developerNewsList: $developerNewsList, developerNewsKindMap: $developerNewsKindMap, developerNewsTimeMap: $developerNewsTimeMap)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeveloperNewsStateImpl &&
            const DeepCollectionEquality()
                .equals(other._developerNewsList, _developerNewsList) &&
            const DeepCollectionEquality()
                .equals(other._developerNewsKindMap, _developerNewsKindMap) &&
            const DeepCollectionEquality()
                .equals(other._developerNewsTimeMap, _developerNewsTimeMap));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_developerNewsList),
      const DeepCollectionEquality().hash(_developerNewsKindMap),
      const DeepCollectionEquality().hash(_developerNewsTimeMap));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeveloperNewsStateImplCopyWith<_$DeveloperNewsStateImpl> get copyWith =>
      __$$DeveloperNewsStateImplCopyWithImpl<_$DeveloperNewsStateImpl>(
          this, _$identity);
}

abstract class _DeveloperNewsState implements DeveloperNewsState {
  const factory _DeveloperNewsState(
          {final List<DeveloperNewsModel> developerNewsList,
          final Map<String, List<DeveloperNewsModel>> developerNewsKindMap,
          final Map<String, List<DeveloperNewsModel>> developerNewsTimeMap}) =
      _$DeveloperNewsStateImpl;

  @override
  List<DeveloperNewsModel> get developerNewsList;
  @override
  Map<String, List<DeveloperNewsModel>> get developerNewsKindMap;
  @override
  Map<String, List<DeveloperNewsModel>> get developerNewsTimeMap;
  @override
  @JsonKey(ignore: true)
  _$$DeveloperNewsStateImplCopyWith<_$DeveloperNewsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
