import 'package:accessibility_tools/src/testing_tools/color_mode_simulation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Color mode simulation is applied to a widget', (tester) async {
    await tester.pumpWidget(const _TestApp(null));
    await tester.pump();
    await expectLater(
      find.byType(_TestApp),
      matchesGoldenFile('goldens/color-mode-original.png'),
    );

    await tester.pumpWidget(const _TestApp(ColorModeSimulation.protanopia));
    await tester.pump();
    await expectLater(
      find.byType(_TestApp),
      matchesGoldenFile('goldens/color-mode-protanopia.png'),
    );

    await tester.pumpWidget(const _TestApp(ColorModeSimulation.deuteranopia));
    await tester.pump();
    await expectLater(
      find.byType(_TestApp),
      matchesGoldenFile('goldens/color-mode-deuteranopia.png'),
    );

    await tester.pumpWidget(const _TestApp(ColorModeSimulation.tritanopia));
    await tester.pump();
    await expectLater(
      find.byType(_TestApp),
      matchesGoldenFile('goldens/color-mode-tritanopia.png'),
    );

    await tester.pumpWidget(const _TestApp(ColorModeSimulation.inverted));
    await tester.pump();
    await expectLater(
      find.byType(_TestApp),
      matchesGoldenFile('goldens/color-mode-inverted.png'),
    );

    await tester.pumpWidget(const _TestApp(ColorModeSimulation.grayscale));
    await tester.pump();
    await expectLater(
      find.byType(_TestApp),
      matchesGoldenFile('goldens/color-mode-grayscale.png'),
    );
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp(this.simulation);

  final ColorModeSimulation? simulation;

  @override
  Widget build(BuildContext context) {
    final spectrum = Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
          colors: [
            Colors.red,
            Colors.orange,
            Colors.yellow,
            Colors.green,
            Colors.blue.shade50,
            Colors.blue.shade800,
            Colors.deepPurple,
            Colors.black,
          ],
        ),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: simulation != null
            ? ColorModeSimulator(simulation: simulation!, child: spectrum)
            : spectrum,
      ),
    );
  }
}
