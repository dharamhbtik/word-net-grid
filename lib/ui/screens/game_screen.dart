import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/game_provider.dart';
import '../../services/ad_service.dart';
import '../widgets/grid_widget.dart';
import '../widgets/keyboard_widget.dart';
import '../widgets/scattered_background.dart';
import '../widgets/glossy_container.dart';
import '../widgets/theme_toggle_button.dart';

class GameScreen extends ConsumerStatefulWidget {
  final int levelId;

  const GameScreen({super.key, required this.levelId});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameControllerProvider.notifier).initialize().then((_) {
        ref.read(gameControllerProvider.notifier).startLevel(widget.levelId);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameControllerProvider);

    if (gameState == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (gameState.isGameOver) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
         if (ModalRoute.of(context)?.isCurrent == true) {
            _showGameOverDialog(context, gameState.isVictory, gameState.currentScore);
         }
       });
    }

    return Scaffold(
      extendBodyBehindAppBar: true, // Allow background to show through app bar
      appBar: AppBar(
        title: Text("LEVEL ${gameState.levelId}"),
        backgroundColor: Colors.transparent, // Transparent for glass
        actions: [
          const ThemeToggleButton(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(gameControllerProvider.notifier).resetLevel();
            },
          ),
        ],
      ),
      body: ScatteredLettersBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Stats Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: GlossyContainer(
                  borderRadius: 15,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStat(context, "SCORE", "${gameState.currentScore}"),
                      _buildStat(context, "MOVES", "${gameState.movesRemaining}"),
                    ],
                  ),
                ),
              ),
              
              const Gap(10),
              
              // Grid
              Expanded(
                child: Center(
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GlossyContainer(
                        padding: const EdgeInsets.all(16.0),
                        child: GridWidget(grid: gameState.grid),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Controls
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     GlossyContainer(
                       borderRadius: 12,
                       opacity: 0.6,
                       child: ElevatedButton.icon(
                         onPressed: () async {
                           final error = await ref.read(gameControllerProvider.notifier).submitWord();
                           if (context.mounted) {
                             if (error != null) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(
                                   content: Text(
                                     error, 
                                     style: const TextStyle(color: Colors.white)
                                   ),
                                   backgroundColor: Colors.redAccent.withOpacity(0.8),
                                   behavior: SnackBarBehavior.floating,
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                   margin: const EdgeInsets.only(bottom: 200, left: 20, right: 20),
                                   duration: const Duration(seconds: 1),
                                 ),
                               );
                             }
                           }
                         },
                         icon: const Icon(Icons.check),
                         label: const Text("SUBMIT WORD"),
                         style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.transparent,
                           foregroundColor: Theme.of(context).colorScheme.primary,
                           elevation: 0,
                           padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(12),
                           ),
                         ),
                       ),
                     ),
                  ],
                ),
              ),

              // Keyboard
              const KeyboardWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  void _showGameOverDialog(BuildContext context, bool isVictory, int score) {
    final adService = ref.read(adServiceProvider);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        title: Text(isVictory ? "LEVEL COMPLETE!" : "GAME OVER"),
        content: Text(
          isVictory 
          ? "You scored $score points!" 
          : "Out of moves! Try again.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close dialog
              Navigator.pop(context); // Back to level select
            },
            child: const Text("EXIT"),
          ),
          
          // Watch Ad for Extra Moves (only if game over, not victory)
          if (!isVictory && adService.isRewardedAdLoaded)
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // Close dialog first
                
                final success = await adService.showRewardedAd(
                  onRewarded: (reward) {
                    // Give 3 extra moves
                    ref.read(gameControllerProvider.notifier).addMoves(3);
                  },
                );
                
                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Ad not ready. Try again later.")),
                  );
                }
              },
              child: const Text("🎬 +3 MOVES"),
            ),
          
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(gameControllerProvider.notifier).resetLevel();
            },
            child: const Text("RETRY"),
          ),
          
          if (isVictory)
             TextButton(
              onPressed: () async {
                 Navigator.pop(dialogContext); // Close Dialog
                 
                 // Show Interstitial Ad between levels
                 await adService.showInterstitialAd();
                 
                 // Navigate to next level
                 if (context.mounted) {
                   Navigator.pushReplacement(
                     context,
                     MaterialPageRoute(
                       builder: (context) => GameScreen(levelId: widget.levelId + 1),
                     ),
                   );
                 }
              },
              child: const Text("NEXT LEVEL"),
            ),
        ],
      ),
    );
  }
}
