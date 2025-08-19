import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// A mixin to update the semantics of the widget tree.
///
/// A listener is set up in [initState] to notify this mixin's descendants that
/// the semantics of the widget tree has changed and it's time to check the
/// accessibility of the widget tree.
///
/// Descendants should implement [didUpdateSemantics] to get notified about the
/// semantics updates.
mixin SemanticUpdateMixin<T extends StatefulWidget> on State<T> {
  late final List<SemanticsClient> _clients = [];
  late final SemanticsHandle _rootSemanticsHandle;

  @override
  void initState() {
    _rootSemanticsHandle = SemanticsBinding.instance.ensureSemantics();

    RendererBinding.instance.rootPipelineOwner.visitChildren((child) {
      final client = SemanticsClient(child)..addListener(_update);
      _clients.add(client);
    });

    super.initState();
  }

  @override
  void dispose() {
    _rootSemanticsHandle.dispose();

    for (final client in _clients) {
      client
        ..removeListener(_update)
        ..dispose();
    }

    super.dispose();
  }

  void _update() {
    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      if (mounted) {
        setState(didUpdateSemantics);
      }
    });
  }

  /// Notifies the mixin that the semantics of the widget tree has changed.
  void didUpdateSemantics();
}

/// A client to listen to semantics updates of a pipeline owner.
class SemanticsClient extends ChangeNotifier {
  /// Default constructor.
  SemanticsClient(PipelineOwner pipelineOwner) {
    _semanticsOwner = pipelineOwner.semanticsOwner
      ?..addListener(notifyListeners);
  }

  late final SemanticsOwner? _semanticsOwner;

  @override
  void dispose() {
    // Looks like disposing root semantics owner is enough to dispose all
    // semantics owners so _semanticsOwner is not explicitly disposed here.
    _semanticsOwner?.removeListener(notifyListeners);

    super.dispose();
  }
}
