import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/game/pixel_harmony_game.dart';

class GameplayScreen extends StatefulWidget {
  const GameplayScreen({super.key});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  late final PixelHarmonyGame _game = PixelHarmonyGame();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).gameplayTitle)),
      body: GameWidget<PixelHarmonyGame>(
        key: const Key('gameplayGameWidget'),
        game: _game,
      ),
    );
  }
}
