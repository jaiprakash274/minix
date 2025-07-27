import 'package:flutter/widgets.dart';
import 'package:minix/core/observable.dart';

/// Signature for the widget-building function used by [ContextObserver].
typedef ContextObserverBuilder = Widget Function(BuildContext context);

/// A reactive widget that rebuilds automatically when any used [Observable] changes.
///
/// It tracks all observables accessed during the widget build phase,
/// and automatically listens to them for changes.
///
/// Similar in concept to `GetX`'s `Obx` or `MobX`'s `Observer`.
///
/// Example usage:
/// ```dart
/// ContextObserver(
///   (context) {
///     final counter = someObservable.watch();
///     return Text('$counter');
///   },
/// );
/// ```
class ContextObserver extends StatefulWidget {
  /// The builder function that returns the widget tree.
  ///
  /// Any observable accessed within this function will be tracked and
  /// automatically listened to for changes.
  final ContextObserverBuilder builder;

  /// Creates a [ContextObserver] that listens for changes in observed values.
  const ContextObserver(this.builder, {super.key});

  @override
  State<ContextObserver> createState() => _ContextObserverState();
}

class _ContextObserverState extends State<ContextObserver> {
  /// Callback triggered when a dependency changes.
  void _onChanged() => setState(() {});

  @override
  void dispose() {
    // Remove this widget from the observable dependency tracker.
    ObservableTracker.instance.disposeObserver(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late final Widget built;

    // Track observables during build and register dependency.
    ObservableTracker.instance.runWithObserver(_onChanged, () {
      try {
        built = widget.builder(context);
      } catch (e, stack) {
        built = ErrorWidget.withDetails(message: 'ContextObserver error: $e');
        debugPrint('ContextObserver build error: $e\n$stack');
      }
    });

    return built;
  }
}
