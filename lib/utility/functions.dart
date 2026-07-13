import 'package:flutter/material.dart';

Color raceRankColor(int? rank, {double alpha = 0.5, Color fallback = Colors.transparent}) => switch (rank) {
  1 => const Color(0xFFFFD700).withValues(alpha: alpha),
  2 => const Color(0xFFC0C0C0).withValues(alpha: alpha),
  3 => const Color(0xFFCD7F32).withValues(alpha: alpha),
  _ => fallback,
};
