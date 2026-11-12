import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/level_service.dart';
import '../../services/storage_service.dart';
import '../../services/ad_service.dart';
import '../widgets/theme_toggle_button.dart';
import 'game_screen.dart';

class LevelSelectScreen extends ConsumerStatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  ConsumerState<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends ConsumerState<LevelSelectScreen> {
  List<int> _completedLevels = [];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final completed = await ref.read(storageServiceProvider).getCompletedLevels();
    setState(() {
      _completedLevels = completed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final levels = ref.read(levelServiceProvider).getLevels();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "SELECT LEVEL",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        centerTitle: true,
        actions: const [
          ThemeToggleButton(),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Level Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // More dense grid
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.0,
                ),
                itemCount: levels.length,
                itemBuilder: (context, index) {
                  final level = levels[index];
                  final isUnlocked = index == 0 || _completedLevels.contains(levels[index - 1].id);
                  final isCompleted = _completedLevels.contains(level.id);

                  return InkWell(
                    onTap: isUnlocked
                        ? () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GameScreen(levelId: level.id),
                              ),
                            );
                            _loadProgress(); // Refresh on return
                          }
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? (isCompleted 
                                ? const Color(0xFF27AE60) 
                                : Theme.of(context).colorScheme.surface)
                            : Theme.of(context).disabledColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                        border: isUnlocked && !isCompleted
                            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                            : null,
                        boxShadow: isUnlocked
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : [],
                      ),
                      child: Center(
                        child: isUnlocked
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${level.id}",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isCompleted 
                                          ? Colors.white 
                                          : Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  if (isCompleted)
                                    const Icon(Icons.star, color: Colors.yellow, size: 16),
                                ],
                              )
                            : Icon(
                                Icons.lock, 
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                size: 20,
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Banner Ad at bottom
            Consumer(
              builder: (context, ref, child) {
                final adService = ref.watch(adServiceProvider);
                if (adService.isBannerAdLoaded && adService.bannerAd != null) {
                  return Container(
                    alignment: Alignment.center,
                    width: adService.bannerAd!.size.width.toDouble(),
                    height: adService.bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: adService.bannerAd!),
                  );
                }
                return const SizedBox(height: 50); // Placeholder space
              },
            ),
          ],
        ),
      ),
    );
  }
}
