import 'package:flutter_test/flutter_test.dart';
import 'package:parcel_atlas/core/cause/code/cause_code.dart';
import 'package:parcel_atlas/domain/drawing/value_object/drawing_details_value_object.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';
import 'package:parcel_atlas/domain/person/value_object/share_value_object.dart';

void main() {
  DrawingDetailsValueObject details(
    String name,
    List<OwnershipValueObject> owners,
  ) => DrawingDetailsValueObject((
    name: name,
    officialParcelId: null,
    owners: owners,
    note: '',
  ));

  OwnershipValueObject line(String id, int n, int d) =>
      OwnershipValueObject(personId: id, share: ShareValueObject(n, d));

  test('a drawing without a name cannot be saved', () {
    expect(
      details(
        '  ',
        const <OwnershipValueObject>[],
      ).valueObject.left.cause?.errorCode?.code,
      CauseCode.emptyValueCode,
    );
  });

  test('shares that add up to more than the parcel are refused', () {
    expect(
      details('x', <OwnershipValueObject>[
        line('a', 3, 4),
        line('b', 1, 2),
      ]).valueObject.left.cause?.errorCode?.code,
      CauseCode.sharesExceedWholeCode,
    );
  });

  test('shares below or equal to the whole are accepted', () {
    expect(
      details('x', <OwnershipValueObject>[
        line('a', 1, 2),
        line('b', 1, 4),
      ]).isValid,
      isTrue,
    );
    expect(
      details('x', <OwnershipValueObject>[line('a', 1, 1)]).isValid,
      isTrue,
    );
  });
}
