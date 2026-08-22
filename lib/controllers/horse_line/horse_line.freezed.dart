// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'horse_line.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$HorseLineState {
  int? get selectedHorse => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $HorseLineStateCopyWith<HorseLineState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HorseLineStateCopyWith<$Res> {
  factory $HorseLineStateCopyWith(
          HorseLineState value, $Res Function(HorseLineState) then) =
      _$HorseLineStateCopyWithImpl<$Res, HorseLineState>;
  @useResult
  $Res call({int? selectedHorse});
}

/// @nodoc
class _$HorseLineStateCopyWithImpl<$Res, $Val extends HorseLineState>
    implements $HorseLineStateCopyWith<$Res> {
  _$HorseLineStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedHorse = freezed,
  }) {
    return _then(_value.copyWith(
      selectedHorse: freezed == selectedHorse
          ? _value.selectedHorse
          : selectedHorse // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HorseLineStateImplCopyWith<$Res>
    implements $HorseLineStateCopyWith<$Res> {
  factory _$$HorseLineStateImplCopyWith(_$HorseLineStateImpl value,
          $Res Function(_$HorseLineStateImpl) then) =
      __$$HorseLineStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? selectedHorse});
}

/// @nodoc
class __$$HorseLineStateImplCopyWithImpl<$Res>
    extends _$HorseLineStateCopyWithImpl<$Res, _$HorseLineStateImpl>
    implements _$$HorseLineStateImplCopyWith<$Res> {
  __$$HorseLineStateImplCopyWithImpl(
      _$HorseLineStateImpl _value, $Res Function(_$HorseLineStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedHorse = freezed,
  }) {
    return _then(_$HorseLineStateImpl(
      selectedHorse: freezed == selectedHorse
          ? _value.selectedHorse
          : selectedHorse // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$HorseLineStateImpl implements _HorseLineState {
  const _$HorseLineStateImpl({this.selectedHorse});

  @override
  final int? selectedHorse;

  @override
  String toString() {
    return 'HorseLineState(selectedHorse: $selectedHorse)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HorseLineStateImpl &&
            (identical(other.selectedHorse, selectedHorse) ||
                other.selectedHorse == selectedHorse));
  }

  @override
  int get hashCode => Object.hash(runtimeType, selectedHorse);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HorseLineStateImplCopyWith<_$HorseLineStateImpl> get copyWith =>
      __$$HorseLineStateImplCopyWithImpl<_$HorseLineStateImpl>(
          this, _$identity);
}

abstract class _HorseLineState implements HorseLineState {
  const factory _HorseLineState({final int? selectedHorse}) =
      _$HorseLineStateImpl;

  @override
  int? get selectedHorse;
  @override
  @JsonKey(ignore: true)
  _$$HorseLineStateImplCopyWith<_$HorseLineStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
