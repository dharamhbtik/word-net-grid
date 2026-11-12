import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/level.dart';

class LevelService {
  List<Level> getLevels() {
    // Base levels with specific start words
    final List<Level> levels = [
      const Level(
        id: 1,
        gridSize: 5,
        targetScore: 100,
        maxMoves: 10,
        startWord: "RAIN",
        startWordRow: 2,
        startWordCol: 1,
        direction: "horizontal",
      ),
      const Level(
        id: 2,
        gridSize: 5,
        targetScore: 200,
        maxMoves: 15,
        startWord: "STORM",
        startWordRow: 2,
        startWordCol: 0,
        direction: "horizontal",
      ),
      const Level(
        id: 3,
        gridSize: 6,
        targetScore: 350,
        maxMoves: 20,
        startWord: "PLANET",
        startWordRow: 2,
        startWordCol: 0,
        direction: "horizontal",
      ),
       const Level(
        id: 4,
        gridSize: 6,
        targetScore: 500,
        maxMoves: 25,
        startWord: "GALAXY",
        startWordRow: 3,
        startWordCol: 0,
        direction: "horizontal",
      ),
    ];

    // Procedurally generate more levels
    final List<String> startWords = [
      "CLOUD", "EARTH", "SPACE", "LIGHT", "SOUND", "MUSIC", "DANCE", "PARTY",
      "HAPPY", "SMILE", "LAUGH", "DREAM", "NIGHT", "STARS", "SHINE", "BLOOM",
      "FLOWER", "GARDEN", "WATER", "RIVER", "OCEAN", "BEACH", "SANDY", "SHELL",
      "PEARL", "STONE"
    ];

    for (int i = 0; i < startWords.length; i++) {
      int levelId = levels.length + 1;
      int gridSize = levelId < 10 ? 5 : 6;
      int targetScore = 500 + (i * 50);
      int maxMoves = 20 + (i % 5);
      
      levels.add(Level(
        id: levelId,
        gridSize: gridSize,
        targetScore: targetScore,
        maxMoves: maxMoves,
        startWord: startWords[i],
        startWordRow: gridSize ~/ 2,
        startWordCol: 0,
        direction: "horizontal",
      ));
    }

    return levels;
  }

  Level getLevel(int id) {
    return getLevels().firstWhere((level) => level.id == id, orElse: () => getLevels().first);
  }
}

final levelServiceProvider = Provider<LevelService>((ref) => LevelService());
