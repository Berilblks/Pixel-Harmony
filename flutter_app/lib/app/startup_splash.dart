import 'dart:async';

import 'package:flutter/material.dart';

class StartupSplash extends StatefulWidget {
  const StartupSplash({
    super.key,
    required this.child,
    this.holdDuration = const Duration(milliseconds: 1400),
    this.fadeDuration = const Duration(milliseconds: 300),
  });

  final Widget child;
  final Duration holdDuration;
  final Duration fadeDuration;

  @override
  State<StartupSplash> createState() => _StartupSplashState();
}

class _StartupSplashState extends State<StartupSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  Timer? _holdTimer;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: widget.fadeDuration,
      value: 1,
    )..addStatusListener(_handleFadeStatus);
    _holdTimer = Timer(widget.holdDuration, _startFadeOut);
  }

  void _startFadeOut() {
    if (!mounted) return;
    _fadeController.reverse();
  }

  void _handleFadeStatus(AnimationStatus status) {
    if (status != AnimationStatus.dismissed || !mounted) return;
    setState(() => _showSplash = false);
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (_showSplash)
            FadeTransition(
              key: const Key('startupSplash'),
              opacity: _fadeController,
              child: const ColoredBox(
                color: Color(0xFFF4EEFA),
                child: Center(
                  child: SizedBox.square(
                    dimension: 120,
                    child: Image(
                      image: AssetImage(
                        'assets/branding/app_icon/pixel_harmony_home.png',
                      ),
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
