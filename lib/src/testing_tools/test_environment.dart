import 'package:flutter/material.dart';

import 'color_mode_simulation.dart';

/// Currently set environment values
///
/// TODO support more settings:
/// MediaQuery.devicePixelRatio
/// MediaQuery.platformBrightness
/// MediaQuery.highContrast
/// MediaQuery.disableAnimations
/// MediaQuery.invertColors
@immutable
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

  @override
  bool operator ==(covariant TestEnvironment other) {
    if (identical(this, other)) return true;

    return other.textScaleFactor == textScaleFactor &&
        other.boldText == boldText &&
        other.targetPlatform == targetPlatform &&
        other.visualDensity == visualDensity &&
        other.localeOverride == localeOverride &&
        other.textDirection == textDirection &&
        other.semanticsDebuggerEnabled == semanticsDebuggerEnabled &&
        other.colorModeSimulation == colorModeSimulation;
  }

  @override
  int get hashCode {
    return textScaleFactor.hashCode ^
        boldText.hashCode ^
        targetPlatform.hashCode ^
        visualDensity.hashCode ^
        localeOverride.hashCode ^
        textDirection.hashCode ^
        semanticsDebuggerEnabled.hashCode ^
        colorModeSimulation.hashCode;
  }

  @override
  String toString() {
    return '''TestEnvironment(textScaleFactor: $textScaleFactor, boldText: $boldText, targetPlatform: $targetPlatform, visualDensity: $visualDensity, localeOverride: $localeOverride, textDirection: $textDirection, semanticsDebuggerEnabled: $semanticsDebuggerEnabled, colorModeSimulation: $colorModeSimulation)''';
  }
}
