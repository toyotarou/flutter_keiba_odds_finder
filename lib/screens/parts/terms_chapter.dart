import 'package:flutter/material.dart';

class TermsChapter {
  const TermsChapter(this.title, this.body);

  final String title;
  final String body;
}

class TermsChapterTile extends StatelessWidget {
  const TermsChapterTile({super.key, required this.index, required this.chapter});

  final int index;
  final TermsChapter chapter;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 3,
            decoration: BoxDecoration(
              color: Colors.greenAccent.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  chapter.title,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  chapter.body,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12, height: 1.7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
