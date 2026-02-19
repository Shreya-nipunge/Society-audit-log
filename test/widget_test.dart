import 'package:flutter_test/flutter_test.dart';

import 'package:society_audit_log/main.dart';

void main() {
  testWidgets('App loads splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SocietyAuditLogApp());
    expect(find.text('Society Audit Log'), findsOneWidget);
  });
}
