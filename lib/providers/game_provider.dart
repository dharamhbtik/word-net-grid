import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/grid_cell.dart';
import '../models/level.dart';
import '../services/word_service.dart';
import '../services/level_service.dart';
import '../services/storage_service.dart';
import '../services/play_games_service.dart';

class GameController extends StateNotifier<GameState?> {
  final WordService _wordService;
  final LevelService _levelService;
  final StorageService _storageService;
  final PlayGamesService _playGamesService;

  GameController(
    this._wordService,
    this._levelService,
    this._storageService,
    this._playGamesService,
  ) : super(null);

  Future<void> initialize() async {
    await _wordService.loadDictionary();
    // Try to load saved game
    final savedGame = await _storageService.loadGameState();
    if (savedGame != null) {
      state = savedGame;
    }
  }

  void startLevel(int levelId) {
    final level = _levelService.getLevel(levelId);
    final grid = List.generate(
      level.gridSize,
      (y) => List.generate(
        level.gridSize,
        (x) => GridCell(x: x, y: y),
      ),
    );

    // Place start word
    for (int i = 0; i < level.startWord.length; i++) {
      int r = level.startWordRow;
      int c = level.startWordCol;
      if (level.direction == "horizontal") {
        c += i;
      } else {
        r += i;
      }
      if (r < level.gridSize && c < level.gridSize) {
        grid[r][c] = grid[r][c].copyWith(
          letter: level.startWord[i],
          isLocked: true,
        );
      }
    }

    state = GameState(
      levelId: levelId,
      currentScore: 0,
      movesRemaining: level.maxMoves,
      grid: grid,
      placedWords: [level.startWord],
    );
    
    _saveGame();
  }

  void selectCell(int x, int y) {
    if (state == null || state!.isGameOver) return;
    
    // Only allow selecting empty cells or cells that are part of the 'new' word being formed
    // Actually, for this game type, usually you pick a start cell and type?
    // Let's implement: Tap to place cursor.
    
    // Simple implementation: Toggle selection
    final currentGrid = List<List<GridCell>>.from(state!.grid.map((row) => List<GridCell>.from(row)));
    
    // Deselect all others if we want single selection
    for(var row in currentGrid) {
      for(var i=0; i<row.length; i++) {
        if(row[i].isSelected) {
           row[i] = row[i].copyWith(isSelected: false);
        }
      }
    }
    
    currentGrid[y][x] = currentGrid[y][x].copyWith(isSelected: true);
    
    state = state!.copyWith(grid: currentGrid);
  }

  void inputLetter(String letter) {
    if (state == null || state!.isGameOver) return;

    final currentGrid = List<List<GridCell>>.from(state!.grid.map((row) => List<GridCell>.from(row)));
    int? selX, selY;

    // Find selected cell
    for(int y=0; y<currentGrid.length; y++) {
      for(int x=0; x<currentGrid[y].length; x++) {
        if (currentGrid[y][x].isSelected) {
          selX = x;
          selY = y;
          break;
        }
      }
    }

    if (selX != null && selY != null) {
      if (!currentGrid[selY][selX].isLocked) {
         currentGrid[selY][selX] = currentGrid[selY][selX].copyWith(
           letter: letter.toUpperCase(),
           isNew: true,
         );
         
         // Auto-advance logic (optional, but nice)
         // Find next cell in direction if possible (logic can be complex, skip for now to keep simple)
         
         state = state!.copyWith(grid: currentGrid);
      }
    }
  }

  void deleteLetter() {
    if (state == null || state!.isGameOver) return;

    final currentGrid = List<List<GridCell>>.from(state!.grid.map((row) => List<GridCell>.from(row)));
    
    // 1. Check selected cell
    int? selX, selY;
    for(int y=0; y<currentGrid.length; y++) {
      for(int x=0; x<currentGrid[y].length; x++) {
        if (currentGrid[y][x].isSelected) {
          selX = x;
          selY = y;
          break;
        }
      }
    }

    if (selX != null && selY != null) {
      // If selected cell has a new letter, clear it
      if (currentGrid[selY][selX].isNew) {
        currentGrid[selY][selX] = GridCell(
            x: selX,
            y: selY,
            letter: null, // Clear letter
            isLocked: false,
            isSelected: true,
            isNew: false,
        );
        state = state!.copyWith(grid: currentGrid);
        return;
      }
    }
    
    // If selected cell was empty or locked (can't delete locked), try to delete the *last* new cell added?
    // Without tracking history, we can't easily know "last". 
    // Best fallback: Do nothing if selected isn't deletable. User must select to delete.
  }
  
  void clearSelection() {
     _clearNewCells();
  }
  
  /// Add extra moves (e.g., from rewarded ad)
  void addMoves(int moves) {
    if (state == null) return;
    
    state = state!.copyWith(
      movesRemaining: state!.movesRemaining + moves,
      isGameOver: false, // Return to playing state
    );
  }

  Future<String?> submitWord() async {
    if (state == null || state!.isGameOver) return null;
    
    final grid = state!.grid;
    List<GridCell> newCells = [];
    for(var row in grid) {
      for(var cell in row) {
        if (cell.isNew) newCells.add(cell);
      }
    }

    if (newCells.isEmpty) return "No letters placed";

    // Check if they are in a line (horizontal or vertical)
    bool isHorizontal = newCells.every((c) => c.y == newCells.first.y);
    bool isVertical = newCells.every((c) => c.x == newCells.first.x);

    if (!isHorizontal && !isVertical) {
      _clearNewCells();
      return "Letters must be in a straight line";
    }

    // Sort cells
    newCells.sort((a, b) => isHorizontal ? a.x.compareTo(b.x) : a.y.compareTo(b.y));
    
    // Check for continuity in placement (gaps between new cells)
    // Note: Gaps filled by existing locked cells are okay.
    // We check this by scanning the full range.

    // Check for gaps and collect the full word including existing locked letters
    List<GridCell> fullWordCells = [];
    int startIdx = isHorizontal ? newCells.first.x : newCells.first.y;
    int endIdx = isHorizontal ? newCells.last.x : newCells.last.y;
    int fixedCoord = isHorizontal ? newCells.first.y : newCells.first.x;

    // Scan backwards
    int curr = startIdx;
    while(curr > 0) {
      var cell = isHorizontal ? grid[fixedCoord][curr - 1] : grid[curr - 1][fixedCoord];
      if (cell.letter != null) {
        curr--;
      } else {
        break;
      }
    }
    int wordStart = curr;

    // Scan forwards
    curr = endIdx;
    int limit = isHorizontal ? grid[0].length : grid.length;
    while(curr < limit - 1) {
      var cell = isHorizontal ? grid[fixedCoord][curr + 1] : grid[curr + 1][fixedCoord];
      if (cell.letter != null) {
        curr++;
      } else {
        break;
      }
    }
    int wordEnd = curr;

    // Construct the word
    String word = "";
    bool intersectsExisting = false;

    for (int i = wordStart; i <= wordEnd; i++) {
      var cell = isHorizontal ? grid[fixedCoord][i] : grid[i][fixedCoord];
      if (cell.letter == null) {
        _clearNewCells();
        return "Word cannot have gaps";
      }
      word += cell.letter!;
      if (cell.isLocked) intersectsExisting = true;
    }

    // Validation Rules
    // 1. Must intersect existing word (unless it's the first move, but we start with a word)
    if (!intersectsExisting && state!.placedWords.isNotEmpty) {
       _clearNewCells();
       return "Must connect to an existing word";
    }
    
    // 2. Must be a valid dictionary word
    if (!_wordService.isValidWord(word)) {
      _clearNewCells();
      return "Not a valid word: $word";
    }

    // Success!
    // Calculate Score
    int wordScore = word.length * 10; 
    
    // Update State
    final newGrid = List<List<GridCell>>.from(grid.map((row) => List<GridCell>.from(row)));
    
    // Lock new cells
    for(var cell in newCells) {
      newGrid[cell.y][cell.x] = newGrid[cell.y][cell.x].copyWith(
        isNew: false,
        isLocked: true,
        isSelected: false,
      );
    }

    final newScore = state!.currentScore + wordScore;
    final newMoves = state!.movesRemaining - 1;
    final newPlacedWords = List<String>.from(state!.placedWords)..add(word);
    
    // Check Victory
    final level = _levelService.getLevel(state!.levelId);
    bool victory = newScore >= level.targetScore;
    bool gameOver = newMoves <= 0 && !victory;

    state = state!.copyWith(
      grid: newGrid,
      currentScore: newScore,
      movesRemaining: newMoves,
      placedWords: newPlacedWords,
      isVictory: victory,
      isGameOver: gameOver || victory,
    );

    _saveGame();
    
    if (victory) {
      _storageService.markLevelComplete(state!.levelId);
      _storageService.saveHighScore(state!.levelId, newScore);
      try {
        await _playGamesService.submitScore(score: newScore);
        
        // Unlock Achievements
        await _playGamesService.unlockFirstWord();
        
        if (state!.levelId >= 5) {
          await _playGamesService.unlockLevel5Master();
        }
        
        if (newScore >= 1000) {
          await _playGamesService.unlockScore1000();
        }
        
        // Check for Word Smith (if any word was long)
        // Ideally checking the just submitted word is better
        if (word.length >= 6) {
           await _playGamesService.unlockWordSmith();
        }

      } catch (_) {}
    }
    
    return null; // Success (no error)
  }

  void _clearNewCells() {
    if (state == null) return;
    final currentGrid = List<List<GridCell>>.from(state!.grid.map((row) => List<GridCell>.from(row)));
    for(int y=0; y<currentGrid.length; y++) {
      for(int x=0; x<currentGrid[y].length; x++) {
        if (currentGrid[y][x].isNew) {
          currentGrid[y][x] = GridCell(
            x: x,
            y: y,
            letter: null,
            isLocked: currentGrid[y][x].isLocked,
            isSelected: currentGrid[y][x].isSelected,
            isNew: false,
          );
        }
      }
    }
    state = state!.copyWith(grid: currentGrid);
  }
  
  void resetLevel() {
    if (state != null) {
      startLevel(state!.levelId);
    }
  }

  void _saveGame() {
    if (state != null) {
      _storageService.saveGameState(state!);
    }
  }
}

final gameControllerProvider = AutoDisposeStateNotifierProvider<GameController, GameState?>((ref) {
  return GameController(
    ref.watch(wordServiceProvider),
    ref.watch(levelServiceProvider),
    ref.watch(storageServiceProvider),
    ref.watch(playGamesServiceProvider),
  );
});
