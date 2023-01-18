import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../accessibility_issue.dart';
import 'checker_base.dart';

/// If deviation from target contrast is this big or less, it's considered to be
/// the same
const double _contrastTolerance = -0.01;

/// Defined in flutter_test/src/accessibility.dart
///
/// Default text size when text size can't be extracted from the widget
const double _kDefaultFontSize = 12.0;

/// Checks contrast of a text element and returns an [AccessibilityIssue] if
/// contrast is too low
///
/// Based on https://github.com/flutter/flutter/blob/5d96d619d88d6e7305fc3cae474db6762941b2fe/packages/flutter_test/lib/src/accessibility.dart
class TextContrastChecker extends AsyncSemanticsNodeChecker {
  ui.Image? _image;
  ByteData? _byteData;

  @override
  List<CheckerUpdateType> get updateType => [
        CheckerUpdateType.onSemanticsUpdate,
        CheckerUpdateType.onWidgetUpdate,
      ];

  @override
  Future<void> onSemanticsUpdated() => _takeScreenshot();

  @override
  Future<AccessibilityIssue?> checkNode(
    SemanticsNode node,
    RenderObject renderObject,
  ) async {
    // Skip disabled nodes, as they not required to pass contrast check.
    final bool isDisabled = node.hasFlag(SemanticsFlag.hasEnabledState) &&
        !node.hasFlag(SemanticsFlag.isEnabled);

    if (node.isInvisible ||
        node.isMergedIntoParent ||
        node.hasFlag(ui.SemanticsFlag.isHidden) ||
        isDisabled) {
      return null;
    }

    if (_image != null && _byteData != null) {
      return _evaluateNode(node, renderObject, _image!, _byteData!);
    }

    return null;
  }

  Future<void> _takeScreenshot() async {
    final renderView = WidgetsBinding.instance.renderView;
    final offsetLayer = renderView.debugLayer! as OffsetLayer;
    final ratio = 1 / WidgetsBinding.instance.window.devicePixelRatio;
    final newImage = await offsetLayer.toImage(
      renderView.paintBounds,
      pixelRatio: ratio,
    );

    if (newImage.hashCode != _image?.hashCode) {
      _image = newImage;
      _byteData = await newImage.toByteData();
    }
  }

  AccessibilityIssue? _evaluateNode(
    SemanticsNode node,
    RenderObject renderObject,
    ui.Image image,
    ByteData byteData,
  ) {
    late final Rect screenBounds;
    late final Rect paintBoundsWithOffset;

    if (renderObject is! RenderBox) {
      // Unexpected renderObject type
      return null;
    }

    if (!renderObject.attached) {
      return null;
    }

    final globalTransform = renderObject.getTransformTo(null);
    paintBoundsWithOffset = MatrixUtils.transformRect(
      globalTransform,
      renderObject.paintBounds.inflate(4.0),
    );

    // The semantics node transform will include root view transform, which is
    // not included in renderBox.getTransformTo(null). Manually multiply the
    // root transform to the global transform.
    final Matrix4 rootTransform = Matrix4.identity();
    final renderView = WidgetsBinding.instance.renderView;
    renderView.applyPaintTransform(renderView.child!, rootTransform);
    rootTransform.multiply(globalTransform);
    screenBounds =
        MatrixUtils.transformRect(rootTransform, renderObject.paintBounds);
    Rect nodeBounds = node.rect;
    SemanticsNode? current = node;
    while (current != null) {
      final Matrix4? transform = current.transform;
      if (transform != null) {
        nodeBounds = MatrixUtils.transformRect(transform, nodeBounds);
      }
      current = current.parent;
    }
    final Rect intersection = nodeBounds.intersect(screenBounds);
    if (intersection.width <= 0 || intersection.height <= 0) {
      // Skip this element since it doesn't correspond to the given semantic
      // node.
      return null;
    }

    // Look up inherited text properties to determine text size and weight.
    final element = renderObject.getCreatorElement();
    final widget = element?.widget;

    if (widget is! RichText) {
      return null;
    }

    final isBold = widget.text.style?.fontWeight == FontWeight.bold;
    final fontSize = widget.text.style?.fontSize;

    if (isNodeOffScreen(paintBoundsWithOffset)) {
      return null;
    }

    final colorHistogram = _colorsWithinRect(
      byteData,
      paintBoundsWithOffset,
      image.width,
      image.height,
    );

    // Node was too far off screen.
    if (colorHistogram.isEmpty) {
      return null;
    }

    final report = _ContrastReport(colorHistogram);
    final contrastRatio = report.contrastRatio();
    final targetContrastRatio = _targetContrastRatio(
      fontSize: fontSize,
      bold: isBold,
    );

    if (contrastRatio - targetContrastRatio >= _contrastTolerance) {
      return null;
    }

    return AccessibilityIssue(
      renderObject: renderObject,
      message: '''
Expected contrast ratio of at least $targetContrastRatio but found ${contrastRatio.toStringAsFixed(2)}''',
    );
  }

  /// Gives the color histogram of all pixels inside a given rectangle on the
  /// screen.
  ///
  /// Given a [ByteData] object [data], which stores the color of each pixel
  /// in row-first order, where each pixel is given in 4 bytes in RGBA order,
  /// and [paintBounds], the rectangle, and [width] and [height],
  //  the dimensions of the [ByteData] returns color histogram.
  Map<Color, int> _colorsWithinRect(
    ByteData data,
    Rect paintBounds,
    int width,
    int height,
  ) {
    final Rect truePaintBounds = paintBounds.intersect(
      Rect.fromLTWH(0.0, 0.0, width.toDouble(), height.toDouble()),
    );
    final int leftX = truePaintBounds.left.floor();
    final int rightX = truePaintBounds.right.ceil();
    final int topY = truePaintBounds.top.floor();
    final int bottomY = truePaintBounds.bottom.ceil();

    final Map<int, int> rgbaToCount = <int, int>{};

    int getPixel(ByteData data, int x, int y) {
      final int offset = (y * width + x) * 4;
      return data.getUint32(offset);
    }

    for (int x = leftX; x < rightX; x++) {
      for (int y = topY; y < bottomY; y++) {
        rgbaToCount.update(
          getPixel(data, x, y),
          (int count) => count + 1,
          ifAbsent: () => 1,
        );
      }
    }

    return rgbaToCount.map<Color, int>((int rgba, int count) {
      final int argb = (rgba << 24) | (rgba >> 8) & 0xFFFFFFFF;
      return MapEntry<Color, int>(Color(argb), count);
    });
  }

  /// Returns the required contrast ratio for the [fontSize] and [bold] setting.
  ///
  /// Defined by http://www.w3.org/TR/UNDERSTANDING-WCAG20/visual-audio-contrast-contrast.html
  static double _targetContrastRatio({
    required double? fontSize,
    required bool bold,
  }) {
    const int largeTextMinimumSize =
        // ignore: invalid_use_of_visible_for_testing_member
        MinimumTextContrastGuideline.kLargeTextMinimumSize;
    const int boldTextMinimumSize =
        // ignore: invalid_use_of_visible_for_testing_member
        MinimumTextContrastGuideline.kBoldTextMinimumSize;
    const double minimumRatioNormalText =
        // ignore: invalid_use_of_visible_for_testing_member
        MinimumTextContrastGuideline.kMinimumRatioNormalText;
    const double minimumRatioLargeText =
        // ignore: invalid_use_of_visible_for_testing_member
        MinimumTextContrastGuideline.kMinimumRatioLargeText;

    final double fontSizeOrDefault = fontSize ?? _kDefaultFontSize;
    if ((bold && fontSizeOrDefault >= boldTextMinimumSize) ||
        fontSizeOrDefault >= largeTextMinimumSize) {
      return minimumRatioLargeText;
    }
    return minimumRatioNormalText;
  }
}

/// A class that reports the contrast ratio of a part of the screen.
///
/// Commonly used in accessibility testing to obtain the contrast ratio of
/// text widgets and other types of widgets.
class _ContrastReport {
  /// Generates a contrast report given a color histogram.
  ///
  /// The contrast ratio of the most frequent light color and the most
  /// frequent dark color is calculated. Colors are divided into light and
  /// dark colors based on their lightness as an [HSLColor].
  factory _ContrastReport(Map<Color, int> colorHistogram) {
    // To determine the lighter and darker color, partition the colors
    // by HSL lightness and then choose the mode from each group.
    double totalLightness = 0.0;
    int count = 0;
    for (final MapEntry<Color, int> entry in colorHistogram.entries) {
      totalLightness += HSLColor.fromColor(entry.key).lightness * entry.value;
      count += entry.value;
    }
    final double averageLightness = totalLightness / count;
    assert(!averageLightness.isNaN, 'Average lightness is not a number');

    MapEntry<Color, int>? lightColor;
    MapEntry<Color, int>? darkColor;

    // Find the most frequently occurring light and dark color.
    for (final MapEntry<Color, int> entry in colorHistogram.entries) {
      final double lightness = HSLColor.fromColor(entry.key).lightness;
      final int count = entry.value;
      if (lightness <= averageLightness) {
        if (count > (darkColor?.value ?? 0)) {
          darkColor = entry;
        }
      } else if (count > (lightColor?.value ?? 0)) {
        lightColor = entry;
      }
    }

    // If there is only single color, it is reported as both dark and light.
    return _ContrastReport._(
      lightColor?.key ?? darkColor!.key,
      darkColor?.key ?? lightColor!.key,
    );
  }

  const _ContrastReport._(this.lightColor, this.darkColor);

  /// The most frequently occurring light color. Uses [Colors.transparent] if
  /// the rectangle is empty.
  final Color lightColor;

  /// The most frequently occurring dark color. Uses [Colors.transparent] if
  /// the rectangle is empty.
  final Color darkColor;

  /// Computes the contrast ratio as defined by the WCAG.
  ///
  /// Source: https://www.w3.org/TR/UNDERSTANDING-WCAG20/visual-audio-contrast-contrast.html
  double contrastRatio() =>
      (lightColor.computeLuminance() + 0.05) /
      (darkColor.computeLuminance() + 0.05);
}
