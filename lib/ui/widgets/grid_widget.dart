import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/grid_cell.dart';
import '../../providers/game_provider.dart';

class GridWidget extends ConsumerWidget {
  final List<List<GridCell>> grid;

  const GridWidget({super.key, required this.grid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gridSize = grid.length;
    
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: List.generate(gridSize, (y) {
            return Expanded(
              child: Row(
                children: List.generate(gridSize, (x) {
                  final cell = grid[y][x];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ref.read(gameControllerProvider.notifier).selectCell(x, y);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: _getCellColor(context, cell),
                          borderRadius: BorderRadius.circular(8),
                          border: cell.isSelected
                              ? Border.all(color: Theme.of(context).colorScheme.primary, width: 3)
                              : Border.all(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.15), 
                                  width: 1
                                ),
                          boxShadow: cell.letter != null
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 2,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            cell.letter ?? "",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _getTextColor(context, cell),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }

  Color _getCellColor(BuildContext context, GridCell cell) {
    if (cell.isLocked) return Theme.of(context).colorScheme.primary.withOpacity(0.9);
    if (cell.isNew) return const Color(0xFFF1C40F).withOpacity(0.9); 
    // Empty cells - very glossy/transparent
    return Theme.of(context).colorScheme.surface.withOpacity(0.3);
  }

  Color _getTextColor(BuildContext context, GridCell cell) {
    if (cell.isLocked) return Theme.of(context).colorScheme.onPrimary;
    if (cell.isNew) return Colors.black;
    return Theme.of(context).colorScheme.onSurface;
  }
}
