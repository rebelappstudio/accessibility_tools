import 'package:flutter/material.dart';

/// When added to the widget tree, warnings caused by <code>MinimumTapAreaSizeChecker</code>
/// are ignored for all descendants of this widget.
class IgnoreMinimumTapAreaSize extends InheritedWidget {
  const IgnoreMinimumTapAreaSize({
    super.key,
    required super.child,
  });

  static IgnoreMinimumTapAreaSize? maybeOf(BuildContext context) {
    return LookupBoundary.dependOnInheritedWidgetOfExactType<
        IgnoreMinimumTapAreaSize>(context);
  }

  static IgnoreMinimumTapAreaSize of(BuildContext context) {
    final IgnoreMinimumTapAreaSize? result =
        context.dependOnInheritedWidgetOfExactType<IgnoreMinimumTapAreaSize>();
    assert(result != null, 'No IgnoreMinimumTapAreaSize found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(IgnoreMinimumTapAreaSize oldWidget) {
    return false;
  }
}
