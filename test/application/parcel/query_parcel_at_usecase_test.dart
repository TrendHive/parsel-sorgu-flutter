import 'dart:convert';
import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parcel_atlas/application/parcel/usecase/query_parcel_at_usecase.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/domain/activity/value_object/audit_stamp_value_object.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/auth/enum/member_role_enum.dart';
import 'package:parcel_atlas/domain/auth/interface/auth_repository_interface.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain/parcel/interface/official_parcel_repository_interface.dart';
import 'package:parcel_atlas/domain/parcel/interface/parcel_registry_interface.dart';
import 'package:parcel_atlas/domain/parcel/value_object/registry_record_value_object.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/infrastructure/parcel/dto/tkgm_parcel_dto.dart';
import 'package:parcel_atlas/infrastructure/parcel/mapper/tkgm_parcel_mapper.dart';

class _Auth extends Mock implements AuthRepositoryInterface {}

class _Registry extends Mock implements ParcelRegistryInterface {}

class _Parcels extends Mock implements OfficialParcelRepositoryInterface {}

void main() {
  const MemberEntity member = MemberEntity(
    id: 'uid',
    name: 'Tester',
    username: 'tester',
    role: MemberRoleEnum.admin,
  );
  final RegistryRecordValueObject record = const TkgmParcelMapper()
      .toRecord(
        TkgmParcelDTO.fromJson(
          jsonDecode(
            File('test/support/fixtures/tkgm_parcel_duzkoy_114_1.json')
                .readAsStringSync(),
          ) as Map<String, dynamic>,
        ),
      )
      .right;
  final AuditStampValueObject stamp = AuditStampValueObject(
    memberId: 'uid',
    memberName: 'Tester',
    at: DateTime(2026),
  );
  const LatLng inside = LatLng(40.55885, 41.00088);

  late _Auth auth;
  late _Registry registry;
  late _Parcels parcels;
  late QueryParcelAtUseCase query;

  setUpAll(() {
    registerFallbackValue(record);
    registerFallbackValue(inside);
    registerFallbackValue(member);
  });

  setUp(() {
    auth = _Auth();
    registry = _Registry();
    parcels = _Parcels();
    when(() => auth.currentMember).thenReturn(member);
    query = QueryParcelAtUseCase(auth, registry, parcels);
  });

  MapSnapshotReadModel snapshotWith(List<OfficialParcelEntity> officials) =>
      MapSnapshotReadModel(
        officials: officials,
        drawings: const <DrawnParcelEntity>[],
        persons: const <PersonEntity>[],
      );

  test('a tap inside a stored parcel never spends a registry lookup', () async {
    final Either<BaseException, String> result = await query(
      inside,
      snapshotWith(<OfficialParcelEntity>[
        OfficialParcelEntity(record: record, created: stamp, refreshed: stamp),
      ]),
    );
    expect(result.right, record.key);
    verifyNever(() => registry.fetchAt(any()));
    verifyNever(
      () => parcels.saveRecord(
        any(),
        actor: any(named: 'actor'),
        isRefresh: any(named: 'isRefresh'),
      ),
    );
  });

  test('a tap on unknown ground asks the registry once and saves it', () async {
    when(() => registry.fetchAt(any())).thenAnswer((_) async => Right(record));
    when(
      () => parcels.saveRecord(
        any(),
        actor: any(named: 'actor'),
        isRefresh: any(named: 'isRefresh'),
      ),
    ).thenAnswer((_) async => Right(record.key));

    final Either<BaseException, String> result = await query(
      inside,
      snapshotWith(const <OfficialParcelEntity>[]),
    );

    expect(result.right, record.key);
    verify(() => registry.fetchAt(inside)).called(1);
    verify(() => parcels.saveRecord(record, actor: member, isRefresh: false))
        .called(1);
  });
}
