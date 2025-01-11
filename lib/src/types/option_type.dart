class Option<T> {
  final T? _some;
  final bool _isNone;

  Option.some(this._some) : _isNone = false {
    if (_some == null) {
      throw Exception('tried to create an Option.some with a null value');
    }
  }
  Option.none()
      : _some = null,
        _isNone = true;

  bool get isSome => _some != null;
  bool get isNone => _isNone;

  T get unwrap {
    if (_some != null) {
      return _some;
    }
    throw Exception('tried to unwrap an Option that is none');
  }

  R match<R>({required R Function(T) some, required R Function() none}) {
    if (isSome) {
      return some(_some as T);
    } else {
      return none();
    }
  }
}
