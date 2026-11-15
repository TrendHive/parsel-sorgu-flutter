import 'package:flutter_test/flutter_test.dart';
import 'package:parcel_atlas/domain/person/value_object/share_value_object.dart';

void main() {
  test('three thirds add up to exactly the whole parcel', () {
    final ShareValueObject third = ShareValueObject(1, 3);
    expect(third.plus(third).plus(third).isWhole, isTrue);
  });

  test('a share is stored reduced, as a deed writes it', () {
    final ShareValueObject share = ShareValueObject(2, 8);
    expect((share.numerator, share.denominator), (1, 4));
  });

  test("a father's 1/1 split among four siblings is 1/4 each", () {
    final ShareValueObject each = ShareValueObject.whole.dividedBy(4);
    expect((each.numerator, each.denominator), (1, 4));
  });

  test('typed shares parse, and nonsense or more than the whole does not', () {
    expect(ShareValueObject.tryParse('1/4'), ShareValueObject(1, 4));
    expect(ShareValueObject.tryParse(' 3 / 8 '), ShareValueObject(3, 8));
    expect(ShareValueObject.tryParse('1'), ShareValueObject.whole);
    expect(ShareValueObject.tryParse('5/4'), isNull);
    expect(ShareValueObject.tryParse('0/4'), isNull);
    expect(ShareValueObject.tryParse('a/b'), isNull);
    expect(ShareValueObject.tryParse('1/0'), isNull);
  });
}
