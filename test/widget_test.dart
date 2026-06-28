import 'package:flutter_test/flutter_test.dart';
import 'package:flowwise/main.dart';

void main() {
  testWidgets('FlowWise smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FlowWiseApp());
  });
}
