import 'dart:async';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../accessibility_issue.dart';

enum CheckerUpdateType { onSemanticsUpdate, onWidgetUpdate }

abstract class CheckerBase extends ChangeNotifier {
  List<AccessibilityIssue> _issues = [];
  List<AccessibilityIssue> get issues => _issues;
  set issues(List<AccessibilityIssue> issues) {
    _issues = issues;
    notifyListeners();
  }

  void didUpdateSemantics(List<RenderObject> semanticRenderObjects);

  @protected
  Rect getPaintBounds(SemanticsNode node) {
    Rect paintBounds = node.rect;
    SemanticsNode? current = node;
    while (current != null) {
      if (current.transform != null) {
        paintBounds =
            MatrixUtils.transformRect(current.transform!, paintBounds);
      }
      current = current.parent;
    }

    return paintBounds;
  }

  @protected
  bool isNodeOffScreen(Rect paintBounds) {
    final window = WidgetsBinding.instance.window;
    final windowPhysicalSize = window.physicalSize * window.devicePixelRatio;
    return paintBounds.top < -50.0 ||
        paintBounds.left < -50.0 ||
        paintBounds.bottom > windowPhysicalSize.height + 50.0 ||
        paintBounds.right > windowPhysicalSize.width + 50.0;
  }

  // When this checker is called to process updated data
  List<CheckerUpdateType> get updateType;
}

abstract class SemanticsNodeChecker extends CheckerBase {
  @override
  void didUpdateSemantics(List<RenderObject> semanticRenderObjects) {
    issues = semanticRenderObjects
        .map((node) => checkNode(node.debugSemantics!, node))
        .whereNotNull()
        .toList();
  }

  AccessibilityIssue? checkNode(
    SemanticsNode node,
    RenderObject renderObject,
  );
}

abstract class AsyncSemanticsNodeChecker extends CheckerBase {
  Timer? _debounceTimer;

  @override
  Future<void> didUpdateSemantics(
    List<RenderObject> semanticRenderObjects,
  ) async {
    _debounce(() async {
      await onSemanticsUpdated();

      final futures = semanticRenderObjects
          .map((node) => checkNode(node.debugSemantics!, node))
          .whereNotNull()
          .toList();
      final issues = await Future.wait(futures);
      this.issues = issues.whereNotNull().toList();
    });
  }

  Future<void> onSemanticsUpdated();

  Future<AccessibilityIssue?> checkNode(
    SemanticsNode node,
    RenderObject renderObject,
  );

  void _debounce(
    Future<void> Function() action, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      delay,
      () async {
        _debounceTimer?.cancel();
        await action();
      },
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

abstract class WidgetCheckerBase extends CheckerBase {
  Widget build(BuildContext context, Widget child);
}

extension RenderObjectExtension on RenderObject {
  @protected
  Rect getGlobalRect() {
    assert(attached, 'RenderObject must be attached to get global rect');

    final translation = getTransformTo(null).getTranslation();
    final offset = Offset(translation.x, translation.y);
    return paintBounds.shift(offset);
  }

  Element? getCreatorElement() {
    final creator = debugCreator;
    if (creator is DebugCreator) {
      return creator.element;
    }

    return null;
  }
}

extension SemanticsDataExtension on SemanticsData {
  bool get isTappable {
    return hasAction(ui.SemanticsAction.longPress) ||
        hasAction(ui.SemanticsAction.tap);
  }
}
