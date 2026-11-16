import 'dart:math' as math;

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parcel_atlas/application/drawing/usecase/redivide_drawings_usecase.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/exception/validation_exception.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/auth/enum/member_role_enum.dart';
import 'package:parcel_atlas/domain/auth/interface/auth_repository_interface.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/drawing/interface/drawn_parcel_repository_interface.dart';
import 'package:parcel_atlas/domain/drawing/read_model/map_redivide_read_model.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/map/rule/geo_rules.dart';
import 'package:parcel_atlas/domain/map/value_object/geo_polygon_value_object.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';

import '../support/fakes.dart';

class _Auth extends Mock implements AuthRepositoryInterface {}

class _Drawings extends Mock implements DrawnParcelRepositoryInterface {}

void main() {
  const MemberEntity member = MemberEntity(
    id: 'uid',
    name: 'Tester',
    username: 'tester',
    role: MemberRoleEnum.admin,
  );
  const LatLng origin = LatLng(40.5, 41);
  List<LatLng> metres(List<(double, double)> points) =>
      GeoRules.fromLocalPlane(<math.Point<double>>[
        for (final (double x, double y) in points) math.Point<double>(x, y),
      ], origin);

  late _Auth auth;
  late _Drawings drawings;
  late RedivideDrawingsUseCase redivide;
  final OfficialParcelEntity deedA = testOfficial(
    '1',
    corners: metres(<(double, double)>[(0, 0), (15, 0), (15, 20), (0, 20)]),
  );
  final OfficialParcelEntity deedB = testOfficial(
    '2',
    corners: metres(<(double, double)>[(15, 0), (30, 0), (30, 20), (15, 20)]),
  );
  final DrawnParcelEntity a = testDrawing(
    'a',
    const <OwnershipValueObject>[],
    corners: metres(<(double, double)>[(0, 0), (10, 0), (10, 20), (0, 20)]),
    officialParcelId: deedA.id,
  );
  final DrawnParcelEntity b = testDrawing(
    'b',
    const <OwnershipValueObject>[],
    corners: metres(<(double, double)>[(10, 0), (30, 0), (30, 20), (10, 20)]),
    officialParcelId: deedB.id,
  );

  setUpAll(() => registerFallbackValue(member));

  setUp(() {
    auth = _Auth();
    drawings = _Drawings();
    redivide = RedivideDrawingsUseCase(auth, drawings);
    when(() => auth.currentMember).thenReturn(member);
    when(() => drawings.reshape(any(), actor: any(named: 'actor')))
        .thenAnswer((_) async => const Right('a'));
  });

  test('a ready re-division reshapes both neighbours in one write', () async {
    final MapRedivideReadModel ready = MapRedivideReadModel.between(
      first: a,
      second: b,
      snapshot: MapSnapshotReadModel(
        officials: <OfficialParcelEntity>[deedA, deedB],
        drawings: <DrawnParcelEntity>[a, b],
        persons: testFamily,
      ),
    );

    expect(await redivide(ready), const Right<BaseException, String>('a'));

    final List<({DrawnParcelEntity drawing, GeoPolygonValueObject outline})>
    changes =
        verify(() => drawings.reshape(captureAny(), actor: member))
                .captured
                .single
            as List<
              ({DrawnParcelEntity drawing, GeoPolygonValueObject outline})
            >;
    expect(changes.map((c) => c.drawing.id), <String>['a', 'b']);
    expect(changes.first.outline.areaSquareMeters, closeTo(300, 1));
    expect(changes.last.outline.areaSquareMeters, closeTo(300, 1));
  });

  test(
    'a re-division still waiting for the neighbour writes nothing',
    () async {
      final Either<BaseException, String> result = await redivide(
        MapRedivideReadModel.start(a),
      );

      expect(result.left, isA<ValidationException>());
      verifyNever(() => drawings.reshape(any(), actor: any(named: 'actor')));
    },
  );
}
