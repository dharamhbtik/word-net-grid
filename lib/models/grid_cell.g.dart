// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grid_cell.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GridCell _$GridCellFromJson(Map<String, dynamic> json) => GridCell(
      x: (json['x'] as num).toInt(),
      y: (json['y'] as num).toInt(),
      letter: json['letter'] as String?,
      isLocked: json['isLocked'] as bool? ?? false,
      isSelected: json['isSelected'] as bool? ?? false,
      isNew: json['isNew'] as bool? ?? false,
    );

Map<String, dynamic> _$GridCellToJson(GridCell instance) => <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'letter': instance.letter,
      'isLocked': instance.isLocked,
      'isSelected': instance.isSelected,
      'isNew': instance.isNew,
    };
