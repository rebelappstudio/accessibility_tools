import 'package:flutter/material.dart';

enum ColorModeSimulation {
  protanopia([
    //
    0.152286, 1.052583, -0.204868, 0, 0,
    0.114503, 0.786281, 0.099216, 0, 0,
    -0.003882, -0.048116, 1.051998, 0, 0,
    0, 0, 0, 1, 0,
  ]),

  deuteranopia([
    //
    0.367322, 0.860646, -0.227968, 0, 0,
    0.280085, 0.672501, 0.047413, 0, 0,
    -0.011820, 0.042940, 0.968881, 0, 0,
    0, 0, 0, 1, 0,
  ]),

  tritanopia([
    //
    1.255528, -0.076749, -0.178779, 0, 0,
    -0.078411, 0.930809, 0.147602, 0, 0,
    0.004733, 0.691367, 0.303900, 0, 0,
    0, 0, 0, 1, 0,
  ]),

  inverted([
    //
    -1, 0, 0, 0, 255,
    0, -1, 0, 0, 255,
    0, 0, -1, 0, 255,
    0, 0, 0, 1, 0,
  ]),

  greyscale([
    //
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  const ColorModeSimulation(this.matrix);

  final List<double> matrix;
}

/// Widget that uses color filters to simulate various color modes
class ColorModeSimulator extends StatelessWidget {
  const ColorModeSimulator({
    super.key,
    required this.simulation,
    required this.child,
  });

  final ColorModeSimulation simulation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: const ColorFilter.linearToSrgbGamma(),
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix(simulation.matrix),
        child: ColorFiltered(
          colorFilter: const ColorFilter.srgbToLinearGamma(),
          child: child,
        ),
      ),
    );
  }
}
