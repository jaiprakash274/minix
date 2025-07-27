// observable.dart

/// A function that takes no arguments and returns no value.
typedef VoidCallback = void Function();

/// A reactive value that notifies listeners whenever its value changes.
///
/// This is the core building block of the reactive system in Minix.
/// Listeners can subscribe to changes and get notified automatically.
class Observable<T> {

  /// Creates a new Observable with the given initial value.
  Observable(this._value);
  /// The internal current value of the observable.
  T _value;

  /// Set of registered listeners for this observable.
  final Set<VoidCallback> _listeners = {};

  /// Gets the current value and tracks the observer if present.
  ///
  /// When accessed within a reactive context (e.g., inside an Observer widget),
  /// this method automatically registers the dependency.
  T get value {
    final currentObserver = ObservableTracker.instance.currentObserver;
    if (currentObserver != null) {
      if (!_listeners.contains(currentObserver)) {
        _listeners.add(currentObserver);
      }
      ObservableTracker.instance._registerDependency(currentObserver, this);
    }
    return _value;
  }

  /// Sets a new value and notifies all registered listeners if the value has changed.
  set value(T newValue) {
    if (_value != newValue) {
      _value = newValue;
      for (final listener in _listeners) {
        try {
          listener();
        } catch (e, stack) {
          // Optional: log the error
          print('Observable listener error: $e\n$stack');
        }
      }
    }
  }

  /// Removes a specific listener from this observable.
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Disposes the observable by clearing all listeners.
  void dispose() {
    _listeners.clear();
  }

  /// Returns the current value and tracks the dependency for reactivity.
  T watch() => value;

  /// Returns the current value without tracking dependency.
  T read() => _value;
}

/// Tracks current observers and their associated observable dependencies.
///
/// Used internally to enable automatic dependency registration and disposal.
class ObservableTracker {

  /// Internal constructor for singleton pattern.
  ObservableTracker._internal();
  /// The singleton instance of ObservableTracker.
  static final ObservableTracker instance = ObservableTracker._internal();

  /// Stores all observer functions and the observables they depend on.
  final Map<VoidCallback, Set<Observable>> _observerDependencies = {};

  /// The current active observer being tracked.
  VoidCallback? currentObserver;

  /// Executes a function within an observer context, enabling automatic dependency tracking.
  void runWithObserver(VoidCallback observer, VoidCallback fn) {
    currentObserver = observer;
    _observerDependencies[observer] = {};
    fn();
    currentObserver = null;
  }

  /// Registers an observable as a dependency for the given observer.
  void _registerDependency(VoidCallback observer, Observable observable) {
    _observerDependencies[observer]?.add(observable);
  }

  /// Disposes an observer and removes it from all observables it was listening to.
  void disposeObserver(VoidCallback observer) {
    final observables = _observerDependencies[observer];
    if (observables != null) {
      for (final obs in observables) {
        obs.removeListener(observer);
      }
      _observerDependencies.remove(observer);
    }
  }
}
