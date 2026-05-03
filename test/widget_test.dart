import 'package:flutter_test/flutter_test.dart';

import 'package:admin/main.dart';

void main() {
  test('Admin app can be constructed for login route', () {
    const app = MyApp(initialAuthenticated: false);

    expect(app.initialAuthenticated, isFalse);
  });
}
