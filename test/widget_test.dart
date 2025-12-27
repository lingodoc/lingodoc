import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lingodoc/app.dart';

void main() {
  testWidgets('LingoDoc app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: LingoDocApp()));

    // Verify that LingoDoc title appears.
    expect(find.text('LingoDoc'), findsWidgets);
    expect(find.text('Multilingual Documentation Editor'), findsOneWidget);
    expect(find.text('Open Project'), findsOneWidget);
  });
}
