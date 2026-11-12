import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'grid_cell.dart';

part 'game_state.g.dart';

@JsonSerializable()
class GameState extends Equatable {
  final int levelId;
  final int currentScore;
  final int movesRemaining;
  final List<List<GridCell>> grid;
  final List<String> placedWords;
  final bool isGameOver;
  final bool isVictory;

  const GameState({
    required this.levelId,
    required this.currentScore,
    required this.movesRemaining,
    required this.grid,
    required this.placedWords,
    this.isGameOver = false,
    this.isVictory = false,
  });

  GameState copyWith({
    int? levelId,
    int? currentScore,
    int? movesRemaining,
    List<List<GridCell>>? grid,
    List<String>? placedWords,
    bool? isGameOver,
    bool? isVictory,
  }) {
    return GameState(
      levelId: levelId ?? this.levelId,
      currentScore: currentScore ?? this.currentScore,
      movesRemaining: movesRemaining ?? this.movesRemaining,
      grid: grid ?? this.grid,
      placedWords: placedWords ?? this.placedWords,
      isGameOver: isGameOver ?? this.isGameOver,
      isVictory: isVictory ?? this.isVictory,
    );
  }

  @override
  List<Object?> get props => [levelId, currentScore, movesRemaining, grid, placedWords, isGameOver, isVictory];

  factory GameState.fromJson(Map<String, dynamic> json) => _$GameStateFromJson(json);
  Map<String, dynamic> toJson() => _$GameStateToJson(this);
}
