import 'package:flutter/foundation.dart';

/// Configuration for the testing tools panel
@immutable
class TestingToolsConfiguration {
  const TestingToolsConfiguration({
    this.enabled = true,
    this.minTextScale = 0.1,
    this.maxTextScale = 10.0,
  })  : assert(
          minTextScale > 0 && minTextScale <= 1.0,
          'minTextScale must be greater than 0 and less than or equal to 1',
        ),
        assert(
          minTextScale < maxTextScale,
          'minTextScale must be less than maxTextScale',
        ),
        assert(
          maxTextScale > 0 && maxTextScale <= 100,
          'maxTextScale must be greater than 0 and less than or equal to 100',
        );

  /// Indicates whether the testing tools are enabled and can be used
  final bool enabled;

  /// The minimum allowed text scale factor
  final double minTextScale;

  /// The maximum allowed text scale factor
  final double maxTextScale;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TestingToolsConfiguration &&
        other.enabled == enabled &&
        other.minTextScale == minTextScale &&
        other.maxTextScale == maxTextScale;
  }

  @override
  int get hashCode =>
      enabled.hashCode ^ minTextScale.hashCode ^ maxTextScale.hashCode;
}
