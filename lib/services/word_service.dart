import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WordService {
  Set<String> _validWords = {};
  bool _isLoaded = false;

  Future<void> loadDictionary() async {
    if (_isLoaded) return;
    try {
      final String response = await rootBundle.loadString('assets/words/words.json');
      final List<dynamic> data = json.decode(response);
      _validWords = data.map((e) => e.toString().toUpperCase()).toSet();
      _isLoaded = true;
    } catch (e) {
      print("Error loading dictionary: $e");
      // Fallback or retry logic could go here
    }
  }

  bool isValidWord(String word) {
    return _validWords.contains(word.toUpperCase());
  }
}

final wordServiceProvider = Provider<WordService>((ref) => WordService());
