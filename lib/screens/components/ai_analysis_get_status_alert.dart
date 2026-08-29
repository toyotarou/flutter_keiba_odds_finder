import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';

class AiAnalysisGetStatusAlert extends ConsumerStatefulWidget {
  const AiAnalysisGetStatusAlert({super.key});

  @override
  ConsumerState<AiAnalysisGetStatusAlert> createState() => _AiAnalysisGetStatusAlertState();
}

class _AiAnalysisGetStatusAlertState extends ConsumerState<AiAnalysisGetStatusAlert>
    with ControllersMixin<AiAnalysisGetStatusAlert> {
  ///
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
