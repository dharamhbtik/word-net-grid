import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';

class StorageService {
  static const String _keyGameState = 'current_game_state';
  static const String _keyHighScores = 'high_scores';
  static const String _keyCompletedLevels = 'completed_levels';

  Future<void> saveGameState(GameState state) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(state.toJson());
    await prefs.setString(_keyGameState, jsonString);
  }

  Future<GameState?> loadGameState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyGameState);
    if (jsonString == null) return null;
    try {
      return GameState.fromJson(json.decode(jsonString));
    } catch (e) {
      print('Error parsing saved game state: $e');
      return null;
    }
  }

  Future<void> clearGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyGameState);
  }

  Future<void> saveHighScore(int levelId, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final highScores = await getHighScores();
    if ((highScores[levelId] ?? 0) < score) {
      highScores[levelId] = score;
      await prefs.setString(_keyHighScores, json.encode(mapIntKeysToString(highScores)));
    }
  }

  Future<Map<int, int>> getHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyHighScores);
    if (jsonString == null) return {};
    try {
      final Map<String, dynamic> decoded = json.decode(jsonString);
      return decoded.map((key, value) => MapEntry(int.parse(key), value as int));
    } catch (e) {
      return {};
    }
  }
  
  Future<void> markLevelComplete(int levelId) async {
     final prefs = await SharedPreferences.getInstance();
     final completed = await getCompletedLevels();
     if (!completed.contains(levelId)) {
       completed.add(levelId);
       await prefs.setStringList(_keyCompletedLevels, completed.map((e) => e.toString()).toList());
     }
  }
  
  Future<List<int>> getCompletedLevels() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyCompletedLevels);
    if (list == null) return [];
    return list.map((e) => int.parse(e)).toList();
  }

  Map<String, dynamic> mapIntKeysToString(Map<int, dynamic> map) {
    return map.map((key, value) => MapEntry(key.toString(), value));
  }
}

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());
