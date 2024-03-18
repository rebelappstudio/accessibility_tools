import 'package:flutter/material.dart';

import 'color_mode_simulation.dart';

/// Currently set environment values
///
/// TODO: more settings including the following:
/// MediaQuery.devicePixelRatio
/// MediaQuery.platformBrightness
/// MediaQuery.highContrast
/// MediaQuery.disableAnimations
/// MediaQuery.invertColors
class TestEnvironment {
  const TestEnvironment({
    this.textScaleFactor,
    this.boldText,
    this.targetPlatform,
    this.visualDensity,
    this.localeOverride,
    this.textDirection,
    this.semanticsDebuggerEnabled,
    this.colorModeSimulation,
  });

  final double? textScaleFactor;
  final bool? boldText;
  final TargetPlatform? targetPlatform;
  final VisualDensity? visualDensity;
  final Locale? localeOverride;
  final TextDirection? textDirection;
  final bool? semanticsDebuggerEnabled;
  final ColorModeSimulation? colorModeSimulation;
}
