import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';

class LoginUserListDisplayAlert extends ConsumerStatefulWidget {
  const LoginUserListDisplayAlert({super.key});

  @override
  ConsumerState<LoginUserListDisplayAlert> createState() => _LoginUserListDisplayAlertState();
}

class _LoginUserListDisplayAlertState extends ConsumerState<LoginUserListDisplayAlert>
    with ControllersMixin<LoginUserListDisplayAlert> {
  ///
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
