import 'dart:math';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

import 'accessibility_issue.dart';
import 'checker_manager.dart';
import 'checkers/checker_base.dart';
import 'checkers/flex_overflow_checker.dart';
import 'checkers/input_label_checker.dart';
import 'checkers/minimum_tap_area_checker.dart';
import 'checkers/mixin.dart';
import 'checkers/semantic_label_checker.dart';

const _warningBoxMinSize = 48.0;
const iOSLargestTextScaleFactor = 1.35;

/// A checker for debug mode that highlights accessibility issues.
///
/// Issues are highlighted by a red box.
class AccessibilityTools extends StatefulWidget {
  const AccessibilityTools({
    super.key,
    required this.child,
    this.minimumTapAreas = MinimumTapAreas.material,
    this.checkSemanticLabels = true,
    this.checkMissingInputLabels = true,
    this.checkFontOverflows = false,
  });

  /// Forces accessibility checkers to run when running from a test.
  @visibleForTesting
  static bool debugRunCheckersInTests = false;

  final Widget? child;
  final MinimumTapAreas? minimumTapAreas;
  final bool checkSemanticLabels;
  final bool checkFontOverflows;
  final bool checkMissingInputLabels;

  @override
  State<AccessibilityTools> createState() => _AccessibilityToolsState();
}

class _AccessibilityToolsState extends State<AccessibilityTools>
    with SemanticUpdateMixin {
  late CheckerManager _checker = CheckerManager(_getCheckers());

  @override
  void dispose() {
    _checker.dispose();
    super.dispose();
  }

  @override
  void didUpdateSemantics() {
    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      // Semantic information are only available at the end of a frame and our
      // only chance to paint them on the screen is the next frame. To achieve
      // this, we call setState() in a post-frame callback.
      if (mounted) {
        _checker.update();
      }
    });
  }

  @override
  void didUpdateWidget(covariant AccessibilityTools oldWidget) {
    _checker.dispose();
    _checker = CheckerManager(_getCheckers());
    super.didUpdateWidget(oldWidget);
  }

  List<CheckerBase> _getCheckers() {
    final minTapAreas = widget.minimumTapAreas;
    final targetPlatform = Theme.of(context).platform;

    return [
      if (widget.checkSemanticLabels) SemanticLabelChecker(),
      if (minTapAreas != null)
        MinimumTapAreaChecker(
          minTapArea: minTapAreas.forPlatform(targetPlatform),
        ),
      if (widget.checkFontOverflows)
        FlexOverflowChecker(
          textScaleFactor: iOSLargestTextScaleFactor,
        ),
      if (widget.checkMissingInputLabels) InputLabelChecker(),
    ];
  }

  late final _isTest = WidgetsBinding.instance is TestWidgetsFlutterBinding;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode ||
        kIsWeb ||
        (!AccessibilityTools.debugRunCheckersInTests && _isTest)) {
      return widget.child!;
    }

    final actualChild = widget.child;
    if (actualChild == null) {
      return const SizedBox();
    }

    Widget child = actualChild;
    for (final checker in _checker.checkers) {
      if (checker is WidgetCheckerBase) {
        child = checker.build(context, child);
      }
    }

    return Stack(
      textDirection: ui.TextDirection.ltr,
      children: [
        child,
        Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (_) {
                return CheckerOverlay(checker: _checker);
              },
            ),
          ],
        ),
      ],
    );
  }
}

class CheckerOverlay extends StatefulWidget {
  const CheckerOverlay({
    super.key,
    required this.checker,
  });

  final CheckerManager checker;

  @override
  State<CheckerOverlay> createState() => _CheckerOverlayState();
}

class _CheckerOverlayState extends State<CheckerOverlay> {
  bool showOverlays = false;

  static Rect _inflateToMinimumSize(Rect rect) {
    if (rect.shortestSide < _warningBoxMinSize) {
      return Rect.fromCenter(
        center: rect.center,
        width: max(_warningBoxMinSize, rect.width),
        height: max(_warningBoxMinSize, rect.height),
      );
    }

    return rect;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.checker,
      builder: (context, _) {
        final issues = List<AccessibilityIssue>.of(widget.checker.issues);
        final rects = issues
            .where((element) => element.renderObject.attached)
            .groupListsBy((issue) => issue.renderObject.getGlobalRect());

        const errorBorderWidth = 5.0;

        return Stack(
          children: [
            if (showOverlays)
              for (final entry in rects.entries)
                Positioned.fromRect(
                  rect: _inflateToMinimumSize(entry.key)
                      .inflate(errorBorderWidth),
                  child: WarningBox(
                    borderWidth: errorBorderWidth,
                    message: entry.value.map((e) => e.message).join('\n\n'),
                    size: Size(
                      max(5, entry.key.width) + errorBorderWidth,
                      max(5, entry.key.height) + errorBorderWidth,
                    ),
                  ),
                ),
            if (issues.isNotEmpty)
              Positioned(
                bottom: 10,
                right: 10,
                child: SafeArea(
                  child: _WarningButton(
                    issues: issues,
                    onPressed: () {
                      setState(() => showOverlays = !showOverlays);
                    },
                    toggled: showOverlays,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _WarningButton extends StatelessWidget {
  const _WarningButton({
    required this.issues,
    required this.onPressed,
    required this.toggled,
  });

  final bool toggled;
  final List<AccessibilityIssue> issues;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: _warningBoxMinSize,
      child: Tooltip(
        message: issues.length == 1
            ? 'Accessibility issue found'
            : '${issues.length} accessibility issues found',
        child: Transform.translate(
          offset: toggled ? const Offset(1, 1) : Offset.zero,
          child: FloatingActionButton(
            elevation: toggled ? 0 : 10,
            hoverElevation: toggled ? 0 : 10,
            onPressed: onPressed,
            backgroundColor: toggled ? Colors.orange : Colors.red,
            child: Icon(
              Icons.accessibility_new,
              size: 25,
              color: toggled ? Colors.white : Colors.yellow,
              semanticLabel: toggled
                  ? 'Hide accessibility issues'
                  : 'Show accessibility issues',
            ),
          ),
        ),
      ),
    );
  }
}

class WarningBox extends StatelessWidget {
  const WarningBox({
    super.key,
    required this.size,
    required this.borderWidth,
    required this.message,
  });

  final Size size;
  final double borderWidth;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        padding: const EdgeInsets.all(10),
        message: message,
        decoration: const BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          color: Colors.white,
        ),
        child: Center(
          child: CustomPaint(
            size: size,
            painter: WarningBoxPainter(
              borderWidth: borderWidth,
            ),
          ),
        ),
      ),
    );
  }
}

class WarningBoxPainter extends CustomPainter {
  WarningBoxPainter({required this.borderWidth});

  final double borderWidth;

  static const Color _black = Color(0xBF000000);
  static const Color _yellow = Color(0xBFFFFF00);

  static final Paint _indicatorPaint = Paint()
    ..style = PaintingStyle.stroke
    ..shader = ui.Gradient.linear(
      Offset.zero,
      const Offset(10.0, 10.0),
      <Color>[_black, _yellow, _yellow, _black],
      <double>[0.25, 0.25, 0.75, 0.75],
      TileMode.repeated,
    )
    ..strokeWidth = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      _indicatorPaint,
    );
  }

  @override
  bool shouldRepaint(WarningBoxPainter oldDelegate) {
    return oldDelegate.borderWidth != borderWidth;
  }
}
