import 'package:flutter/widgets.dart';

import 'app_state.dart';

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState appState,
    required super.child,
  }) : super(notifier: appState);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope was not found in the widget tree.');
    return scope!.notifier!;
  }

  static AppState read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<AppStateScope>();
    final scope = element?.widget as AppStateScope?;
    assert(scope != null, 'AppStateScope was not found in the widget tree.');
    return scope!.notifier!;
  }
}
