import 'package:flutter/widgets.dart';

/// A tab icon drawn as a colour emoji, so every tab uses colour icons in one
/// style (architecture 10.7). The tab's label carries the meaning, so the
/// emoji is hidden from screen readers.
class ColourTabIcon extends StatelessWidget {
  const ColourTabIcon({required this.emoji, this.size = 24, super.key});

  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: size,
      child: Center(
        child: Text(
          emoji,
          textScaler: TextScaler.noScaling,
          style: TextStyle(fontSize: size, height: 1),
        ),
      ),
    ),
  );
}
