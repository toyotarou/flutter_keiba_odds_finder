import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

extension ContextEx on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colorTheme => Theme.of(this).colorScheme;

  Size get screenSize => MediaQuery.of(this).size;

  void showKeyboard(FocusNode node) {
    FocusScope.of(this).requestFocus(node);
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }
}

// 20260925: DateFormat / NumberFormat / RegExp は呼ぶたびに生成すると重いので使い回す
// （youbiStr の 'EEEE' はロケールの初期化状態に依存するため従来どおり都度生成）
final DateFormat _yyyymmddFormat = DateFormat('yyyy-MM-dd');
final DateFormat _yyyymmFormat = DateFormat('yyyy-MM');
final DateFormat _mmddFormat = DateFormat('MM-dd');
final DateFormat _yyyyFormat = DateFormat('yyyy');
final DateFormat _mmFormat = DateFormat('MM');
final DateFormat _ddFormat = DateFormat('dd');
final DateFormat _dateTimeParseFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
final NumberFormat _currencyFormat = NumberFormat('#,###');
final RegExp _halfAlphanumericRegExp = RegExp(r'^[a-zA-Z0-9]+$');
final RegExp _fullAlphanumericRegExp = RegExp(r'^[Ａ-Ｚａ-ｚ０-９]+$');

extension DateTimeEx on DateTime {
  String get yyyymmdd => _yyyymmddFormat.format(this);

  String get yyyymm => _yyyymmFormat.format(this);

  String get mmdd => _mmddFormat.format(this);

  String get yyyy => _yyyyFormat.format(this);

  String get mm => _mmFormat.format(this);

  String get dd => _ddFormat.format(this);

  String get youbiStr {
    final DateFormat outputFormat = DateFormat('EEEE');
    return outputFormat.format(this);
  }

  // ===== ここから追記：日付比較を“日単位”で扱うためのヘルパ =====

  /// 時刻を切り捨てた "日付のみ"（00:00:00）を返す
  DateTime get dateOnly => DateTime(year, month, day);

  /// 同じ日付か（時刻は無視）
  bool isSameDate(DateTime other) => dateOnly.isAtSameMomentAs(other.dateOnly);

  /// 厳密に「前の日付」か（<、同日は含まない）
  bool isBeforeDate(DateTime other) => dateOnly.isBefore(other.dateOnly);

  /// 厳密に「後の日付」か（>、同日は含まない）
  bool isAfterDate(DateTime other) => dateOnly.isAfter(other.dateOnly);

  /// 「前または同じ日付」か（<=）
  bool isBeforeOrSameDate(DateTime other) => isBeforeDate(other) || isSameDate(other);

  /// 「後または同じ日付」か（>=）
  bool isAfterOrSameDate(DateTime other) => isAfterDate(other) || isSameDate(other);

  /// 範囲内かどうか（閉区間: start <= this <= end）
  bool isBetweenDatesInclusive(DateTime start, DateTime end) => isAfterOrSameDate(start) && isBeforeOrSameDate(end);

  /// 範囲内かどうか（開区間: start < this < end）
  bool isBetweenDatesExclusive(DateTime start, DateTime end) => isAfterDate(start) && isBeforeDate(end);

  // ===== 追記ここまで =====
}

const int _fullLengthCode = 65248;

extension StringEx on String {
  DateTime toDateTime() {
    return _dateTimeParseFormat.parseStrict(this);
  }

  int toInt({int defaultValue = 0}) {
    return int.tryParse(this) ?? defaultValue;
  }

  String toCurrency() {
    final int? val = int.tryParse(this);
    if (val == null) {
      return this;
    }
    return _currencyFormat.format(val);
  }

  double toDouble({double defaultValue = 0.0}) {
    return double.tryParse(this) ?? defaultValue;
  }

  String alphanumericToFullLength() {
    final Iterable<String> string = runes.map<String>((int rune) {
      final String char = String.fromCharCode(rune);
      return _halfAlphanumericRegExp.hasMatch(char) ? String.fromCharCode(rune + _fullLengthCode) : char;
    });
    return string.join();
  }

  String alphanumericToHalfLength() {
    final Iterable<String> string = runes.map<String>((int rune) {
      final String char = String.fromCharCode(rune);
      return _fullAlphanumericRegExp.hasMatch(char) ? String.fromCharCode(rune - _fullLengthCode) : char;
    });
    return string.join();
  }
}

// ignore: strict_raw_type, always_specify_types
extension ListIndexCheck on List {
  bool isInRange(int i) => i >= 0 && i < length;
}
