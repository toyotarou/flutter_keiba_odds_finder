import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'horse_line.freezed.dart';

part 'horse_line.g.dart';

@freezed
class HorseLineState with _$HorseLineState {
  const factory HorseLineState({
    int? selectedHorse,
  }) = _HorseLineState;
}

@riverpod
class HorseLine extends _$HorseLine {
  ///
  @override
  HorseLineState build() => const HorseLineState();

  ///
  void setSelectedHorse({required int? num}) => state = state.copyWith(selectedHorse: num);
}
