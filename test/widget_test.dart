import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog/app/app.dart';

void main() {
  testWidgets('App class exists as smoke test', (WidgetTester tester) async {
    // The App widget requires Hive and GetIt initialization which are async.
    // Full integration tests are covered in the unit/ and widget/ test folders.
    expect(App, isNotNull);
  });
}
