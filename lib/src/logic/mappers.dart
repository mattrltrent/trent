import 'package:flutter/widgets.dart';

/// A utility class for mapping subtype handlers to a base type.
class LogicSubTypeMapper<Base> {
  final Base _state;
  final Map<Type, void Function(Base state)> _handlers = {};
  void Function(Base state)? _allHandler;

  LogicSubTypeMapper(this._state);

  /// Register a handler for a specific subtype and execute immediately.
  void as<T extends Base>(void Function(T state) handler) {
    if (_state is T) {
      handler(_state);
      return;
    }
    _handlers[T] = (state) => handler(state as T);
  }

  /// Register a catch-all handler and execute immediately if no other matches.
  void orElse(void Function(Base state) handler) {
    _allHandler ??= handler;
    if (!_handlers.containsKey(_state.runtimeType)) {
      _allHandler!(_state);
    }
  }
}

/// A utility class for mapping subtype handlers to a base type.
class WidgetSubtypeMapper<Base> {
  final Base _state;
  final Map<Type, Widget Function(Base state)> _widgetBuilders = {};
  Widget Function(Base state)? _defaultBuilder;

  WidgetSubtypeMapper(this._state);

  /// Register a handler for a specific subtype.
  void as<T extends Base>(Widget Function(T state) builder) {
    _widgetBuilders[T] = (state) => builder(state as T);
  }

  /// Register a default handler to use when no specific handler matches.
  void orElse(Widget Function(Base state) builder) {
    _defaultBuilder = builder;
  }

  /// Resolve the widget for the current state.
  Widget resolve() {
    final builder = _widgetBuilders[_state.runtimeType];
    return builder?.call(_state) ??
        _defaultBuilder?.call(_state) ??
        const SizedBox.shrink();
  }
}
