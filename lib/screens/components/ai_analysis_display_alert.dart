import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/app_param/app_param.dart';
import '../../controllers/controllers_mixin.dart';
import '../../data/http/client.dart';
import '../../data/http/path.dart';

class AiAnalysisDisplayAlert extends ConsumerStatefulWidget {
  const AiAnalysisDisplayAlert({super.key, required this.raceNumber});

  final int raceNumber;

  @override
  ConsumerState<AiAnalysisDisplayAlert> createState() => _AiAnalysisDisplayAlertState();
}

class _AiAnalysisDisplayAlertState extends ConsumerState<AiAnalysisDisplayAlert>
    with ControllersMixin<AiAnalysisDisplayAlert> {
  bool _isLoading = true;
  String _analysisText = '';

  // List<_PickupHorse> _pickupHorses = <_PickupHorse>[];
  //
  //
  //
  //

  String? _errorMessage;

  ///
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchAiAnalysis());
  }

  ///
  Future<void> _fetchAiAnalysis() async {
    final String date = appParamState.selectedScheduleDate;

    final List<String> kbdParts = appParamState.selectedScheduleKaisuuBashoDay.split('_');
    final String kaisuu = kbdParts.isNotEmpty ? kbdParts[0] : '';
    final String basho = kbdParts.length > 1 ? kbdParts[1] : '';
    final String day = kbdParts.length > 2 ? kbdParts[2] : '';

    try {
      final dynamic response = await ref
          .read(httpClientProvider)
          .get(
            path: APIPath.getHorseOddsFinderAiAnalysis,
            queryParameters: <String, dynamic>{
              'date': date,
              'kaisuu': kaisuu,
              'basho': basho,
              'day': day,
              'race': widget.raceNumber.toString(),
            },
          );
      final Map<String, dynamic> data =
          (response as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

      final String analysisText = (data['analysis_text'] as String?) ?? '';
      // final String pickupRaw = (data['pickup_horse'] as String?) ?? '';
      // // final List<_PickupHorse> pickupHorses = _parsePickupHorse(pickupRaw);
      // //
      // //
      // //
      //

      if (mounted) {
        setState(() {
          _analysisText = analysisText;
          // _pickupHorses = pickupHorses;
          //
          //
          //
          //
          //

          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'データの取得に失敗しました';
          _isLoading = false;
        });
      }
    }
  }

  // List<_PickupHorse> _parsePickupHorse(String raw) {
  //   if (raw.isEmpty) {
  //     return <_PickupHorse>[];
  //   }
  //   return raw.split('/').map((String part) {
  //     final List<String> pair = part.split('|');
  //     return _PickupHorse(num: pair.isNotEmpty ? pair[0] : '', name: pair.length > 1 ? pair[1] : '');
  //   }).toList();
  // }
  //
  //
  //

  ///
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(48),
        child: Center(child: CircularProgressIndicator(color: Colors.yellowAccent)),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 14)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          //
          //
          // if (_pickupHorses.isNotEmpty) ...<Widget>[
          //   Container(
          //     width: double.infinity,
          //     padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          //     decoration: BoxDecoration(
          //       color: Colors.yellowAccent.withValues(alpha: 0.08),
          //       border: Border.all(color: Colors.yellowAccent.withValues(alpha: 0.5)),
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //     child: Wrap(
          //       spacing: 12,
          //       runSpacing: 4,
          //       children: _pickupHorses.map((_PickupHorse e) {
          //         return Text(
          //           '${e.num}番 ${e.name}',
          //           style: const TextStyle(fontSize: 12, color: Colors.yellowAccent, fontWeight: FontWeight.bold),
          //         );
          //       }).toList(),
          //     ),
          //   ),
          //   const SizedBox(height: 12),
          // ],
          //
          //
          //
          Expanded(
            child: Markdown(
              data: _analysisText,
              padding: EdgeInsets.zero,
              styleSheet: MarkdownStyleSheet(
                h1: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
                h2: const TextStyle(fontSize: 13, color: Colors.greenAccent, fontWeight: FontWeight.bold),
                h3: const TextStyle(fontSize: 12, color: Colors.yellowAccent, fontWeight: FontWeight.bold),
                p: const TextStyle(fontSize: 11, color: Colors.white),
                strong: const TextStyle(fontSize: 11, color: Colors.yellowAccent, fontWeight: FontWeight.bold),
                em: const TextStyle(fontSize: 11, color: Colors.white70, fontStyle: FontStyle.italic),
                listBullet: const TextStyle(fontSize: 11, color: Colors.white70),
                blockquoteDecoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                horizontalRuleDecoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white24)),
                ),
                codeblockDecoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(4)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class _PickupHorse {
//   _PickupHorse({required this.num, required this.name});
//
//   final String num;
//   final String name;
// }
//
//
//
//
