/// Minix: A lightweight state management and dependency injection system for Flutter.
///
/// ✅ Simple and reactive `Observable`, `AsyncObservable`, and `StreamObservable`.
/// ✅ Flutter widgets: `Observer` and `ContextObserver` for automatic rebuilds.
/// ✅ Powerful `Injector` for scoped, tagged, and auto-disposed DI.
///
/// Example:
/// ```dart
/// final counter = Observable(0);
///
/// Observer(() => Text('${counter.watch()}'));
///
/// class MyService extends Injectable {
///   @override
///   void onInit() => print('Initialized');
/// }
///
/// void main() {
///   Injector.put(MyService());
/// }
/// ```
///
/// This file exports all core APIs of the Minix framework.
library minix;

export 'core/observable.dart';
export 'core/async_observable.dart';
export 'core/stream_observable.dart';
export 'core/injector.dart';
export 'core/injectable.dart';
export 'widgets/observer.dart';
export 'widgets/context_observer.dart';
