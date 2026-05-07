import 'package:flutter/material.dart';

import 'app_store.dart';

class AppScope extends InheritedNotifier<AppStore> {
  const AppScope({
    super.key,
    required AppStore store,
    required Widget child,
  }) : super(notifier: store, child: child);

  static AppStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    if (scope == null) {
      throw FlutterError('AppScope not found in widget tree.');
    }
    return scope.notifier!;
  }
}
