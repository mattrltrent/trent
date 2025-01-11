class Result<T> {
  final T? _ok;
  final String? _err;

  Result.ok(T ok)
      : _ok = ok,
        _err = null;

  Result.err(String err)
      : _ok = null,
        _err = err;

  bool get isOk => _ok != null;
  bool get isErr => _err != null;

  @override
  String toString() {
    if (_ok != null) {
      return 'Result.ok($_ok)';
    } else {
      return 'Result.err($_err)';
    }
  }

  T get unwrap {
    if (_ok != null) {
      return _ok;
    }
    throw Exception('tried to unwrap a Result that is an error: $_err');
  }

  String get unwrapErr {
    if (_err != null) {
      return _err;
    }
    throw Exception('tried to unwrapErr on a Result that is ok');
  }

  R match<R>({required R Function(T) ok, required R Function(String) err, void Function()? always}) {
    if (always != null) {
      always();
    }
    if (_ok != null) {
      return ok(_ok);
    } else {
      return err(_err!);
    }
  }
}

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

// just true or false with an error message
class Attempt {
  final bool _success;
  final String _err;

  Attempt.success()
      : _success = true,
        _err = "";
  Attempt.failure(this._err) : _success = false;

  // when printed method
  @override
  String toString() {
    return _success ? "attempt=success" : "attempt=failure, error=$_err";
  }

  bool get wasSuccess => _success;
  bool get wasFailure => !_success;
  String? get error => _err;

  // match
  R match<R>({required R Function() ok, required R Function(String) fail}) {
    if (_success) {
      return ok();
    } else {
      return fail(_err);
    }
  }
}
