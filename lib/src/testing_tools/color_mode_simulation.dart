import 'package:flutter/material.dart';

/// Various color modes that can be simulated to check if the app is accessible
/// in certain color modes.
///
/// Protanopia, deuteranopia, and tritanopia matrices are inspired by:
/// Gustavo M. Machado, Manuel M. Oliveira, and Leandro A. F. Fernandes
/// "A Physiologically-based Model for Simulation of Color Vision Deficiency".
/// IEEE Transactions on Visualization and Computer Graphics.
/// Volume 15 (2009), Number 6, November/December 2009. pp. 1291-1298.
///
/// https://www.inf.ufrgs.br/~oliveira/pubs_files/CVD_Simulation/CVD_Simulation.html
///
enum ColorModeSimulation {
  /// Protanopia color mode simulation.
  protanopia([
    //
    0.152286, 1.052583, -0.204868, 0, 0,
    0.114503, 0.786281, 0.099216, 0, 0,
    -0.003882, -0.048116, 1.051998, 0, 0,
    0, 0, 0, 1, 0,
  ]),

  /// Deuteranopia color mode simulation.
  deuteranopia([
    //
    0.367322, 0.860646, -0.227968, 0, 0,
    0.280085, 0.672501, 0.047413, 0, 0,
    -0.011820, 0.042940, 0.968881, 0, 0,
    0, 0, 0, 1, 0,
  ]),

  /// Tritanopia color mode simulation.
  tritanopia([
    //
    1.255528, -0.076749, -0.178779, 0, 0,
    -0.078411, 0.930809, 0.147602, 0, 0,
    0.004733, 0.691367, 0.303900, 0, 0,
    0, 0, 0, 1, 0,
  ]),

  /// Inverted color mode simulation.
  inverted([
    //
    -1, 0, 0, 0, 255,
    0, -1, 0, 0, 255,
    0, 0, -1, 0, 255,
    0, 0, 0, 1, 0,
  ]),

  /// Grayscale color mode simulation.
  grayscale([
    //
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  const ColorModeSimulation(this.matrix);

  /// Color mode's matrix to use with [ColorFilter].
  final List<double> matrix;
}

/// Widget that uses color filters to simulate various color modes
class ColorModeSimulator extends StatelessWidget {
  /// Default constructor.
  const ColorModeSimulator({
    super.key,
    required this.simulation,
    required this.child,
  });

  /// The color mode simulation to use.
  final ColorModeSimulation simulation;

  /// The child widget to simulate the color mode for.
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
