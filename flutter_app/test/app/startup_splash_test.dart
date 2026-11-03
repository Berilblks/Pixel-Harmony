import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/app/startup_splash.dart';

void main() {
  testWidgets('cold-start splash holds, fades, and never replaces app state', (
    tester,
  ) async {
    var childBuilds = 0;
    await tester.pumpWidget(
      StartupSplash(
        child: Builder(
          builder: (context) {
            childBuilds++;
            return const ColoredBox(
              key: Key('readyApplication'),
              color: Colors.white,
            );
          },
        ),
      ),
    );

    expect(find.byKey(const Key('startupSplash')), findsOneWidget);
    expect(find.byKey(const Key('readyApplication')), findsOneWidget);
    expect(childBuilds, 1);

    await tester.pump(const Duration(milliseconds: 1399));
    expect(find.byKey(const Key('startupSplash')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.byKey(const Key('startupSplash')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.byKey(const Key('startupSplash')), findsNothing);
    expect(find.byKey(const Key('readyApplication')), findsOneWidget);
  });
}
