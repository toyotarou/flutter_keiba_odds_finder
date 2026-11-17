// =============================================================================
// ファイル名   : horse_line.dart
// 概要         : オッズ推移グラフで強調表示する馬番を保持する Notifier と、その状態クラス。
//                （現在、画面からは参照されていない）
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-08-22
// 最終更新日   : 2026-11-17
// =============================================================================

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'horse_line.freezed.dart';

part 'horse_line.g.dart';

/// 強調表示する馬番の状態。
@freezed
class HorseLineState with _$HorseLineState {
  const factory HorseLineState({
    int? selectedHorse,
  }) = _HorseLineState;
}

/// 強調表示する馬番を保持する Notifier。
@riverpod
class HorseLine extends _$HorseLine {
  /// 状態の初期値を返す。
  @override
  HorseLineState build() => const HorseLineState();

  /// オッズ推移グラフで強調表示する馬番を更新する（null で解除）。
  void setSelectedHorse({required int? num}) => state = state.copyWith(selectedHorse: num);
}
