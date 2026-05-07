import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lifely/app/lifely_app.dart';

void main() {
  testWidgets('App starts without error', (WidgetTester tester) async {
    await tester.pumpWidget(const LifelyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
