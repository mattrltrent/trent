/// A type that represents a value that may or may not be present.
class Option<T> {
  final T? _some;
  final bool _isNone;

  /// Create an Option with a value.
  Option.some(this._some) : _isNone = false {
    if (_some == null) {
      throw Exception('tried to create an Option.some with a null value');
    }
  }

  /// Create an Option with no value.
  Option.none()
      : _some = null,
        _isNone = true;

  /// Check if the Option has a value.
  bool get isSome => _some != null;

  /// Check if the Option has no value.
  bool get isNone => _isNone;

  /// Get the value of the Option even if it could be None.
  ///
  /// Throws an exception if the Option is None.
  T get unwrap {
    if (_some != null) {
      return _some;
    }
    throw Exception('tried to unwrap an Option that is none');
  }

  /// Match over the Option.
  ///
  /// If the Option is Some, the [some] function is called with the value.
  /// If the Option is None, the [none] function is called.
  R match<R>({required R Function(T) some, required R Function() none}) {
    if (isSome) {
      return some(_some as T);
    } else {
      return none();
    }
  }
}
