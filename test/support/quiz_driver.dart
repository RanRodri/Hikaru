import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hikaru/features/listening_room/presentation/listening_room_quiz_screen.dart';

Future<void> tapQuizChoice(WidgetTester tester, String label) async {
  final screen = find.byType(ListeningRoomQuizScreen);
  final scrollable = find.descendant(
    of: screen,
    matching: find.byType(Scrollable),
  );
  final labelFinder = find.descendant(of: screen, matching: find.text(label));
  expect(labelFinder, findsOneWidget, reason: 'Missing quiz choice "$label"');

  if (scrollable.evaluate().isNotEmpty) {
    await tester.scrollUntilVisible(labelFinder, 48, scrollable: scrollable);
    await tester.pumpAndSettle();
  }

  final tappable = labelFinder.hitTestable();
  expect(tappable, findsOneWidget, reason: 'Choice "$label" not tappable');
  await tester.tap(tappable);
  await tester.pump();
}

Future<void> tapQuizNext(WidgetTester tester) async {
  await tester.ensureVisible(find.text('NEXT'));
  await tester.tap(find.text('NEXT'));
  await tester.pumpAndSettle();
}
