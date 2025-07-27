/// An abstract class to define lifecycle hooks for dependency injection.
///
/// Classes that implement [Injectable] can be registered with the `Injector`
/// and automatically receive `onInit` and `onDispose` callbacks during their lifecycle.
///
/// Example:
/// ```dart
/// class MyService extends Injectable {
///   @override
///   void onInit() {
///     // Called when this service is first registered
///   }
///
///   @override
///   void onDispose() {
///     // Called when this service is removed/disposed
///   }
/// }
/// ```
abstract class Injectable {
  /// Called when the object is first registered using [Injector.put],
  /// [Injector.putScoped], [Injector.autoDisposePut], or [Injector.putTagged].
  ///
  /// Override this method to perform any initialization logic.
  void onInit() {}

  /// Called when the object is removed or cleaned up by the [Injector].
  ///
  /// Override this method to release resources or cleanup.
  void onDispose() {}
}
