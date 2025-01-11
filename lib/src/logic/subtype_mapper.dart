class SubtypeMapper<Base> {
  final Base _state;
  final Map<Type, void Function(Base state)> _handlers = {};
  void Function(Base state)? _allHandler;

  SubtypeMapper(this._state);

  /// Register a handler for a specific subtype and execute immediately
  void as<T extends Base>(void Function(T state) handler) {
    if (_state is T) {
      handler(_state);
      return;
    }
    _handlers[T] = (state) => handler(state as T);
  }

  /// Register a catch-all handler and execute immediately if no other matches
  void all(void Function(Base state) handler) {
    _allHandler ??= handler;
    if (!_handlers.containsKey(_state.runtimeType)) {
      _allHandler!(_state);
    }
  }
}
