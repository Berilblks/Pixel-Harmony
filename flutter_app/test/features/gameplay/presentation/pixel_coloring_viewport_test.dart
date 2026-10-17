import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/features/gameplay/presentation/pixel_coloring_viewport.dart';

void main() {
  testWidgets('starts at 1x and reveals reset only after transformation', (
    tester,
  ) async {
    final controller = TransformationController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_app(controller: controller));

    expect(controller.value.getMaxScaleOnAxis(), 1);
    expect(_resetOpacity(tester), 0);

    await _pinch(tester, outward: true);

    expect(controller.value.getMaxScaleOnAxis(), greaterThan(1));
    expect(controller.value.getMaxScaleOnAxis(), lessThanOrEqualTo(4));
    expect(_resetOpacity(tester), 1);

    await tester.tap(find.byKey(const Key('pixelColoringZoomResetButton')));
    await tester.pump();
    expect(controller.value.getMaxScaleOnAxis(), closeTo(1, 0.0001));
    expect(_resetOpacity(tester), 0);
  });

  testWidgets(
    'pinch zoom clamps to 4x and two-finger pan changes translation',
    (tester) async {
      final controller = TransformationController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(_app(controller: controller));

      for (var index = 0; index < 3; index++) {
        await _pinch(tester, outward: true);
      }
      expect(controller.value.getMaxScaleOnAxis(), closeTo(4, 0.01));

      final before = controller.value.getTranslation();
      await _twoFingerPan(tester, const Offset(24, 18));
      final after = controller.value.getTranslation();
      expect(after.x != before.x || after.y != before.y, isTrue);

      final zoomedScale = controller.value.getMaxScaleOnAxis();
      await _pinch(tester, outward: false);
      expect(controller.value.getMaxScaleOnAxis(), lessThan(zoomedScale));
      expect(controller.value.getMaxScaleOnAxis(), greaterThanOrEqualTo(1));
    },
  );

  testWidgets('multi-touch is reported and a new viewport starts reset', (
    tester,
  ) async {
    final states = <bool>[];
    await tester.pumpWidget(_app(onMultiTouchChanged: states.add));
    await _pinch(tester, outward: true);
    expect(states, containsAllInOrder([true, false]));

    await tester.pumpWidget(
      _app(key: const ValueKey('nextPuzzle'), onMultiTouchChanged: states.add),
    );
    final state = tester.state<PixelColoringViewportState>(
      find.byType(PixelColoringViewport),
    );
    expect(state.transformationController.value.getMaxScaleOnAxis(), 1);
  });
}

Widget _app({
  Key? key,
  TransformationController? controller,
  ValueChanged<bool>? onMultiTouchChanged,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox.expand(
        child: PixelColoringViewport(
          key: key,
          controller: controller,
          resetTooltip: 'Reset zoom',
          onMultiTouchChanged: onMultiTouchChanged,
          child: const ColoredBox(key: Key('pixelCanvas'), color: Colors.blue),
        ),
      ),
    ),
  );
}

double _resetOpacity(WidgetTester tester) =>
    tester
        .widget<AnimatedOpacity>(
          find.ancestor(
            of: find.byKey(const Key('pixelColoringZoomResetButton')),
            matching: find.byType(AnimatedOpacity),
          ),
        )
        .opacity;

Future<void> _pinch(WidgetTester tester, {required bool outward}) async {
  final center = tester.getCenter(
    find.byKey(const Key('pixelColoringInteractiveViewer')),
  );
  final first = await tester.createGesture(pointer: 1);
  final second = await tester.createGesture(pointer: 2);
  await first.down(center - const Offset(30, 0));
  await second.down(center + const Offset(30, 0));
  final distance = outward ? 120.0 : 12.0;
  await first.moveTo(center - Offset(distance, 0));
  await second.moveTo(center + Offset(distance, 0));
  await tester.pump();
  await first.up();
  await second.up();
  await tester.pump();
}

Future<void> _twoFingerPan(WidgetTester tester, Offset delta) async {
  final center = tester.getCenter(
    find.byKey(const Key('pixelColoringInteractiveViewer')),
  );
  final first = await tester.createGesture(pointer: 3);
  final second = await tester.createGesture(pointer: 4);
  await first.down(center - const Offset(30, 0));
  await second.down(center + const Offset(30, 0));
  await first.moveBy(delta);
  await second.moveBy(delta);
  await tester.pump();
  await first.up();
  await second.up();
  await tester.pump();
}
