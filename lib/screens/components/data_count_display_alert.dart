import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../models/data_count_model.dart';

class DataCountDisplayAlert extends ConsumerStatefulWidget {
  const DataCountDisplayAlert({super.key});

  @override
  ConsumerState<DataCountDisplayAlert> createState() => _DataCountDisplayAlertState();
}

class _DataCountDisplayAlertState extends ConsumerState<DataCountDisplayAlert> {
  List<DataCountModel> _dataCountList = <DataCountModel>[];
  bool _isLoading = true;
  bool _hasError = false;
  final ScrollController _scrollController = ScrollController();

  static const int _maxRetries = 3;
  static const Duration _timeout = Duration(seconds: 30);
  static const Duration _retryDelay = Duration(seconds: 2);

  ///
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  ///
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  ///
  Future<void> _fetchData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        final Uri uri = Uri.http('49.212.166.123', '/api/getHorseOddsFinderSummaryTableCount');

        final http.Response response = await http
            .get(uri, headers: <String, String>{'content-type': 'application/json', 'Accept': 'application/json'})
            .timeout(_timeout);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final String bodyString = utf8.decode(response.bodyBytes);
          final Map<String, dynamic> decoded = jsonDecode(bodyString) as Map<String, dynamic>;
          final List<dynamic> data = decoded['data'] as List<dynamic>;
          final List<DataCountModel> list = data
              .map((dynamic e) => DataCountModel.fromJson(e as Map<String, dynamic>))
              .toList();

          if (mounted) {
            setState(() {
              _dataCountList = list;
              _isLoading = false;
              _hasError = false;
            });
          }
          return;
        }

        debugPrint('DataCountDisplayAlert: HTTP ${response.statusCode} (attempt $attempt)');
      } catch (e, st) {
        debugPrint('DataCountDisplayAlert error (attempt $attempt): $e');
        debugPrint('$st');
      }

      if (attempt < _maxRetries && mounted) {
        await Future<void>.delayed(_retryDelay);
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('サマリーテーブル確認', style: TextStyle(fontSize: 12)),
                Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 5),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const SizedBox.shrink(),

                    Row(
                      children: <Widget>[
                        IconButton(
                          onPressed: () {
                            _scrollController.animateTo(
                              0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          },
                          icon: const Icon(Icons.arrow_upward),
                        ),

                        IconButton(
                          onPressed: () {
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          },
                          icon: const Icon(Icons.arrow_downward),
                        ),
                      ],
                    ),
                  ],
                ),

                Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 2),

                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (_hasError || _dataCountList.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('データの取得に失敗しました', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _fetchData,
              child: const Text('再試行', style: TextStyle(color: Colors.greenAccent)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _dataCountList.length,
      itemBuilder: (BuildContext context, int index) {
        final DataCountModel item = _dataCountList[index];
        return Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
          ),
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 10),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[Text(item.date), const SizedBox.shrink()],
                ),

                const SizedBox(height: 10),

                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              decoration: BoxDecoration(color: Colors.yellowAccent.withValues(alpha: 0.1)),
                              child: const Text('summary', style: TextStyle(fontSize: 10)),
                            ),

                            const SizedBox(height: 3),

                            Text(item.summaryCount.toString()),
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      child: Container(margin: const EdgeInsets.all(8.0), child: const SizedBox.shrink()),
                    ),
                  ],
                ),

                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              decoration: BoxDecoration(color: Colors.yellowAccent.withValues(alpha: 0.1)),
                              child: const Text('history', style: TextStyle(fontSize: 10)),
                            ),

                            const SizedBox(height: 3),

                            Text(item.historyCount.toString()),
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              decoration: BoxDecoration(color: Colors.yellowAccent.withValues(alpha: 0.1)),
                              child: const Text('popularity', style: TextStyle(fontSize: 10)),
                            ),

                            const SizedBox(height: 3),

                            Text(item.historyPopularityRankCount.toString()),
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              decoration: BoxDecoration(color: Colors.yellowAccent.withValues(alpha: 0.1)),
                              child: const Text('finishing', style: TextStyle(fontSize: 10)),
                            ),

                            const SizedBox(height: 3),

                            Text(item.historyFinishingPositionCount.toString()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              decoration: BoxDecoration(color: Colors.yellowAccent.withValues(alpha: 0.1)),
                              child: const Text('payout', style: TextStyle(fontSize: 10)),
                            ),

                            const SizedBox(height: 3),

                            Text(item.payoutCount.toString()),
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              decoration: BoxDecoration(color: Colors.yellowAccent.withValues(alpha: 0.1)),
                              child: const Text('ratio', style: TextStyle(fontSize: 10)),
                            ),

                            const SizedBox(height: 3),

                            Text(item.ratioCount.toString()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
