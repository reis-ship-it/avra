import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

class WordPieceTokenizer {
  final Map<String, int> vocab;
  final String unkToken;
  final String clsToken;
  final String sepToken;
  final bool doLowerCase;

  WordPieceTokenizer({
    required this.vocab,
    this.unkToken = '[UNK]',
    this.clsToken = '[CLS]',
    this.sepToken = '[SEP]',
    this.doLowerCase = false,
  });

  static Future<WordPieceTokenizer> fromAsset(String assetPath, {bool doLowerCase = false}) async {
    final content = await rootBundle.loadString(assetPath);
    final lines = const LineSplitter().convert(content);
    final map = <String, int>{};
    for (var i = 0; i < lines.length; i++) {
      map[lines[i]] = i;
    }
    return WordPieceTokenizer(vocab: map, doLowerCase: doLowerCase);
  }

  List<int> tokenizeToIds(String text, int maxLen) {
    final tokens = _basicTokens(text);
    final pieces = <String>[];
    for (final t in tokens) {
      pieces.addAll(_wordpiece(t));
    }
    // Add [CLS] + [SEP]
    final ids = <int>[
      vocab[clsToken] ?? 101,
      ...pieces.map((p) => vocab[p] ?? (vocab[unkToken] ?? 100)),
      vocab[sepToken] ?? 102,
    ];
    // Pad/truncate
    if (ids.length > maxLen) {
      return ids.sublist(0, maxLen);
    }
    final padId = vocab['[PAD]'] ?? 0;
    return ids + List.filled(maxLen - ids.length, padId);
  }

  List<int> attentionMaskFor(List<int> ids) => ids.map((e) => e == (vocab['[PAD]'] ?? 0) ? 0 : 1).toList();

  List<String> _basicTokens(String text) {
    final s = doLowerCase ? text.toLowerCase() : text;
    return s.split(RegExp(r"\s+")).where((t) => t.isNotEmpty).toList();
  }

  List<String> _wordpiece(String token) {
    if (vocab.containsKey(token)) return [token];
    final chars = token.split('');
    final pieces = <String>[];
    var start = 0;
    while (start < chars.length) {
      var end = chars.length;
      String? cur;
      while (start < end) {
        var substr = chars.sublist(start, end).join();
        if (start > 0) substr = '##$substr';
        if (vocab.containsKey(substr)) { cur = substr; break; }
        end -= 1;
      }
      cur ??= unkToken;
      pieces.add(cur);
      start = end;
    }
    return pieces;
  }
}


