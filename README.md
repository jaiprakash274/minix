![Minix Image](https://github.com/jaiprakash274/minix/blob/main/Minix.jpeg)
# MiniX
MiniX is a minimal yet powerful state management & dependency injection library for flutter app and clear syntax focused on simplicity.
## Built with ❤️ by [Jai Prakash Thawait](https://github.com/jaiprakash02)
## Features

- ✅ Reactive state with `Observable<T>`
- ✅ Auto UI rebuild with `Observer` widget
- ✅ Simple DI using `Injector.put()` and `Injector.find()` and etc.

## ✨ Features

- ✅ **Observable State** – Track reactive values with zero boilerplate.
- 🔁 **Observer Widget** – Automatically rebuild UI when observables change.
- 🧪 **Dependency Injection** – Easily manage and access your app's dependencies.
- 🧼 **Auto Dispose** – Automatically clean up unused ViewModels or services.
- 🧩 **Scoped Injection** – Manage multiple scopes (like pages or flows) easily.
- 📦 **Tagged Instances** – Handle multiple instances of the same type using tags.
- 📉 **No BuildContext required** – Inject and observe state anywhere.

---

## 📦 Installation

Add the following line to your `pubspec.yaml`:

yaml
dependencies:
  minix: ^0.0.1


## 🧠 State Management
✅ Define an observable:

    
final counter = Observable(0);

## 🖼 Wrap your widget with Observer:

    Observer(() => Text('Count: ${counter.value}')),

## 🔁 Update observable:

counter.value++;

## 🧪 Dependency Injection
Register:

Injector.put(MyController());

## Access:

final controller = Injector.find<MyController>();

## Auto Dispose (calls onDispose() automatically):

Injector.autoDisposePut(MyService());

## Scoped:

Injector.putScoped(MyController(), 'login');
Injector.disposeScope('login');

## Tagged:

Injector.putTagged(MyController(), 'admin');
final adminController = Injector.findTagged<MyController>('admin');

## 📊 Debugging

Enable logging to track DI events:

Injector.enableLogs = true;

Print all current instances:

Injector.debugPrintDependencies();

## 🧼 Lifecycle Support

To use lifecycle callbacks, extend your class from Injectable:

class MyController extends Injectable {
@override
void onInit() {
print("Initialized!");
}

@override
void onDispose() {
print("Disposed!");
}
}

## 🔐 Null Safety & Zero Context

Minix works with full null safety and without requiring BuildContext for any logic or DI.
