import 'package:games_services/games_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

class PlayGamesService {
  bool _isSignedIn = false;

  bool get isSignedIn => _isSignedIn;

  // Actual IDs from Google Play Console
  static const String _leaderboardHighScore = "CgkI8Iz02MwLEAIQBQ"; 
  static const String _achievementFirstWord = "CgkI8Iz02MwLEAIQAQ";
  static const String _achievementLevel5Master = "CgkI8Iz02MwLEAIQAg";
  static const String _achievementWordSmith = "CgkI8Iz02MwLEAIQAw";
  static const String _achievementScore1000 = "CgkI8Iz02MwLEAIQBA";

  /// Sign in to Play Games Services (v2 uses automatic sign-in)
  Future<void> signIn() async {
    try {
      // games_services v4 uses Play Games SDK v2
      // v2 handles sign-in automatically, but we can check authentication
      final isAuthenticated = await GamesServices.isSignedIn;
      if (!isAuthenticated) {
        await GamesServices.signIn();
      }
      _isSignedIn = await GamesServices.isSignedIn;
      debugPrint("Play Games Sign In: $_isSignedIn");
    } catch (e) {
      debugPrint("Play Games Sign In Error: $e");
      _isSignedIn = false;
    }
  }

  Future<void> submitScore({required int score}) async {
    try {
      await GamesServices.submitScore(
        score: Score(
          androidLeaderboardID: _leaderboardHighScore,
          value: score,
        ),
      );
      debugPrint("Score submitted: $score");
    } catch (e) {
      debugPrint("Submit Score Error: $e");
    }
  }

  Future<void> unlockFirstWord() async {
    await _unlockAchievement(_achievementFirstWord);
  }

  Future<void> unlockLevel5Master() async {
    await _unlockAchievement(_achievementLevel5Master);
  }

  Future<void> unlockWordSmith() async {
    await _unlockAchievement(_achievementWordSmith);
  }
  
  Future<void> unlockScore1000() async {
    await _unlockAchievement(_achievementScore1000);
  }

  Future<void> _unlockAchievement(String id) async {
    try {
      await GamesServices.unlock(
        achievement: Achievement(androidID: id),
      );
      debugPrint("Achievement unlocked: $id");
    } catch (e) {
      debugPrint("Unlock Achievement Error: $e");
    }
  }

  Future<void> showLeaderboards() async {
    try {
      await GamesServices.showLeaderboards(
        androidLeaderboardID: _leaderboardHighScore,
      );
    } catch (e) {
      debugPrint("Show Leaderboards Error: $e");
    }
  }

  Future<void> showAchievements() async {
    try {
      await GamesServices.showAchievements();
    } catch (e) {
      debugPrint("Show Achievements Error: $e");
    }
  }
  
  // Cloud Save (Saved Games) - v4 API
  Future<void> saveGame(String data) async {
    try {
      await GamesServices.saveGame(
        data: data,
        name: "wordnetgrid_save",
      );
      debugPrint("Game saved to cloud");
    } catch (e) {
      debugPrint("Save Game Error: $e");
    }
  }

  Future<String?> loadGame() async {
    try {
      final String? savedData = await GamesServices.loadGame(
        name: "wordnetgrid_save",
      );
      return savedData;
    } catch (e) {
      debugPrint("Load Game Error: $e");
      return null;
    }
  }
}

final playGamesServiceProvider = Provider<PlayGamesService>((ref) => PlayGamesService());

