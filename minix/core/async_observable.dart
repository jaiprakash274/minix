// async_observable.dart

import 'package:minix/core/observable.dart';

/// Represents the current state of an asynchronous operation.
enum AsyncState {
  /// Initial state before any operation starts.
  idle,

  /// Indicates the async operation is currently running.
  loading,

  /// Operation completed successfully with data.
  success,

  /// Operation failed with an error.
  error
}

/// A reactive wrapper for managing asynchronous operations and their states.
///
/// Provides built-in support for tracking:
/// - Loading state
/// - Successful data
/// - Error messages
///
/// Works seamlessly with Observer widgets for automatic UI updates.
class AsyncObservable<T> {
  final Observable<AsyncState> _state = Observable(AsyncState.idle);
  final Observable<T?> _data = Observable(null);
  final Observable<String?> _error = Observable(null);

  // --- Getters ---

  /// Current async state (idle, loading, success, error).
  AsyncState get state => _state.value;

  /// Current data if the async operation succeeded.
  T? get data => _data.value;

  /// Current error message if the async operation failed.
  String? get error => _error.value;

  /// Whether the operation is currently loading.
  bool get isLoading => _state.value == AsyncState.loading;

  /// Whether data is available.
  bool get hasData => _data.value != null;

  /// Whether an error has occurred.
  bool get hasError => _error.value != null;

  // --- Reactive Watchers ---

  /// Watches and returns the current async state reactively.
  AsyncState watchState() => _state.watch();

  /// Watches and returns the data reactively.
  T? watchData() => _data.watch();

  /// Watches and returns the error reactively.
  String? watchError() => _error.watch();

  /// Watches and returns whether it's currently loading.
  bool watchLoading() => _state.watch() == AsyncState.loading;

  // --- Execution ---

  /// Executes an asynchronous [operation] and updates the state accordingly.
  ///
  /// On success: updates [data] and sets state to [AsyncState.success].
  /// On error: sets error message and updates state to [AsyncState.error].
  Future<void> execute(Future<T> Function() operation) async {
    try {
      _state.value = AsyncState.loading;
      _error.value = null;

      final result = await operation();

      _data.value = result;
      _state.value = AsyncState.success;
    } catch (e) {
      _error.value = e.toString();
      _state.value = AsyncState.error;
    }
  }

  // --- Manual Updates ---

  /// Sets the value manually and marks state as successful.
  void setData(T data) {
    _data.value = data;
    _state.value = AsyncState.success;
    _error.value = null;
  }

  /// Sets the error message manually and marks state as error.
  void setError(String error) {
    _error.value = error;
    _state.value = AsyncState.error;
  }

  /// Resets the observable to initial idle state.
  void reset() {
    _state.value = AsyncState.idle;
    _data.value = null;
    _error.value = null;
  }

  /// Disposes all underlying observables.
  void dispose() {
    _state.dispose();
    _data.dispose();
    _error.dispose();
  }
}
