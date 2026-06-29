import 'package:flutter_test/flutter_test.dart';
import 'package:flowwise/main.dart';
import 'package:flowwise/data/repositories/memory_movement_repository.dart';
import 'package:flowwise/domain/financialCore/engine/financial_engine_v1.dart';
import 'package:flowwise/state/financial_state_notifier.dart';

void main() {
  testWidgets('FlowWise smoke test', (WidgetTester tester) async {
    final repository = MemoryMovementRepository();
    final engine = FinancialEngineV1(movementRepository: repository);
    final notifier = FinancialStateNotifier(engine: engine);

    await tester.pumpWidget(
      FlowWiseApp(financialNotifier: notifier),
    );
  });
}
