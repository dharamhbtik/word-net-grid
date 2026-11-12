import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'grid_cell.g.dart';

@JsonSerializable()
class GridCell extends Equatable {
  final int x;
  final int y;
  final String? letter;
  final bool isLocked;
  final bool isSelected;
  final bool isNew; // Part of the word currently being formed

  const GridCell({
    required this.x,
    required this.y,
    this.letter,
    this.isLocked = false,
    this.isSelected = false,
    this.isNew = false,
  });

  GridCell copyWith({
    String? letter,
    bool? isLocked,
    bool? isSelected,
    bool? isNew,
  }) {
    return GridCell(
      x: x,
      y: y,
      letter: letter ?? this.letter,
      isLocked: isLocked ?? this.isLocked,
      isSelected: isSelected ?? this.isSelected,
      isNew: isNew ?? this.isNew,
    );
  }

  @override
  List<Object?> get props => [x, y, letter, isLocked, isSelected, isNew];

  factory GridCell.fromJson(Map<String, dynamic> json) => _$GridCellFromJson(json);
  Map<String, dynamic> toJson() => _$GridCellToJson(this);
}
