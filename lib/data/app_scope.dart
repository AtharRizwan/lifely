import 'package:flutter/material.dart';

import 'app_store.dart';

class AppScope extends InheritedNotifier<AppStore> {
  const AppScope({
    super.key,
    required AppStore store,
    required super.child,
  }) : super(notifier: store);

  static AppStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    if (scope == null) {
      throw FlutterError('AppScope not found in widget tree.');
    }
    return scope.notifier!;
  }

  /// Like [of] but without subscribing to changes, for use in callbacks.
  static AppStore read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    if (scope == null) {
      throw FlutterError('AppScope not found in widget tree.');
    }
    return scope.notifier!;
  }
}
