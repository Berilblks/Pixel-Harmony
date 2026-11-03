import 'package:flutter/material.dart';
import 'package:pixel_harmony/core/theme/app_design_tokens.dart';

class PixelColoringViewport extends StatefulWidget {
  const PixelColoringViewport({
    super.key,
    required this.child,
    required this.resetTooltip,
    this.controller,
    this.onMultiTouchChanged,
    this.maxScale = 4.0,
    this.completed = false,
    this.reduceMotion = false,
  });

  final Widget child;
  final String resetTooltip;
  final TransformationController? controller;
  final ValueChanged<bool>? onMultiTouchChanged;
  final double maxScale;
  final bool completed;
  final bool reduceMotion;

  @override
  State<PixelColoringViewport> createState() => PixelColoringViewportState();
}

class PixelColoringViewportState extends State<PixelColoringViewport>
    with SingleTickerProviderStateMixin {
  late TransformationController _controller;
  late bool _ownsController;
  bool _isTransformed = false;
  int _activePointerCount = 0;
  late final AnimationController _resetAnimationController;
  Animation<Matrix4>? _resetAnimation;

  static const minScale = 1.0;

  TransformationController get transformationController => _controller;
  bool get isTransformed => _isTransformed;

  @override
  void initState() {
    super.initState();
    _resetAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..addListener(_applyResetAnimation);
    _useController(widget.controller);
  }

  @override
  void didUpdateWidget(PixelColoringViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.completed && !oldWidget.completed) {
      animateToFit();
    }
    if (oldWidget.controller == widget.controller) return;
    _resetAnimationController.stop();
    _controller.removeListener(_handleTransformationChanged);
    if (_ownsController) _controller.dispose();
    _useController(widget.controller);
  }

  void _useController(TransformationController? controller) {
    _ownsController = controller == null;
    _controller = controller ?? TransformationController();
    _controller.addListener(_handleTransformationChanged);
    _isTransformed = !_isIdentity(_controller.value);
  }

  void _handleTransformationChanged() {
    final transformed = !_isIdentity(_controller.value);
    if (transformed != _isTransformed && mounted) {
      setState(() => _isTransformed = transformed);
    }
  }

  void reset() {
    _resetAnimationController.stop();
    _controller.value = Matrix4.identity();
  }

  void animateToFit() {
    if (widget.reduceMotion || _isIdentity(_controller.value)) {
      reset();
      return;
    }
    _resetAnimation = Matrix4Tween(
      begin: Matrix4.copy(_controller.value),
      end: Matrix4.identity(),
    ).animate(
      CurvedAnimation(
        parent: _resetAnimationController,
        curve: Curves.easeInOutCubic,
      ),
    );
    _resetAnimationController.forward(from: 0);
  }

  void _applyResetAnimation() {
    final animation = _resetAnimation;
    if (animation != null) _controller.value = animation.value;
  }

  void _pointerDown(PointerDownEvent event) {
    _activePointerCount++;
    if (_activePointerCount == 2) widget.onMultiTouchChanged?.call(true);
  }

  void _pointerEnded(PointerEvent event) {
    if (_activePointerCount == 0) return;
    _activePointerCount--;
    if (_activePointerCount == 1) widget.onMultiTouchChanged?.call(false);
  }

  @override
  void dispose() {
    _resetAnimationController.dispose();
    _controller.removeListener(_handleTransformationChanged);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          top: 40,
          child: Listener(
            onPointerDown: _pointerDown,
            onPointerUp: _pointerEnded,
            onPointerCancel: _pointerEnded,
            child: ClipRect(
              child: InteractiveViewer(
                key: const Key('pixelColoringInteractiveViewer'),
                transformationController: _controller,
                minScale: minScale,
                maxScale: widget.maxScale,
                panEnabled: !widget.completed,
                scaleEnabled: !widget.completed,
                clipBehavior: Clip.hardEdge,
                boundaryMargin: EdgeInsets.zero,
                child: widget.child,
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: AppSpacing.sm,
          child: AnimatedOpacity(
            opacity: _isTransformed && !widget.completed ? 1 : 0,
            duration: AppMotion.quick,
            child: IgnorePointer(
              ignoring: !_isTransformed || widget.completed,
              child: Semantics(
                button: true,
                label: widget.resetTooltip,
                child: IconButton.filledTonal(
                  key: const Key('pixelColoringZoomResetButton'),
                  tooltip: widget.resetTooltip,
                  onPressed: reset,
                  icon: const Icon(Icons.center_focus_strong_rounded, size: 20),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _isIdentity(Matrix4 matrix) {
    final identity = Matrix4.identity().storage;
    final values = matrix.storage;
    for (var index = 0; index < values.length; index++) {
      if ((values[index] - identity[index]).abs() > 0.0001) return false;
    }
    return true;
  }
}
