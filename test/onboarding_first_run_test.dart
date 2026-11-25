import 'package:cooknote/src/data/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  testWidgets('lần mở đầu hiện màn chào, bỏ qua thì vào Công thức (AC-59)', (
    tester,
  ) async {
    final app = await pumpApp(tester, showOnboarding: true);
    expect(find.text('Bỏ qua'), findsOneWidget);

    await tester.tap(find.text('Bỏ qua'));
    await settle(tester);
    expect(find.text('Bỏ qua'), findsNothing);
    expect(find.text('Công thức'), findsWidgets);

    final seen = await tester.runAsync(
      () => SettingsRepository(app.db).watchOnboardingSeen().first,
    );
    expect(seen, isTrue);
  });

  testWidgets('đã xem màn chào thì mở app vào thẳng Công thức', (tester) async {
    await pumpApp(tester);
    expect(find.text('Bỏ qua'), findsNothing);
  });
}
