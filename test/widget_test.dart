import 'package:flutter_test/flutter_test.dart';
import 'package:palette_pro/main.dart';

void main() {
  testWidgets('PalettePro App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PaletteProApp());

    // Verify that our app bar shows the correct title.
    expect(find.text('臻图坊 • PALETTEPRO'), findsOneWidget);

    // Verify that the initial placeholder canvas exists.
    expect(find.text('臻图坊'), findsOneWidget);
  });
}
