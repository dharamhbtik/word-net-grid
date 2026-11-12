import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game_provider.dart';

class KeyboardWidget extends ConsumerWidget {
  const KeyboardWidget({super.key});

  static const List<String> _keys = [
    "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P",
    "A", "S", "D", "F", "G", "H", "J", "K", "L",
    "Z", "X", "C", "V", "B", "N", "M"
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      child: Column(
        children: [
          _buildRow(context, ref, _keys.sublist(0, 10)),
          const SizedBox(height: 6),
          _buildRow(context, ref, _keys.sublist(10, 19)),
          const SizedBox(height: 6),
          Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               const SizedBox(width: 36), // Spacer for centering
               _buildRow(context, ref, _keys.sublist(19)),
               const SizedBox(width: 4),
               _buildSpecialKey(context, ref, Icons.backspace_outlined, () {
                  ref.read(gameControllerProvider.notifier).deleteLetter();
               }),
             ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, WidgetRef ref, List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((key) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: SizedBox(
            width: 32,
            height: 42,
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(4),
              elevation: 1,
              child: InkWell(
                onTap: () {
                  ref.read(gameControllerProvider.notifier).inputLetter(key);
                },
                borderRadius: BorderRadius.circular(4),
                child: Center(
                  child: Text(
                    key,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  Widget _buildSpecialKey(BuildContext context, WidgetRef ref, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        width: 48, // Slightly wider
        height: 42,
        child: Material(
          color: Theme.of(context).colorScheme.surfaceVariant, // Darker/Distinct
          borderRadius: BorderRadius.circular(4),
          elevation: 1,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(4),
            child: Center(
              child: Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
