import 'package:flutter_test/flutter_test.dart';
import 'package:pmath/services/supabase_gateway.dart';

void main() {
  test('telefon sessiyasi bulutni ochadi', () {
    expect(cloudReadyFromToken('phone-session'), isTrue);
  });

  test('bo‘sh token bulutni ochmaydi', () {
    expect(cloudReadyFromToken(null), isFalse);
    expect(cloudReadyFromToken('   '), isFalse);
  });
}
