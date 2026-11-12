// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Level _$LevelFromJson(Map<String, dynamic> json) => Level(
      id: (json['id'] as num).toInt(),
      gridSize: (json['gridSize'] as num).toInt(),
      targetScore: (json['targetScore'] as num).toInt(),
      maxMoves: (json['maxMoves'] as num).toInt(),
      startWord: json['startWord'] as String,
      startWordRow: (json['startWordRow'] as num).toInt(),
      startWordCol: (json['startWordCol'] as num).toInt(),
      direction: json['direction'] as String,
    );

Map<String, dynamic> _$LevelToJson(Level instance) => <String, dynamic>{
      'id': instance.id,
      'gridSize': instance.gridSize,
      'targetScore': instance.targetScore,
      'maxMoves': instance.maxMoves,
      'startWord': instance.startWord,
      'startWordRow': instance.startWordRow,
      'startWordCol': instance.startWordCol,
      'direction': instance.direction,
    };
