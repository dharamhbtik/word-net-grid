import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../widgets/game_button.dart';
import 'level_select_screen.dart';
import '../../services/play_games_service.dart';
import '../../services/theme_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark || 
                   (themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      body: Stack(
        children: [
          // Background Pattern (Optional)
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: GridPaper(
                color: Theme.of(context).colorScheme.onSurface,
                divisions: 1,
                subdivisions: 1,
                interval: 50,
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  // Logo / Title
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 4,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "WORDNET",
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4.0,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          "GRID",
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w300,
                            letterSpacing: 8.0,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 1),
                  
                  // Buttons
                  GameButton(
                    label: "PLAY",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LevelSelectScreen()),
                      );
                    },
                    isPrimary: true,
                  ),
                  const Gap(20),
                  GameButton(
                    label: "LEADERBOARD",
                    onPressed: () {
                      ref.read(playGamesServiceProvider).showLeaderboards();
                    },
                  ),
                  const Gap(20),
                  GameButton(
                    label: "ACHIEVEMENTS",
                    onPressed: () {
                      ref.read(playGamesServiceProvider).showAchievements();
                    },
                  ),
                  const Gap(20),
                  GameButton(
                    label: "HOW TO PLAY",
                    onPressed: () {
                      _showTutorial(context);
                    },
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
          
          // Theme Toggle
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: IconButton(
              onPressed: () {
                ref.read(themeProvider.notifier).toggleTheme();
              },
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTutorial(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.95),
        title: const Text("HOW TO PLAY", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("📝 ADD LETTERS:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Tap any empty grid cell to select it, then tap a letter on the keyboard."),
              Gap(12),
              
              Text("⌫ REMOVE LETTERS:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Tap the Delete (⌫) button on the keyboard to remove the last added letter.\nOr, select a cell with your new letter and tap a different letter to replace it."),
              Gap(12),
              
              Text("🔗 CONNECT WORDS:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Your new word must connect to at least one existing word on the board (crossword style)."),
              Gap(12),
              
              Text("📏 PLACEMENT:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("• Words must be in a straight line (Horizontal or Vertical).\n• No gaps allowed within a word."),
              Gap(12),
              
              Text("🏆 WINNING:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Reach the target score before you run out of moves! Longer words score higher."),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("GOT IT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
