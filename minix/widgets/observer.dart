import 'package:flutter/widgets.dart';
import 'package:minix/core/observable.dart';

/// Signature for the widget-building function used by [Observer].
typedef ObserverBuilder = Widget Function();

/// A reactive widget that rebuilds whenever any accessed [Observable] changes.
///
/// This is a simplified version of [ContextObserver] that doesn't provide
/// the [BuildContext] to the builder function.
///
/// Use this when you don't need context inside the builder and just want
/// pure reactive rebuilding based on `Observable` values.
///
/// Example usage:
/// ```dart
/// Observer(() {
///   final count = counterObservable.watch();
///   return Text('$count');
/// });
/// ```
class Observer extends StatefulWidget {
  /// The builder function that returns the widget tree.
  ///
  /// Any observable accessed inside this function will be tracked
  /// and automatically listened to for changes.
  final ObserverBuilder builder;

  /// Creates an [Observer] that listens for changes in observed values.
  const Observer(this.builder, {super.key});

  @override
  State<Observer> createState() => _ObserverState();
}

class _ObserverState extends State<Observer> {
  /// Called whenever an observed value changes.
  void _onObservableChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    ObservableTracker.instance.disposeObserver(_onObservableChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late final Widget built;

    // Track observables during build and register dependency.
    ObservableTracker.instance.runWithObserver(_onObservableChanged, () {
      try {
        built = widget.builder();
      } catch (e, stack) {
        built = ErrorWidget.withDetails(message: 'Observer build error: $e');
        debugPrint('Observer build error: $e\n$stack');
      }
    });

    return built;
  }
}
