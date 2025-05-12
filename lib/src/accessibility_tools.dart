import 'dart:math';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'accessibility_issue.dart';
import 'checker_manager.dart';
import 'checkers/checker_base.dart';
import 'checkers/flex_overflow_checker.dart';
import 'checkers/ignore_minimum_tap_area_size.dart';
import 'checkers/image_label_checker.dart';
import 'checkers/input_label_checker.dart';
import 'checkers/minimum_tap_area_checker.dart';
import 'checkers/mixin.dart';
import 'checkers/semantic_label_checker.dart';
import 'enums/buttons_alignment.dart';
import 'floating_action_buttons.dart';
import 'testing_tools/test_environment.dart';
import 'testing_tools/testing_tools_configuration.dart';
import 'testing_tools/testing_tools_panel.dart';
import 'testing_tools/testing_tools_wrapper.dart';

const iOSLargestTextScaleFactor = 1.35;

/// Set log level for the accessibility tools. By default it prints all
/// available info about found issues and suggested solutions
enum LogLevel {
  /// Print found issues and suggested solution
  verbose,

  /// Print info about found issues but not resolution guidance
  warning,

  /// Don't print anything to the log. Useful when you don't want logs polluted
  /// with too many messages (developing the app or only using accessibility
  /// tools UI)
  none,
}

/// A checker for debug mode that highlights accessibility issues.
///
/// Issues are highlighted by a red box.
class AccessibilityTools extends StatefulWidget {
  const AccessibilityTools({
    super.key,
    required this.child,
    this.minimumTapAreas = MinimumTapAreas.material,
    this.logLevel = LogLevel.verbose,
    this.checkSemanticLabels = true,
    this.checkMissingInputLabels = true,
    this.checkFontOverflows = false,
    this.checkImageLabels = true,
    this.buttonsAlignment = ButtonsAlignment.bottomRight,
    this.enableButtonsDrag = false,
    this.testingToolsConfiguration = const TestingToolsConfiguration(),
    this.testEnvironment = const TestEnvironment(),
  });

  /// Forces accessibility checkers to run when running from a test.
  @visibleForTesting
  static bool debugRunCheckersInTests = false;

  /// Forces accessibility tools to ignore its own tap area size issues.
  ///
  /// Accessibility tools uses Material widgets and is tested not to have
  /// accessibility issues. However, in some rare cases issues can be
  /// reported. For example, when [minimumTapAreas] is set to be bigger than
  /// Material guidelines or when scrolling and widget is partially off screen.
  ///
  /// Setting this flag to true will ignore all accessibility issues in
  /// accessibility tools. Setting this flag to false will report all
  /// accessibility issues found in accessibility tools.
  @visibleForTesting
  static bool debugIgnoreTapAreaIssuesInTools = true;

  final Widget? child;
  final MinimumTapAreas? minimumTapAreas;
  final LogLevel logLevel;
  final bool checkSemanticLabels;
  final bool checkFontOverflows;
  final bool checkMissingInputLabels;
  final bool checkImageLabels;

  final ButtonsAlignment buttonsAlignment;
  final bool enableButtonsDrag;
  final TestingToolsConfiguration testingToolsConfiguration;
  final TestEnvironment testEnvironment;

  @override
  State<AccessibilityTools> createState() => _AccessibilityToolsState();
}

class _AccessibilityToolsState extends State<AccessibilityTools>
    with SemanticUpdateMixin {
  late CheckerManager _checker = CheckerManager(
    checkers: _getCheckers(),
    logLevel: widget.logLevel,
  );

  bool _testingToolsVisible = false;
  late TestEnvironment _environment = widget.testEnvironment;

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
    _checker = CheckerManager(
      checkers: _getCheckers(),
      logLevel: widget.logLevel,
    );
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
      if (widget.checkImageLabels) ImageLabelChecker(),
    ];
  }

  /// Returns true if currently running in a test environment (e.g.
  /// widget tests).
  ///
  /// It uses type names instead of `is` operator because all test binginds are
  /// part of flutter_test which uses dart:io. In order to support WASM, dart:io
  /// should not be used.
  bool get _isTest {
    final bindingName = WidgetsBinding.instance.runtimeType.toString();
    return const [
      'AutomatedTestWidgetsFlutterBinding',
      'LiveTestWidgetsFlutterBinding',
      'TestWidgetsFlutterBinding',
    ].contains(bindingName);
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode ||
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
        TestingToolsWrapper(
          environment: _environment,
          child: child,
        ),
        Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (_) {
                final child = CheckerOverlay(
                  checker: _checker,
                  buttonsAlignment: widget.buttonsAlignment,
                  enableButtonsDrag: widget.enableButtonsDrag,
                  isTestingPanelEnabled:
                      widget.testingToolsConfiguration.enabled,
                  onToolsButtonPressed: () {
                    setState(() {
                      _testingToolsVisible = !_testingToolsVisible;
                    });
                  },
                  onHideTestingTools: () {
                    setState(() => _testingToolsVisible = false);
                  },
                );

                return AccessibilityTools.debugIgnoreTapAreaIssuesInTools
                    ? IgnoreMinimumTapAreaSize(child: child)
                    : child;
              },
            ),
            if (widget.testingToolsConfiguration.enabled)
              OverlayEntry(
                builder: (context) {
                  if (!_testingToolsVisible) return const SizedBox();

                  final child = TestingToolsPanel(
                    environment: _environment,
                    configuration: widget.testingToolsConfiguration,
                    onClose: () {
                      setState(() => _testingToolsVisible = false);
                    },
                    onEnvironmentUpdate: (TestEnvironment environment) {
                      setState(() => _environment = environment);
                    },
                  );

                  return AccessibilityTools.debugIgnoreTapAreaIssuesInTools
                      ? IgnoreMinimumTapAreaSize(child: child)
                      : child;
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
    required this.onToolsButtonPressed,
    required this.onHideTestingTools,
    required this.isTestingPanelEnabled,
    this.buttonsAlignment = ButtonsAlignment.bottomRight,
    this.enableButtonsDrag = false,
  });

  final CheckerManager checker;
  final VoidCallback onToolsButtonPressed;
  final VoidCallback onHideTestingTools;
  final ButtonsAlignment buttonsAlignment;
  final bool enableButtonsDrag;
  final bool isTestingPanelEnabled;

  @override
  State<CheckerOverlay> createState() => _CheckerOverlayState();
}

class _CheckerOverlayState extends State<CheckerOverlay> {
  bool showOverlays = false;

  static Rect _inflateToMinimumSize(Rect rect) {
    if (rect.shortestSide < toolsBoxMinSize) {
      return Rect.fromCenter(
        center: rect.center,
        width: max(toolsBoxMinSize, rect.width),
        height: max(toolsBoxMinSize, rect.height),
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
            _DraggablePositioned(
              minSpacing: 10,
              initialAlignment: widget.buttonsAlignment,
              enableDrag: widget.enableButtonsDrag,
              child: _WarningButton(
                issues: issues,
                isTestingPanelEnabled: widget.isTestingPanelEnabled,
                onPressed: () {
                  setState(() {
                    showOverlays = !showOverlays;
                    widget.onHideTestingTools();
                  });
                },
                toggled: showOverlays,
                onToolsButtonPressed: () {
                  setState(() {
                    showOverlays = false;
                    widget.onToolsButtonPressed();
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DraggablePositioned extends StatefulWidget {
  const _DraggablePositioned({
    this.initialAlignment = ButtonsAlignment.bottomRight,
    required this.minSpacing,
    required this.enableDrag,
    required this.child,
  });

  final ButtonsAlignment initialAlignment;
  final double minSpacing;
  final bool enableDrag;
  final Widget child;

  @override
  State<_DraggablePositioned> createState() => _DraggablePositionedState();
}

class _DraggablePositionedState extends State<_DraggablePositioned> {
  late Offset _offset = Offset(widget.minSpacing, widget.minSpacing);
  late ButtonsAlignment _alignment = widget.initialAlignment;

  Offset _panPosition = Offset.zero;
  bool _isDragging = false;

  void _updateAlignedPosition(Offset position) {
    final delta = position - _panPosition;
    switch (_alignment) {
      case ButtonsAlignment.topLeft:
        _offset = Offset(_offset.dx + delta.dx, _offset.dy + delta.dy);
        break;
      case ButtonsAlignment.topRight:
        _offset = Offset(_offset.dx - delta.dx, _offset.dy + delta.dy);
        break;
      case ButtonsAlignment.bottomLeft:
        _offset = Offset(_offset.dx + delta.dx, _offset.dy - delta.dy);
        break;
      case ButtonsAlignment.bottomRight:
        _offset = Offset(_offset.dx - delta.dx, _offset.dy - delta.dy);
        break;
    }
    setState(() => _panPosition = position);
  }

  void _calculateAlignment() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final leftHalf = _panPosition.dx < width / 2;
    final topHalf = _panPosition.dy < height / 2;

    if (leftHalf) {
      if (topHalf) {
        _alignment = ButtonsAlignment.topLeft;
      } else {
        _alignment = ButtonsAlignment.bottomLeft;
      }
    } else {
      if (topHalf) {
        _alignment = ButtonsAlignment.topRight;
      } else {
        _alignment = ButtonsAlignment.bottomRight;
      }
    }

    setState(() {
      _offset = Offset(widget.minSpacing, widget.minSpacing);
    });
  }

  void _validateMinDrag(DragUpdateDetails details) {
    final delta = _panPosition - details.globalPosition;
    final distance = delta.distanceSquared;
    if (distance > 300) {
      _isDragging = true;
    }
  }

  void _onPanStart(DragStartDetails details) =>
      _panPosition = details.globalPosition;

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isDragging) {
      _updateAlignedPosition(details.globalPosition);
    } else {
      _validateMinDrag(details);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;
    _panPosition = details.globalPosition;
    _calculateAlignment();
  }

  Widget _buildAlignedPosition(BuildContext context, Widget child) {
    switch (_alignment) {
      case ButtonsAlignment.topLeft:
        return Positioned(
          left: _offset.dx,
          top: _offset.dy,
          child: child,
        );
      case ButtonsAlignment.topRight:
        return Positioned(
          right: _offset.dx,
          top: _offset.dy,
          child: child,
        );
      case ButtonsAlignment.bottomLeft:
        return Positioned(
          left: _offset.dx,
          bottom: _offset.dy,
          child: child,
        );
      case ButtonsAlignment.bottomRight:
        return Positioned(
          right: _offset.dx,
          bottom: _offset.dy,
          child: child,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildAlignedPosition(
      context,
      SafeArea(
        child: widget.enableDrag
            ? GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: widget.child,
              )
            : widget.child,
      ),
    );
  }
}

class _WarningButton extends StatelessWidget {
  const _WarningButton({
    required this.issues,
    required this.onPressed,
    required this.onToolsButtonPressed,
    required this.toggled,
    required this.isTestingPanelEnabled,
  });

  final bool toggled;
  final bool isTestingPanelEnabled;
  final List<AccessibilityIssue> issues;
  final VoidCallback onPressed;
  final VoidCallback onToolsButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (issues.isNotEmpty)
          AccessibilityIssuesToggle(
            toggled: toggled,
            issues: issues,
            onPressed: onPressed,
          ),
        if (isTestingPanelEnabled) ...[
          const SizedBox(height: 12),
          AccessibilityToolsToggle(
            onToolsButtonPressed: onToolsButtonPressed,
          ),
        ],
      ],
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
