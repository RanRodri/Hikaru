import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hikaru/features/listening_room/presentation/listening_room_quiz_screen.dart';

Future<void> tapQuizChoice(WidgetTester tester, String label) async {
  final scrollable = find.descendant(
    of: find.byType(ListeningRoomQuizScreen),
    matching: find.byType(Scrollable),
  );
  final finder = find.text(label).hitTestable();
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(finder, 48, scrollable: scrollable);
  }
  await tester.tap(finder);
  await tester.pump();
}

Future<void> tapQuizNext(WidgetTester tester) async {
  await tester.ensureVisible(find.text('NEXT'));
  await tester.tap(find.text('NEXT'));
  await tester.pumpAndSettle();
}
