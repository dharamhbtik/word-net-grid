import 'dart:math';
import 'package:flutter/material.dart';

class ScatteredLettersBackground extends StatefulWidget {
  final Widget child;

  const ScatteredLettersBackground({super.key, required this.child});

  @override
  State<ScatteredLettersBackground> createState() => _ScatteredLettersBackgroundState();
}

class _ScatteredLettersBackgroundState extends State<ScatteredLettersBackground>
    with SingleTickerProviderStateMixin {
  late List<_ScatteredLetter> letters;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    
    // Generate static random letters
    letters = List.generate(20, (index) => _ScatteredLetter(index));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Color
        Positioned.fill(
          child: Container(
             color: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
        
        // Scattered Letters
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: letters.map((l) {
                // Calculate float movement
                final offset = l.speed * _controller.value; 
                final dy = (l.y + offset) % 1.0; 
                
                return Positioned(
                  left: l.x * MediaQuery.of(context).size.width,
                  top: dy * MediaQuery.of(context).size.height,
                  child: Opacity(
                    opacity: 0.1, // Subtle
                    child: Transform.rotate(
                      angle: l.rotation,
                      child: Text(
                        l.char,
                        style: TextStyle(
                          fontSize: l.size,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          fontFamily: 'Roboto', // Or standard font
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),

        // Foreground Content
        widget.child,
      ],
    );
  }
}

class _ScatteredLetter {
  late String char;
  late double x;
  late double y;
  late double rotation;
  late double size;
  late double speed;

  _ScatteredLetter(int index) {
    final rnd = Random(index);
    char = String.fromCharCode(65 + rnd.nextInt(26)); // A-Z
    x = rnd.nextDouble();
    y = rnd.nextDouble();
    rotation = rnd.nextDouble() * pi / 2 - pi / 4; // -45 to 45 deg
    size = 20.0 + rnd.nextDouble() * 60.0;
    speed = 0.1 + rnd.nextDouble() * 0.2; // Vertical drift speed
  }
}
