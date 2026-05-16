import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keep_notes/presentation/views/widgets/empty_notes_view.dart';

void main() {
  testWidgets('EmptyNotesView shows empty state message', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: EmptyNotesView()),
    );

    expect(find.text('No notes yet'), findsOneWidget);
    expect(find.text('Tap + to create your first note'), findsOneWidget);
  });
}
