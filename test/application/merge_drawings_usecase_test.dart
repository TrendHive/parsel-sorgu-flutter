import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parcel_atlas/application/drawing/usecase/merge_drawings_usecase.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/cause/code/cause_code.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/auth/enum/member_role_enum.dart';
import 'package:parcel_atlas/domain/auth/interface/auth_repository_interface.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/drawing/interface/drawn_parcel_repository_interface.dart';
import 'package:parcel_atlas/domain/drawing/read_model/map_merge_read_model.dart';
import 'package:parcel_atlas/domain/drawing/value_object/drawing_details_value_object.dart';
import 'package:parcel_atlas/domain/map/rule/geo_rules.dart';
import 'package:parcel_atlas/domain/map/value_object/geo_polygon_value_object.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/rule/family_rules.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';
import 'package:parcel_atlas/domain/person/value_object/share_value_object.dart';

import '../support/fakes.dart';

class _Auth extends Mock implements AuthRepositoryInterface {}

class _Drawings extends Mock implements DrawnParcelRepositoryInterface {}

void main() {
  const MemberEntity member = MemberEntity(
    id: 'uid',
    name: 'Tester',
    username: 'tester',
    role: MemberRoleEnum.member,
  );
  late _Auth auth;
  late _Drawings drawings;
  late MergeDrawingsUseCase merge;

  final List<String> sons = <String>['a', 'b', 'c', 'd'];
  final List<List<LatLng>> strips = GeoRules.splitEqual(
    testSquare,
    sons.length,
    bearingDegrees: 0,
  );
  final List<DrawnParcelEntity> pieces = <DrawnParcelEntity>[
    for (final (int i, String son) in sons.indexed)
      testDrawing('Tarla – $son', <OwnershipValueObject>[
        OwnershipValueObject(personId: son, share: ShareValueObject.whole),
      ], corners: strips[i]),
  ];

  setUpAll(() {
    registerFallbackValue(member);
    registerFallbackValue(pieces.first);
    registerFallbackValue(GeoPolygonValueObject.empty);
    registerFallbackValue(
      const DrawingDetailsValueObject((
        name: 'x',
        officialParcelId: null,
        owners: <OwnershipValueObject>[],
        note: '',
      )),
    );
  });

  setUp(() {
    auth = _Auth();
    drawings = _Drawings();
    merge = MergeDrawingsUseCase(auth, drawings);
    when(() => auth.currentMember).thenReturn(member);
    when(
      () => drawings.merge(
        any(),
        any(),
        any(),
        any(),
        actor: any(named: 'actor'),
      ),
    ).thenAnswer((_) async => const Right('Tarla – a'));
  });

  test("four brothers' pieces merge back into their father's field", () async {
    MapMergeReadModel chosen = MapMergeReadModel.start(pieces.first);
    for (final DrawnParcelEntity piece in pieces.skip(1)) {
      chosen = chosen.toggle(piece);
    }
    final PersonEntity? father = FamilyRules.commonAncestor(
      testFamily,
      chosen.ownerIds,
    );
    expect(father?.id, 'father');

    final Either<BaseException, String> result = await merge(
      chosen,
      owner: father,
    );

    expect(result.isRight, isTrue);
    final List<dynamic> captured = verify(
      () => drawings.merge(
        captureAny(),
        captureAny(),
        captureAny(),
        captureAny(),
        actor: member,
      ),
    ).captured;
    expect((captured[0] as DrawnParcelEntity).id, pieces.first.id);
    expect(
      (captured[1] as List<DrawnParcelEntity>).map(
        (DrawnParcelEntity d) => d.id,
      ),
      pieces.skip(1).map((DrawnParcelEntity d) => d.id),
    );
    expect(
      (captured[2] as GeoPolygonValueObject).areaSquareMeters,
      closeTo(GeoRules.areaSquareMeters(testSquare), 0.01),
    );
    final DrawingDetailsValueObject details =
        captured[3] as DrawingDetailsValueObject;
    expect(details.name, 'Tarla');
    expect(details.value.owners.single.personId, 'father');
  });

  test('pieces that do not touch are not merged', () async {
    final MapMergeReadModel apart = MapMergeReadModel.start(pieces.first)
        .toggle(pieces.last);
    expect(apart.canConfirm, isFalse);
    expect(
      (await merge(apart)).left.cause?.errorCode?.code,
      CauseCode.mergeMissesCode,
    );
  });
}
