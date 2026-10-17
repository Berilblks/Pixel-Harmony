import 'package:flutter/material.dart';
import 'package:pixel_harmony/core/theme/app_design_tokens.dart';

class PixelColoringViewport extends StatefulWidget {
  const PixelColoringViewport({
    super.key,
    required this.child,
    required this.resetTooltip,
    this.controller,
    this.onMultiTouchChanged,
  });

  final Widget child;
  final String resetTooltip;
  final TransformationController? controller;
  final ValueChanged<bool>? onMultiTouchChanged;

  @override
  State<PixelColoringViewport> createState() => PixelColoringViewportState();
}

class PixelColoringViewportState extends State<PixelColoringViewport> {
  late TransformationController _controller;
  late bool _ownsController;
  bool _isTransformed = false;
  int _activePointerCount = 0;

  static const minScale = 1.0;
  static const maxScale = 4.0;

  TransformationController get transformationController => _controller;
  bool get isTransformed => _isTransformed;

  @override
  void initState() {
    super.initState();
    _useController(widget.controller);
  }

  @override
  void didUpdateWidget(PixelColoringViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
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

  void reset() => _controller.value = Matrix4.identity();

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
                maxScale: maxScale,
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
            opacity: _isTransformed ? 1 : 0,
            duration: AppMotion.quick,
            child: IgnorePointer(
              ignoring: !_isTransformed,
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
