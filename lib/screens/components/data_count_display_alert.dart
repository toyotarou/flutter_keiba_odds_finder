import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
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

    try {
      final HttpClient client = ref.read(httpClientProvider);
      final dynamic response = await client.get(path: APIPath.getHorseOddsFinderSummaryTableCount);

      // ignore: avoid_dynamic_calls
      final List<dynamic> data = response['data'] as List<dynamic>;
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
    } catch (e) {
      debugPrint('DataCountDisplayAlert error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
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
        return DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Container(
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
                    children: <Widget>[
                      Text(item.date, style: const TextStyle(color: Colors.white)),
                      const SizedBox.shrink(),
                    ],
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
                                child: const Text('summary', style: TextStyle(fontSize: 10, color: Colors.white)),
                              ),

                              const SizedBox(height: 3),

                              Text(item.summaryCount.toString(), style: const TextStyle(color: Colors.white)),
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
                                child: const Text('history', style: TextStyle(fontSize: 10, color: Colors.white)),
                              ),

                              const SizedBox(height: 3),

                              Text(item.historyCount.toString(), style: const TextStyle(color: Colors.white)),
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
                                child: const Text('popularity', style: TextStyle(fontSize: 10, color: Colors.white)),
                              ),

                              const SizedBox(height: 3),

                              Text(
                                item.historyPopularityRankCount.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
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
                                child: const Text('finishing', style: TextStyle(fontSize: 10, color: Colors.white)),
                              ),

                              const SizedBox(height: 3),

                              Text(
                                item.historyFinishingPositionCount.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
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
                                child: const Text('payout', style: TextStyle(fontSize: 10, color: Colors.white)),
                              ),

                              const SizedBox(height: 3),

                              Text(item.payoutCount.toString(), style: const TextStyle(color: Colors.white)),
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
                                child: const Text('ratio', style: TextStyle(fontSize: 10, color: Colors.white)),
                              ),

                              const SizedBox(height: 3),

                              Text(item.ratioCount.toString(), style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
