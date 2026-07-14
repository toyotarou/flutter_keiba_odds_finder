import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';

class TotalForecastDisplayAlert extends ConsumerStatefulWidget {
  const TotalForecastDisplayAlert({super.key});

  @override
  ConsumerState<TotalForecastDisplayAlert> createState() => _TotalForecastDisplayAlertState();
}

class _TotalForecastDisplayAlertState extends ConsumerState<TotalForecastDisplayAlert>
    with ControllersMixin<TotalForecastDisplayAlert> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
