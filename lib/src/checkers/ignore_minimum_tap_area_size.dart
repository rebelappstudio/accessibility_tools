import 'package:flutter/material.dart';

import 'minimum_tap_area_checker.dart';

/// A widget to ignore minimum tap area size warnings.
///
/// When added to the widget tree, warnings caused by [MinimumTapAreaChecker]
/// are ignored for all descendants of this widget.
///
/// In some cases this widget is needed, e.g. when a tappable element is coming
/// from a third party package and there's no easy way to fix the issue.
///
/// Use this widget carefully as it may easily make the app less accessible.
class IgnoreMinimumTapAreaSize extends InheritedWidget {
  /// Default constructor.
  const IgnoreMinimumTapAreaSize({super.key, required super.child});

  /// Returns the [IgnoreMinimumTapAreaSize] widget from the given [context] if
  /// it exists.
  static IgnoreMinimumTapAreaSize? maybeOf(BuildContext context) {
    return LookupBoundary.dependOnInheritedWidgetOfExactType<
      IgnoreMinimumTapAreaSize
    >(context);
  }

  /// Returns the [IgnoreMinimumTapAreaSize] widget from the given [context]
  /// assuming it exists.
  static IgnoreMinimumTapAreaSize of(BuildContext context) {
    final IgnoreMinimumTapAreaSize? result = context
        .dependOnInheritedWidgetOfExactType<IgnoreMinimumTapAreaSize>();
    assert(result != null, 'No IgnoreMinimumTapAreaSize found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(IgnoreMinimumTapAreaSize oldWidget) {
    return false;
  }
}
