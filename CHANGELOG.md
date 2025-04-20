## 0.3.0

- Adds `cancelableAsyncOp` to `Trent` class, allowing for the cancellation of optional async operations via `void reset({bool cancelInFlightAsyncOps = true})` or `cancelInFlightAsyncOps`. This helps prevent state leaking across sessions.
- Adds documentation.

## 0.2.1

- Fixes broken import.

## 0.2.0

- Adds `Future<AsyncCompleted<T>> cancelableAsyncOp<T>(Future<T> Function() work)` wrapper function to `Trent` class, allowing for the cancellation of optional async operations via `void reset({bool cancelAsyncOps = true})`. This helps prevent state leaking across sessions.

## 0.1.1

- Updates `TrentManager`'s `trents` field to be optional.
- Updates `register` function to be callable outside the widget tree. This is useful if you want to start the lifecycle of your Trents *before* you execute `runApp`, such as in the `main` function.

## 0.1.0

- `get<T>(BuildContext)` -> `get<T>()`, removing the need to pass `BuildContext` to `get` method.
- README updates to update documentation.

## 0.0.7

- README updates. Specifically, adds link to blog post with more information on the package.

## 0.0.6

- README image sizing fixed.

## 0.0.5

- Improved documentation and examples in the README.

## 0.0.4

- Updates the `Alerter` widget to include an `Option` type for the previous alert state in its `listenAlertsIf` function, as it may be absent when there is no default alert, unlike the default state which is always present.

## 0.0.3

- README updates.

## 0.0.2

- Improves documentation.
- Adds example weather app.
- Fixes assorted errors.

## 0.0.1

- Initial release.
