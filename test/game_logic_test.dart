import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wordnetgrid/models/game_state.dart';
import 'package:wordnetgrid/models/grid_cell.dart';
import 'package:wordnetgrid/models/level.dart';
import 'package:wordnetgrid/providers/game_provider.dart';
import 'package:wordnetgrid/services/level_service.dart';
import 'package:wordnetgrid/services/play_games_service.dart';
import 'package:wordnetgrid/services/storage_service.dart';
import 'package:wordnetgrid/services/word_service.dart';

class MockWordService extends Mock implements WordService {}
class MockLevelService extends Mock implements LevelService {}
class MockStorageService extends Mock implements StorageService {}
class MockPlayGamesService extends Mock implements PlayGamesService {}

void main() {
  late GameController controller;
  late MockWordService mockWordService;
  late MockLevelService mockLevelService;
  late MockStorageService mockStorageService;
  late MockPlayGamesService mockPlayGamesService;

  setUpAll(() {
    registerFallbackValue(const GameState(
      levelId: 0,
      currentScore: 0,
      movesRemaining: 0,
      grid: [],
      placedWords: [],
    ));
  });

  setUp(() {
    mockWordService = MockWordService();
    mockLevelService = MockLevelService();
    mockStorageService = MockStorageService();
    mockPlayGamesService = MockPlayGamesService();

    // Default mocks
    when(() => mockWordService.loadDictionary()).thenAnswer((_) async {});
    when(() => mockStorageService.loadGameState()).thenAnswer((_) async => null);
    when(() => mockStorageService.saveGameState(any())).thenAnswer((_) async {});
    when(() => mockStorageService.saveHighScore(any(), any())).thenAnswer((_) async {});
    when(() => mockStorageService.markLevelComplete(any())).thenAnswer((_) async {});
    when(() => mockStorageService.getCompletedLevels()).thenAnswer((_) async => []);
    when(() => mockPlayGamesService.submitScore(leaderboardId: any(named: 'leaderboardId'), score: any(named: 'score')))
        .thenAnswer((_) async {});

    controller = GameController(
      mockWordService,
      mockLevelService,
      mockStorageService,
      mockPlayGamesService,
    );
  });

  test('Initial state is null', () {
    expect(controller.state, isNull);
  });

  test('Start level initializes game state correctly', () {
    final level = Level(
      id: 1,
      gridSize: 5,
      targetScore: 100,
      maxMoves: 10,
      startWord: "TEST",
      startWordRow: 2,
      startWordCol: 0,
      direction: "horizontal",
    );
    when(() => mockLevelService.getLevel(1)).thenReturn(level);

    controller.startLevel(1);

    expect(controller.state, isNotNull);
    expect(controller.state!.levelId, 1);
    expect(controller.state!.movesRemaining, 10);
    expect(controller.state!.currentScore, 0);
    expect(controller.state!.grid[2][0].letter, "T");
    expect(controller.state!.grid[2][1].letter, "E");
    expect(controller.state!.grid[2][2].letter, "S");
    expect(controller.state!.grid[2][3].letter, "T");
  });

  test('Input letter updates grid', () {
    final level = Level(
      id: 1,
      gridSize: 5,
      targetScore: 100,
      maxMoves: 10,
      startWord: "TEST",
      startWordRow: 2,
      startWordCol: 0,
      direction: "horizontal",
    );
    when(() => mockLevelService.getLevel(1)).thenReturn(level);
    controller.startLevel(1);

    // Select cell (2, 4) - right after TEST
    controller.selectCell(4, 2);
    controller.inputLetter("S");

    expect(controller.state!.grid[2][4].letter, "S");
    expect(controller.state!.grid[2][4].isNew, true);
  });

  test('Submit valid word updates score and moves', () async {
    final level = Level(
      id: 1,
      gridSize: 5,
      targetScore: 100,
      maxMoves: 10,
      startWord: "TEST",
      startWordRow: 2,
      startWordCol: 0,
      direction: "horizontal",
    );
    when(() => mockLevelService.getLevel(1)).thenReturn(level);
    when(() => mockWordService.isValidWord("TESTS")).thenReturn(true);

    controller.startLevel(1);

    // Form "TESTS" by adding 'S' at end
    controller.selectCell(4, 2);
    controller.inputLetter("S");
    
    await controller.submitWord();

    expect(controller.state!.currentScore, 50); // 5 letters * 10
    expect(controller.state!.movesRemaining, 9);
    expect(controller.state!.placedWords, contains("TESTS"));
    expect(controller.state!.grid[2][4].isLocked, true);
  });
  
  test('Submit invalid word clears new cells', () async {
    final level = Level(
      id: 1,
      gridSize: 5,
      targetScore: 100,
      maxMoves: 10,
      startWord: "TEST",
      startWordRow: 2,
      startWordCol: 0,
      direction: "horizontal",
    );
    when(() => mockLevelService.getLevel(1)).thenReturn(level);
    when(() => mockWordService.isValidWord("TESTX")).thenReturn(false);

    controller.startLevel(1);

    // Form "TESTX"
    controller.selectCell(4, 2);
    controller.inputLetter("X");
    
    await controller.submitWord();

    expect(controller.state!.currentScore, 0);
    expect(controller.state!.movesRemaining, 10);
    expect(controller.state!.grid[2][4].letter, isNull); // Cleared
  });
}
