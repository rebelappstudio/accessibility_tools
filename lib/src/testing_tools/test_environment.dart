import 'package:flutter/material.dart';

import 'color_mode_simulation.dart';

/// Represents a test environment that can be applied to a widget for testing
/// purposes.
@immutable
class TestEnvironment {
  /// Default constructor.
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

  /// Text scale factor to simulate different text sizes similar to
  /// OS's font accessibility settings.
  final double? textScaleFactor;

  /// Whether bold text accessibility flag is enabled.
  final bool? boldText;

  /// Target platform to simulate how Flutter widgets behave on different
  /// platforms.
  ///
  /// Used to simulate a target platform. This may not result in drastic
  /// changes in the UI, but it may affect the behavior of some widgets:
  /// * scrollable behavior
  /// * toolbar back icon (chevron on iOS, arrow on Android)
  final TargetPlatform? targetPlatform;

  /// Visual density to simulate different visual densities.
  final VisualDensity? visualDensity;

  /// Locale override to change the app's locale.
  final Locale? localeOverride;

  /// Text direction to change the app's text direction.
  ///
  /// Use to simulate different text directions (left-to-right, right-to-left).
  /// This setting may change things even if the app doesn't support various
  /// text directions.
  final TextDirection? textDirection;

  /// Whether semantics debugger is enabled for the test environment.
  ///
  /// Set to true to enable [SemanticsDebugger] for checking how semantics
  /// are present to the OS's accessibility services.
  final bool? semanticsDebuggerEnabled;

  /// Color mode simulation to simulate different color modes.
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
