import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parcel_atlas/application/drawing/usecase/save_drawing_usecase.dart';
import 'package:parcel_atlas/application/drawing/usecase/split_drawing_usecase.dart';
import 'package:parcel_atlas/application/parcel/usecase/query_parcel_by_number_usecase.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/cause/code/cause_code.dart';
import 'package:parcel_atlas/core/exception/network_exception.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/auth/enum/member_role_enum.dart';
import 'package:parcel_atlas/domain/auth/interface/auth_repository_interface.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/drawing/interface/drawn_parcel_repository_interface.dart';
import 'package:parcel_atlas/domain/drawing/value_object/drawing_details_value_object.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/map/rule/geo_rules.dart';
import 'package:parcel_atlas/domain/map/value_object/geo_polygon_value_object.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain/parcel/interface/official_parcel_repository_interface.dart';
import 'package:parcel_atlas/domain/parcel/interface/parcel_registry_interface.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';
import 'package:parcel_atlas/domain/person/value_object/share_value_object.dart';

import '../support/fakes.dart';

class _Auth extends Mock implements AuthRepositoryInterface {}

class _Drawings extends Mock implements DrawnParcelRepositoryInterface {}

class _Registry extends Mock implements ParcelRegistryInterface {}

class _Parcels extends Mock implements OfficialParcelRepositoryInterface {}

typedef _Piece = ({
  GeoPolygonValueObject outline,
  DrawingDetailsValueObject details,
});

void main() {
  const MemberEntity member = MemberEntity(
    id: 'uid',
    name: 'Tester',
    username: 'tester',
    role: MemberRoleEnum.member,
  );
  final DrawnParcelEntity field = testDrawing(
    'field',
    const <OwnershipValueObject>[
      OwnershipValueObject(personId: 'father', share: ShareValueObject.whole),
    ],
  );
  const DrawingDetailsValueObject details = DrawingDetailsValueObject((
    name: 'new',
    officialParcelId: null,
    owners: <OwnershipValueObject>[],
    note: '',
  ));

  late _Auth auth;
  late _Drawings drawings;

  setUpAll(() {
    registerFallbackValue(member);
    registerFallbackValue(field);
    registerFallbackValue(GeoPolygonValueObject.empty);
    registerFallbackValue(details);
  });

  setUp(() {
    auth = _Auth();
    drawings = _Drawings();
    when(() => auth.currentMember).thenReturn(member);
    when(() => drawings.split(any(), any(), actor: any(named: 'actor')))
        .thenAnswer((_) async => const Right('field'));
    when(() => drawings.create(any(), any(), actor: any(named: 'actor')))
        .thenAnswer((_) async => const Right('new'));
  });

  test(
    'a drawing laid over another is refused and nothing is stored',
    () async {
      final MapSnapshotReadModel snapshot = MapSnapshotReadModel(
        officials: const <OfficialParcelEntity>[],
        drawings: <DrawnParcelEntity>[field],
        persons: const <PersonEntity>[],
      );

      final Either<BaseException, String> result =
          await SaveDrawingUseCase(auth, drawings)(
            outline: const GeoPolygonValueObject(testSquare),
            details: details,
            snapshot: snapshot,
          );

      expect(result.left.cause?.errorCode?.code, CauseCode.drawingOverlapsCode);
      verifyNever(
        () => drawings.create(any(), any(), actor: any(named: 'actor')),
      );
    },
  );

  test('editing a drawing is not an overlap with itself', () async {
    when(() => drawings.update(any(), any(), any(), actor: any(named: 'actor')))
        .thenAnswer((_) async => const Right('field'));
    final MapSnapshotReadModel snapshot = MapSnapshotReadModel(
      officials: const <OfficialParcelEntity>[],
      drawings: <DrawnParcelEntity>[field],
      persons: const <PersonEntity>[],
    );

    final Either<BaseException, String> result =
        await SaveDrawingUseCase(auth, drawings)(
          outline: const GeoPolygonValueObject(testSquare),
          details: details,
          existing: field,
          snapshot: snapshot,
        );

    expect(result.isRight, isTrue);
  });

  test('an equal split gives each heir one piece as its only owner', () async {
    final List<PersonEntity> heirs = testFamily
        .where((PersonEntity p) => p.parentId == 'father')
        .toList();

    final Either<BaseException, String> result =
        await SplitDrawingUseCase(auth, drawings)(
          drawing: field,
          outlines: GeoRules.splitEqual(
            testSquare,
            heirs.length,
            bearingDegrees: 0,
          ),
          heirs: heirs,
        );

    expect(result.right, 'field');
    final List<_Piece> pieces =
        verify(
              () => drawings.split(
                any(),
                captureAny(),
                actor: any(named: 'actor'),
              ),
            ).captured.single
            as List<_Piece>;
    expect(pieces, hasLength(4));
    expect(pieces.map((_Piece p) => p.details.name), <String>[
      'field – a',
      'field – b',
      'field – c',
      'field – d',
    ]);
    expect(pieces.map((_Piece p) => p.details.owners.single.personId), <String>[
      'a',
      'b',
      'c',
      'd',
    ]);
  });

  test('a cut that leaves one piece is not a split', () async {
    final Either<BaseException, String> result = await SplitDrawingUseCase(
      auth,
      drawings,
    )(drawing: field, outlines: const <List<LatLng>>[testSquare]);

    expect(result.left.cause?.errorCode?.code, CauseCode.splitMissesCode);
    verifyNever(() => drawings.split(any(), any(), actor: any(named: 'actor')));
  });

  test('a parcel number nobody fetched asks the registry by number', () async {
    final _Registry registry = _Registry();
    when(
      () => registry.fetchByNumber(
        neighborhoodId: any(named: 'neighborhoodId'),
        block: any(named: 'block'),
        parcel: any(named: 'parcel'),
      ),
    ).thenAnswer((_) async => Left(NetworkException()));

    await QueryParcelByNumberUseCase(auth, registry, _Parcels())(
      neighborhoodId: 130241,
      block: ' 114 ',
      parcel: '2',
      snapshot: MapSnapshotReadModel.empty,
    );

    verify(
      () => registry.fetchByNumber(
        neighborhoodId: 130241,
        block: '114',
        parcel: '2',
      ),
    ).called(1);
  });
}
