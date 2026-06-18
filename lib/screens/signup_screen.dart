import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/http/client.dart';
import '../data/http/path.dart';
import '../extensions/extensions.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final List<FocusNode> _focusNodes = List<FocusNode>.generate(2, (_) => FocusNode());
  bool _passwordObscure = true;
  bool _isLoading = false;

  ///
  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    for (final FocusNode node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              Image.asset('assets/images/gold_title.png'),
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: context.screenSize.height * 0.38),
                    _buildInputCard(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          onPressed: _isLoading ? null : () => Navigator.pop(context),
                          child: const Text('LOGIN', style: TextStyle(color: Colors.white70)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///
  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[BoxShadow(blurRadius: 24, spreadRadius: 16, color: Colors.black.withOpacity(0.2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            width: context.screenSize.width,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
            ),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                TextField(
                  controller: _userIdController,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    hintText: 'ユーザーID',
                    filled: true,
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                  ),
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                  onTapOutside: (PointerDownEvent event) => FocusManager.instance.primaryFocus?.unfocus(),
                  focusNode: _focusNodes[0],
                  onTap: () => context.showKeyboard(_focusNodes[0]),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: _passwordObscure,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    hintText: 'パスワード',
                    filled: true,
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                    suffixIcon: IconButton(
                      icon: Icon(_passwordObscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _passwordObscure = !_passwordObscure),
                    ),
                  ),
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                  onTapOutside: (PointerDownEvent event) => FocusManager.instance.primaryFocus?.unfocus(),
                  focusNode: _focusNodes[1],
                  onTap: () => context.showKeyboard(_focusNodes[1]),
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const CircularProgressIndicator(color: Colors.greenAccent)
                else
                  ElevatedButton(
                    onPressed: _signup,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent.withOpacity(0.3)),
                    child: const Text('SIGN UP'),
                  ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///
  Future<void> _signup() async {
    final String userId = _userIdController.text.trim();
    final String password = _passwordController.text.trim();

    if (userId.isEmpty || password.isEmpty) {
      _showError('ユーザーIDとパスワードを入力してください。');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final HttpClient client = ref.read(httpClientProvider);
      final Map<String, dynamic> data =
          (await client.post(path: APIPath.signup, body: <String, String>{'user_id': userId, 'password': password}))
              as Map<String, dynamic>;

      if (data['success'] == true) {
        if (mounted) {
          Navigator.pop(context, <String, String>{'user_id': userId, 'password': password});
        }
      } else {
        _showError('登録できませんでした。すでに使われているユーザーIDかもしれません。');
      }
    } catch (_) {
      _showError('登録に失敗しました。通信環境を確認してください。');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  ///
  void _showError(String message) {
    if (!mounted) {
      return;
    }
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black.withValues(alpha: 0.2),
        title: const Text('エラー', style: TextStyle(color: Colors.white, fontSize: 14)),
        content: Text(message, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
      ),
    );
  }
}
