import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import '../accessibility_issue.dart';
import 'checker_base.dart';

/// Defines the minimum tap size per device type.
class MinimumTapAreas {
  const MinimumTapAreas({
    required this.mobile,
    required this.desktop,
  });

  /// The minimum tap areas as defined by the Material Design guidelines:
  /// https://m3.material.io/foundations/accessible-design/accessibility-basics#28032e45-c598-450c-b355-f9fe737b1cd8
  ///
  /// 48 on mobile devices with touch screens, and 28 on desktop devices.
  static const MinimumTapAreas material = MinimumTapAreas(
    mobile: 48,
    desktop: 28,
  );

  /// The minimum tap areas as defined by the Apple Human Interface Guidelines:
  /// https://developer.apple.com/design/human-interface-guidelines/foundations/accessibility/#buttons-and-controls
  ///
  /// 44 on mobile devices with touch screens, and 28 on desktop devices.
  static const MinimumTapAreas cupertino = MinimumTapAreas(
    mobile: 44,
    desktop: 28,
  );

  /// The minimum tap area for mobile devices with touch screens, used on
  /// Android, iOS and Fuchsia.
  final double mobile;

  /// The minimum tap area for desktop devices where users most often use a
  /// mouse. Used on Linux, macOS and Windows.
  final double desktop;

  /// Returns the minimum tap area for the given [platform].
  double forPlatform(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return mobile;
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return desktop;
    }
  }
}

/// Modified from package:flutter_test/lib/src/accessibility.dart
class MinimumTapAreaChecker extends SemanticsNodeChecker {
  MinimumTapAreaChecker({required this.minTapArea});

  final double minTapArea;

  @override
  AccessibilityIssue? checkNode(SemanticsNode node, RenderObject renderObject) {
    if (node.isMergedIntoParent || !node.getSemanticsData().isTappable) {
      return null;
    }

    final paintBounds = getPaintBounds(node);
    final devicePixelRatio = WidgetsBinding.instance.window.devicePixelRatio;
    final size = paintBounds.size / devicePixelRatio;
    final element = renderObject.getCreatorElement();

    if (element?.size != null && element?.size != size) {
      // Item size doesn't match tap area height - it's probably partially off
      // screen
      return null;
    }

    const delta = 0.001;
    if (size.width < minTapArea - delta || size.height < minTapArea - delta) {
      return AccessibilityIssue(
        message: '''
Tap area of ${format(size.width)}x${format(size.height)} is too small:
should be at least ${format(minTapArea)}x${format(minTapArea)}''',
        renderObject: renderObject,
      );
    }

    return null;
  }

  @visibleForTesting
  static String format(double val) => NumberFormat('#.##').format(val);
}
