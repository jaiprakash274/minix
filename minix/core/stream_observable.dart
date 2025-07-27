import 'dart:async';
import 'package:minix/core/observable.dart';

/// Represents the various states a [StreamObservable] can be in.
enum StreamState {
  /// No stream is currently active.
  idle,

  /// A stream is currently being listened to.
  listening,

  /// The stream has been paused.
  paused,

  /// The stream has been closed or completed.
  closed,

  /// The stream encountered an error.
  error,
}

/// A reactive wrapper around Dart's [Stream], enabling observable state,
/// error handling, and reactive UI updates.
///
/// Integrates with the `Observable` system in Minix to automatically track:
/// - Current stream value
/// - Stream state (idle, listening, paused, closed, error)
/// - Errors
/// - Whether data has been received
class StreamObservable<T> {
  final Observable<StreamState> _state = Observable(StreamState.idle);
  final Observable<T?> _data = Observable(null);
  final Observable<String?> _error = Observable(null);
  final Observable<bool> _hasData = Observable(false);

  StreamSubscription<T>? _subscription;
  Stream<T>? _stream;

  // --- Getters ---

  /// Current stream state.
  StreamState get state => _state.value;

  /// Most recent data emitted from the stream.
  T? get data => _data.value;

  /// Latest error encountered, if any.
  String? get error => _error.value;

  /// Whether the stream is currently listening.
  bool get isListening => _state.value == StreamState.listening;

  /// Whether the stream is currently paused.
  bool get isPaused => _state.value == StreamState.paused;

  /// Whether the stream has been closed.
  bool get isClosed => _state.value == StreamState.closed;

  /// Whether any data has been emitted yet.
  bool get hasData => _hasData.value;

  /// Whether an error occurred.
  bool get hasError => _error.value != null;

  // --- Reactive Watchers ---

  /// Reactively watches the current [StreamState].
  StreamState watchState() => _state.watch();

  /// Reactively watches the current stream data.
  T? watchData() => _data.watch();

  /// Reactively watches the error.
  String? watchError() => _error.watch();

  /// Reactively checks whether the stream is listening.
  bool watchListening() => _state.watch() == StreamState.listening;

  /// Reactively checks whether data has been received.
  bool watchHasData() => _hasData.watch();

  // --- Stream Handling ---

  /// Starts listening to a given [stream] and updates state/data accordingly.
  ///
  /// Optional callbacks:
  /// - [onData]: called on each data event
  /// - [onError]: called on error
  /// - [onDone]: called when stream closes
  /// - [cancelOnError]: if true, cancels stream on error
  void listen(
      Stream<T> stream, {
        void Function(T data)? onData,
        void Function(String error)? onError,
        void Function()? onDone,
        bool cancelOnError = false,
      }) {
    cancel();

    _stream = stream;
    _state.value = StreamState.listening;
    _error.value = null;

    _subscription = stream.listen(
          (data) {
        _data.value = data;
        _hasData.value = true;
        _error.value = null;
        onData?.call(data);
      },
      onError: (error) {
        _error.value = error.toString();
        _state.value = StreamState.error;
        onError?.call(error.toString());
      },
      onDone: () {
        _state.value = StreamState.closed;
        onDone?.call();
      },
      cancelOnError: cancelOnError,
    );
  }

  /// Pauses the active stream if it's currently listening.
  void pause() {
    if (_subscription != null && !_subscription!.isPaused) {
      _subscription!.pause();
      _state.value = StreamState.paused;
    }
  }

  /// Resumes the paused stream.
  void resume() {
    if (_subscription != null && _subscription!.isPaused) {
      _subscription!.resume();
      _state.value = StreamState.listening;
    }
  }

  /// Cancels the current stream subscription.
  Future<void> cancel() async {
    await _subscription?.cancel();
    _subscription = null;
    if (_state.value != StreamState.closed) {
      _state.value = StreamState.idle;
    }
  }

  // --- Transformations ---

  /// Transforms the stream using a mapping function [mapper].
  ///
  /// Returns a new [StreamObservable<R>] with mapped values.
  ///
  /// ⚠️ Requires [listen] to be called first.
  StreamObservable<R> map<R>(R Function(T data) mapper) {
    if (_stream == null) {
      throw StateError('Call listen() first before using map()');
    }

    final newObs = StreamObservable<R>();
    final newStream = _stream!.map(mapper);
    newObs.listen(newStream);
    return newObs;
  }

  /// Filters the stream using a [predicate] function.
  ///
  /// Returns a new [StreamObservable<T>] with filtered values.
  ///
  /// ⚠️ Requires [listen] to be called first.
  StreamObservable<T> where(bool Function(T data) predicate) {
    if (_stream == null) {
      throw StateError('Call listen() first before using where()');
    }

    final newObs = StreamObservable<T>();
    final filtered = _stream!.where(predicate);
    newObs.listen(filtered);
    return newObs;
  }

  // --- Manual Updates ---

  /// Manually sets the data value.
  void setData(T data) {
    _data.value = data;
    _hasData.value = true;
    _error.value = null;
  }

  /// Manually sets the error message and state to [StreamState.error].
  void setError(String error) {
    _error.value = error;
    _state.value = StreamState.error;
  }

  /// Resets the stream observable to idle state.
  void reset() {
    cancel();
    _state.value = StreamState.idle;
    _data.value = null;
    _error.value = null;
    _hasData.value = false;
  }

  /// Disposes all internal observables and cancels any active stream.
  Future<void> dispose() async {
    await cancel();
    _state.dispose();
    _data.dispose();
    _error.dispose();
    _hasData.dispose();
  }
}

/// Extension on [Stream] to easily convert it to a [StreamObservable].
extension StreamObservableExtension<T> on Stream<T> {
  /// Converts any [Stream<T>] into a [StreamObservable<T>] and starts listening.
  StreamObservable<T> toObservable() {
    final observable = StreamObservable<T>();
    observable.listen(this);
    return observable;
  }
}
