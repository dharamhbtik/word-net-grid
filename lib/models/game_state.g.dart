// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameState _$GameStateFromJson(Map<String, dynamic> json) => GameState(
      levelId: (json['levelId'] as num).toInt(),
      currentScore: (json['currentScore'] as num).toInt(),
      movesRemaining: (json['movesRemaining'] as num).toInt(),
      grid: (json['grid'] as List<dynamic>)
          .map((e) => (e as List<dynamic>)
              .map((e) => GridCell.fromJson(e as Map<String, dynamic>))
              .toList())
          .toList(),
      placedWords: (json['placedWords'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isGameOver: json['isGameOver'] as bool? ?? false,
      isVictory: json['isVictory'] as bool? ?? false,
    );

Map<String, dynamic> _$GameStateToJson(GameState instance) => <String, dynamic>{
      'levelId': instance.levelId,
      'currentScore': instance.currentScore,
      'movesRemaining': instance.movesRemaining,
      'grid': instance.grid,
      'placedWords': instance.placedWords,
      'isGameOver': instance.isGameOver,
      'isVictory': instance.isVictory,
    };
