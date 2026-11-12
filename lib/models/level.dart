import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'level.g.dart';

@JsonSerializable()
class Level extends Equatable {
  final int id;
  final int gridSize; // 5 or 6
  final int targetScore;
  final int maxMoves;
  final String startWord;
  final int startWordRow;
  final int startWordCol;
  final String direction; // "horizontal" or "vertical"

  const Level({
    required this.id,
    required this.gridSize,
    required this.targetScore,
    required this.maxMoves,
    required this.startWord,
    required this.startWordRow,
    required this.startWordCol,
    required this.direction,
  });

  @override
  List<Object?> get props => [id, gridSize, targetScore, maxMoves, startWord, startWordRow, startWordCol, direction];

  factory Level.fromJson(Map<String, dynamic> json) => _$LevelFromJson(json);
  Map<String, dynamic> toJson() => _$LevelToJson(this);
}
