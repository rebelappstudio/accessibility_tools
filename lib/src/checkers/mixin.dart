import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

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

  void didUpdateSemantics();
}

class SemanticsClient extends ChangeNotifier {
  SemanticsClient(PipelineOwner pipelineOwner) {
    _semanticsOwner = pipelineOwner.semanticsOwner
      ?..addListener(notifyListeners);
  }

  late final SemanticsOwner? _semanticsOwner;

  @override
  void dispose() {
    // Looks like disposing root semantics owner is enough to dispose all
    // semantics owners so _semanticsOwner is not explicitly disposed here
    _semanticsOwner?.removeListener(notifyListeners);

    super.dispose();
  }
}
