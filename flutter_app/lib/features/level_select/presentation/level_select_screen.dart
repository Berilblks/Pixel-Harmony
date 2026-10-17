import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_harmony/app/router/app_router.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/core/localization/level_localizations.dart';
import 'package:pixel_harmony/core/theme/app_design_tokens.dart';
import 'package:pixel_harmony/features/level_progress/application/level_progress_providers.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';
import 'package:pixel_harmony/game/levels/level_progression.dart';

class LevelSelectScreen extends ConsumerStatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  ConsumerState<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends ConsumerState<LevelSelectScreen>
    with SingleTickerProviderStateMixin {
  static const _stopExtent = 124.0;
  static const _minimumVisibleLevels = 100;
  static const _futureBuffer = 40;

  late final ScrollController _scrollController;
  late final AnimationController _focusController;
  int? _positionedAtLevel;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _focusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final progress = ref.watch(levelProgressControllerProvider);
    final completedLevelIds = progress.asData?.value ?? const <String>{};
    final currentLevel = _firstIncompleteLevel(completedLevelIds);
    final itemCount = math.max(
      _minimumVisibleLevels,
      currentLevel + _futureBuffer,
    );
    _positionNearCurrentLevel(currentLevel);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      body: Stack(
        children: [
          const Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                key: Key('journeySelectBackground'),
                painter: _LevelSelectBackgroundPainter(),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _LevelSelectHeader(
                  title: localizations.chooseLevel,
                  onBack: () => context.pop(),
                ),
                if (progress.isLoading)
                  const LinearProgressIndicator(minHeight: 2),
                if (progress.hasError)
                  Padding(
                    key: const Key('levelProgressError'),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      0,
                    ),
                    child: Text(
                      localizations.progressLoadError,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return ListView.builder(
                        key: const Key('levelSelectGrid'),
                        controller: _scrollController,
                        padding: const EdgeInsets.only(
                          top: AppSpacing.sm,
                          bottom: AppSpacing.xxl,
                        ),
                        itemExtent: _stopExtent,
                        itemCount: itemCount,
                        itemBuilder: (context, index) {
                          final number = index + 1;
                          final level = LevelCatalog.byNumber(number);
                          final completed = completedLevelIds.contains(
                            level.id,
                          );
                          const progression = LevelProgression.journey();
                          final unlocked = progression.isUnlocked(
                            level.id,
                            completedLevelIds,
                          );
                          final current = number == currentLevel && unlocked;

                          return _JourneyStopRow(
                            level: level,
                            number: number,
                            availableWidth: constraints.maxWidth,
                            completed: completed,
                            unlocked: unlocked,
                            current: current,
                            currentLevel: currentLevel,
                            focusAnimation: _focusController,
                            label: localizedLevelName(localizations, level),
                            completedLabel: localizations.completedLabel,
                            lockedLabel: localizations.lockedLabel,
                            pixelPictureLabel: localizations.pixelPictureLabel,
                            onTap:
                                unlocked
                                    ? () => context.pushNamed(
                                      AppRoutes.gameplay,
                                      pathParameters: {'levelId': level.id},
                                    )
                                    : null,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _firstIncompleteLevel(Set<String> completedLevelIds) {
    var number = 1;
    while (completedLevelIds.contains(_levelId(number))) {
      number++;
    }
    return number;
  }

  void _positionNearCurrentLevel(int currentLevel) {
    if (_positionedAtLevel == currentLevel) return;
    _positionedAtLevel = currentLevel;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final viewport = _scrollController.position.viewportDimension;
      final target = ((currentLevel - 1) * _stopExtent - viewport * 0.42).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      if (_scrollController.offset == target) return;
      if ((_scrollController.offset - target).abs() > _stopExtent * 3) {
        _scrollController.jumpTo(target);
      } else {
        _scrollController.animateTo(
          target,
          duration: AppMotion.gentle,
          curve: Curves.easeInOut,
        );
      }
    });
  }
}

class _LevelSelectHeader extends StatelessWidget {
  const _LevelSelectHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 64,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: MaterialLocalizations.of(context).backButtonTooltip,
            child: Material(
              color: Colors.white.withValues(alpha: 0.76),
              shape: const CircleBorder(),
              child: InkWell(
                key: const Key('levelSelectBackButton'),
                onTap: onBack,
                customBorder: const CircleBorder(),
                child: const SizedBox.square(
                  dimension: 44,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 19,
                    color: Color(0xFF5D556A),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF40394F),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    ),
  );
}

class _JourneyStopRow extends StatelessWidget {
  const _JourneyStopRow({
    required this.level,
    required this.number,
    required this.availableWidth,
    required this.completed,
    required this.unlocked,
    required this.current,
    required this.currentLevel,
    required this.focusAnimation,
    required this.label,
    required this.completedLabel,
    required this.lockedLabel,
    required this.pixelPictureLabel,
    required this.onTap,
  });

  final LevelDefinition level;
  final int number;
  final double availableWidth;
  final bool completed;
  final bool unlocked;
  final bool current;
  final int currentLevel;
  final Animation<double> focusAnimation;
  final String label;
  final String completedLabel;
  final String lockedLabel;
  final String pixelPictureLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final milestone = _isMilestone(number);
    final nodeSize = current ? 80.0 : 72.0;
    final fraction = _pathFraction(number);
    final horizontalCenter = availableWidth * fraction;
    final left =
        (horizontalCenter - nodeSize / 2)
            .clamp(
              AppSpacing.md,
              math.max(
                AppSpacing.md,
                availableWidth - nodeSize - AppSpacing.md,
              ),
            )
            .toDouble();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    Widget node = _JourneyNode(
      level: level,
      number: number,
      size: nodeSize,
      completed: completed,
      unlocked: unlocked,
      current: current,
      milestone: milestone,
      label: label,
      completedLabel: completedLabel,
      lockedLabel: lockedLabel,
      pixelPictureLabel: pixelPictureLabel,
      onTap: onTap,
    );
    if (current && !reduceMotion) {
      node = AnimatedBuilder(
        animation: focusAnimation,
        builder:
            (context, child) => Transform.scale(
              scale: 1 + focusAnimation.value * 0.035,
              child: child,
            ),
        child: node,
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(
            key: Key('journeyPathSegment_$number'),
            painter: _JourneyPathPainter(
              number: number,
              currentLevel: currentLevel,
              previousFraction: _pathFraction(math.max(1, number - 1)),
              currentFraction: fraction,
              nextFraction: _pathFraction(number + 1),
            ),
          ),
        ),
        Positioned(left: left, top: (124 - nodeSize) / 2, child: node),
      ],
    );
  }
}

class _JourneyNode extends StatelessWidget {
  const _JourneyNode({
    required this.level,
    required this.number,
    required this.size,
    required this.completed,
    required this.unlocked,
    required this.current,
    required this.milestone,
    required this.label,
    required this.completedLabel,
    required this.lockedLabel,
    required this.pixelPictureLabel,
    required this.onTap,
  });

  final LevelDefinition level;
  final int number;
  final double size;
  final bool completed;
  final bool unlocked;
  final bool current;
  final bool milestone;
  final String label;
  final String completedLabel;
  final String lockedLabel;
  final String pixelPictureLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final semanticLabel = [
      label,
      if (completed) completedLabel,
      if (!unlocked) lockedLabel,
      if (level.puzzleType == JourneyPuzzleType.pixelPicture) pixelPictureLabel,
    ].join(', ');
    final accent = _journeyAccent(number);
    final nextAccent = _journeyAccent(number + 1);
    final foreground =
        completed
            ? (accent.computeLuminance() > 0.48
                ? const Color(0xFF40394F)
                : Colors.white)
            : current
            ? Colors.white
            : unlocked
            ? AppPalette.ink
            : AppPalette.mutedInk;
    final border =
        current
            ? Colors.white.withValues(alpha: 0.92)
            : milestone
            ? accent.withValues(alpha: 0.72)
            : unlocked
            ? Colors.white.withValues(alpha: 0.7)
            : const Color(0x55FFFFFF);
    final nodeGradient =
        completed
            ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_lighten(accent, 0.2), accent, nextAccent],
            )
            : current
            ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF8CE7CF), Color(0xFF3ABFA8)],
            )
            : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _lighten(accent, unlocked ? 0.72 : 0.84),
                _lighten(nextAccent, unlocked ? 0.62 : 0.8),
              ],
            );

    return Semantics(
      key: Key('levelCard_${level.id}'),
      container: true,
      button: true,
      enabled: unlocked,
      label: semanticLabel,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (current)
            Container(
              key: Key('currentLevel_${level.id}'),
              width: size + 14,
              height: size + 14,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(27),
                border: Border.all(
                  color: const Color(0xFF53C9B4).withValues(alpha: 0.48),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF53C9B4).withValues(alpha: 0.24),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          if (milestone)
            Container(
              key: Key('milestoneLevel_${level.id}'),
              width: size + 10,
              height: size + 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: accent.withValues(alpha: unlocked ? 0.4 : 0.18),
                  width: 2,
                ),
              ),
            ),
          Material(
            color: Colors.transparent,
            elevation: current ? 6 : (unlocked ? 2 : 0),
            shadowColor: accent.withValues(alpha: 0.35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            clipBehavior: Clip.antiAlias,
            child: Ink(
              key:
                  level.puzzleType == JourneyPuzzleType.gradient
                      ? Key('gradientNode_${level.id}')
                      : null,
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: nodeGradient,
                border: Border.all(color: border, width: current ? 3 : 2),
              ),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 6,
                      left: 9,
                      right: 9,
                      height: 10,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.58),
                              Colors.white.withValues(alpha: 0.05),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '$number',
                          maxLines: 1,
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            color: foreground,
                            fontSize: number >= 1000 ? 16.0 : null,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (completed)
            Positioned(
              key: Key('levelCompleted_${level.id}'),
              right: -2,
              bottom: -2,
              child: _NodeBadge(
                icon: Icons.check_rounded,
                color: AppPalette.surface,
                foreground: accent,
              ),
            )
          else if (!unlocked)
            Positioned(
              key: Key('levelLocked_${level.id}'),
              right: -2,
              bottom: -2,
              child: const _NodeBadge(
                icon: Icons.lock_outline_rounded,
                color: AppPalette.surfaceLocked,
                foreground: AppPalette.mutedInk,
              ),
            ),
          if (level.puzzleType == JourneyPuzzleType.pixelPicture)
            Positioned(
              key: Key('pixelPictureBadge_${level.id}'),
              left: -5,
              bottom: -3,
              child: _NodeBadge(
                icon: Icons.palette_outlined,
                color: unlocked ? AppPalette.surface : AppPalette.surfaceLocked,
                foreground: unlocked ? accent : AppPalette.mutedInk,
              ),
            ),
        ],
      ),
    );
  }
}

class _NodeBadge extends StatelessWidget {
  const _NodeBadge({
    required this.icon,
    required this.color,
    required this.foreground,
  });

  final IconData icon;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: AppPalette.border),
      ),
      child: Icon(icon, size: 15, color: foreground),
    );
  }
}

class _JourneyPathPainter extends CustomPainter {
  const _JourneyPathPainter({
    required this.number,
    required this.currentLevel,
    required this.previousFraction,
    required this.currentFraction,
    required this.nextFraction,
  });

  final int number;
  final int currentLevel;
  final double previousFraction;
  final double currentFraction;
  final double nextFraction;

  @override
  void paint(Canvas canvas, Size size) {
    final top = Offset(
      size.width * (previousFraction + currentFraction) / 2,
      0,
    );
    final center = Offset(size.width * currentFraction, size.height / 2);
    final bottom = Offset(
      size.width * (currentFraction + nextFraction) / 2,
      size.height,
    );
    final incoming =
        Path()
          ..moveTo(top.dx, top.dy)
          ..quadraticBezierTo(center.dx, center.dy - 20, center.dx, center.dy);
    final outgoing =
        Path()
          ..moveTo(center.dx, center.dy)
          ..quadraticBezierTo(center.dx, center.dy + 20, bottom.dx, bottom.dy);
    final futurePaint =
        Paint()
          ..color = _journeyAccent(number).withValues(alpha: 0.16)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.5
          ..strokeCap = StrokeCap.round;
    final glowPaint =
        Paint()
          ..color = _journeyAccent(number).withValues(alpha: 0.13)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 13
          ..strokeCap = StrokeCap.round;
    final travelledPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [_journeyAccent(number - 1), _journeyAccent(number + 1)],
          ).createShader(Offset.zero & size)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6.5
          ..strokeCap = StrokeCap.round;

    canvas.drawPath(incoming, futurePaint);
    canvas.drawPath(outgoing, futurePaint);
    if (number <= currentLevel) {
      canvas.drawPath(incoming, glowPaint);
      canvas.drawPath(incoming, travelledPaint);
    }
    if (number < currentLevel) {
      canvas.drawPath(outgoing, glowPaint);
      canvas.drawPath(outgoing, travelledPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _JourneyPathPainter oldDelegate) {
    return oldDelegate.number != number ||
        oldDelegate.currentLevel != currentLevel ||
        oldDelegate.previousFraction != previousFraction ||
        oldDelegate.currentFraction != currentFraction ||
        oldDelegate.nextFraction != nextFraction;
  }
}

class _LevelSelectBackgroundPainter extends CustomPainter {
  const _LevelSelectBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final base =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [
              Color(0xFFFFFCF7),
              Color(0xFFFAF6FC),
              Color(0xFFF6FAF8),
            ],
          ).createShader(bounds);
    canvas.drawRect(bounds, base);

    void paintGlow(Alignment alignment, Color color, double radius) {
      final center = alignment.alongSize(size);
      final glow =
          Paint()
            ..shader = RadialGradient(
              colors: [color.withValues(alpha: 0.15), Colors.transparent],
            ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, glow);
    }

    paintGlow(const Alignment(-1.15, -0.62), const Color(0xFFB9A9EF), 210);
    paintGlow(const Alignment(1.12, -0.05), const Color(0xFFF2A9C9), 230);
    paintGlow(const Alignment(-1.08, 0.58), const Color(0xFF99CFF2), 220);
    paintGlow(const Alignment(1.1, 0.9), const Color(0xFFA9DEC9), 230);
  }

  @override
  bool shouldRepaint(covariant _LevelSelectBackgroundPainter oldDelegate) =>
      false;
}

double _pathFraction(int number) {
  final primary = math.sin(number * 0.73 - 0.9) * 0.27;
  final organic = math.sin(number * 0.19 + 1.4) * 0.075;
  return (0.5 + primary + organic).clamp(0.18, 0.82);
}

bool _isMilestone(int number) =>
    const {10, 25, 50, 100, 250, 500, 1000}.contains(number);

Color _journeyAccent(int number) {
  const accents = [
    Color(0xFFE95A9E),
    Color(0xFFF2B83F),
    Color(0xFF3E91E8),
    Color(0xFF8B61D5),
    Color(0xFF46BFA1),
  ];
  return accents[(number.abs() - 1) % accents.length];
}

Color _lighten(Color color, double amount) =>
    Color.lerp(color, Colors.white, amount)!;

String _levelId(int number) => 'level_${number.toString().padLeft(3, '0')}';
