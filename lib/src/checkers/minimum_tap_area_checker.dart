import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../accessibility_issue.dart';
import 'checker_base.dart';
import 'ignore_minimum_tap_area_size.dart';

/// Defines the minimum tap size per device type.
class MinimumTapAreas {
  const MinimumTapAreas({required this.mobile, required this.desktop});

  /// The minimum tap areas as defined by the Material Design guidelines:
  /// https://m3.material.io/foundations/accessible-design/accessibility-basics#28032e45-c598-450c-b355-f9fe737b1cd8
  ///
  /// 48 on mobile devices with touch screens, and 28 on desktop devices.
  static const MinimumTapAreas material = MinimumTapAreas(
    mobile: kMinInteractiveDimension,
    desktop: 28,
  );

  /// The minimum tap areas as defined by the Apple Human Interface Guidelines:
  /// https://developer.apple.com/design/human-interface-guidelines/foundations/accessibility/#buttons-and-controls
  ///
  /// 44 on mobile devices with touch screens, and 28 on desktop devices.
  static const MinimumTapAreas cupertino = MinimumTapAreas(
    mobile: kMinInteractiveDimensionCupertino,
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
    final window = _flutterViewForRenderObject(renderObject);

    if (window == null ||
        node.isMergedIntoParent ||
        !node.getSemanticsData().isTappable) {
      return null;
    }

    // skip this node if explicitly ignored by user
    final context = _contextForRenderObject(renderObject);
    if (context != null && IgnoreMinimumTapAreaSize.maybeOf(context) != null) {
      return null;
    }

    final nodePaintBounds = getPaintBounds(node);
    final renderObjectPaintBounds = renderObject.paintBounds;
    if (_isNodeOffScreen(window, renderObjectPaintBounds, nodePaintBounds)) {
      return null;
    }

    const delta = 0.001;
    final size = nodePaintBounds.size / window.devicePixelRatio;
    if (size.width < minTapArea - delta || size.height < minTapArea - delta) {
      return AccessibilityIssue(
        message:
            '''
Tap area of ${format(size.width)}x${format(size.height)} is too small:
should be at least ${format(minTapArea)}x${format(minTapArea)}''',
        resolutionGuidance:
            '''
Consider making the tap area bigger. For example, wrap the widget in a SizedBox:

InkWell(
  child: SizedBox.square(
    dimension: ${format(minTapArea)},
    child: child,
  ),
)

Icons have a size property:

Icon(
  Icons.wysiwyg,
  size: ${format(minTapArea)},
)''',
        renderObject: renderObject,
      );
    }

    return null;
  }

  FlutterView? _flutterViewForRenderObject(RenderObject renderObject) {
    final creator = renderObject.debugCreator;
    if (creator is DebugCreator) {
      return View.maybeOf(creator.element);
    }

    return null;
  }

  BuildContext? _contextForRenderObject(RenderObject renderObject) {
    final creator = renderObject.debugCreator;
    if (creator is DebugCreator) {
      return creator.element;
    } else {
      return null;
    }
  }

  @visibleForTesting
  static String format(double val) {
    // Round to N places after decimal point where N is 2
    final mod = pow(10, 2);
    final rounded = (val * mod).roundToDouble() / mod;
    return (rounded - rounded.toInt()) == 0
        ? rounded.toStringAsFixed(0)
        : rounded.toStringAsFixed(2);
  }

  /// Returns true if rectangle of a node is (partially) off screen
  bool _isNodeOffScreen(
    FlutterView flutterView,
    Rect renderObjectPaintBounds,
    Rect nodePaintBounds,
  ) {
    // Check if node's size and corresponding render object's size are different
    // This could mean that node is partially off screen
    final nodeSize = nodePaintBounds.size / flutterView.devicePixelRatio;
    final renderObjectSize = renderObjectPaintBounds.size;
    final widthDiff = (nodeSize.width - renderObjectSize.width).abs();
    final heightDiff = (nodeSize.height - renderObjectSize.height).abs();
    const offScreenDelta = 5.0;
    final isNodeOffScreen =
        widthDiff >= offScreenDelta || heightDiff >= offScreenDelta;
    if (isNodeOffScreen) {
      return true;
    }

    // Check if node's paint bounds are off screen
    const delta = 10.0;
    final windowPhysicalSize =
        flutterView.physicalSize * flutterView.devicePixelRatio;
    return nodePaintBounds.top < -delta ||
        nodePaintBounds.left < -delta ||
        nodePaintBounds.bottom > windowPhysicalSize.height + delta ||
        nodePaintBounds.right > windowPhysicalSize.width + delta;
  }
}
