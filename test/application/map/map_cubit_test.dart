import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parcel_atlas/application/drawing/usecase/delete_drawing_usecase.dart';
import 'package:parcel_atlas/application/drawing/usecase/save_drawing_usecase.dart';
import 'package:parcel_atlas/application/map/cubit/map_cubit.dart';
import 'package:parcel_atlas/application/map/usecase/locate_device_usecase.dart';
import 'package:parcel_atlas/application/map/usecase/watch_map_usecase.dart';
import 'package:parcel_atlas/application/parcel/usecase/query_parcel_at_usecase.dart';
import 'package:parcel_atlas/application/parcel/usecase/refresh_parcel_usecase.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/cause/registry_refuses_web_cause.dart';
import 'package:parcel_atlas/core/exception/quota_exceeded_exception.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/auth/enum/member_role_enum.dart';
import 'package:parcel_atlas/domain/auth/interface/auth_repository_interface.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/drawing/interface/drawn_parcel_repository_interface.dart';
import 'package:parcel_atlas/domain/map/interface/device_location_interface.dart';
import 'package:parcel_atlas/domain/map/read_model/map_hit_read_model.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain/parcel/interface/official_parcel_repository_interface.dart';
import 'package:parcel_atlas/domain/parcel/interface/parcel_registry_interface.dart';
import 'package:parcel_atlas/domain/parcel/value_object/registry_record_value_object.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/interface/person_repository_interface.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';
import 'package:parcel_atlas/infrastructure/parcel/dto/tkgm_parcel_dto.dart';
import 'package:parcel_atlas/infrastructure/parcel/mapper/tkgm_parcel_mapper.dart';

import '../../support/fakes.dart';

class _Auth extends Mock implements AuthRepositoryInterface {}

class _Registry extends Mock implements ParcelRegistryInterface {}

class _Officials extends Mock implements OfficialParcelRepositoryInterface {}

class _Drawings extends Mock implements DrawnParcelRepositoryInterface {}

class _Persons extends Mock implements PersonRepositoryInterface {}

class _Location extends Mock implements DeviceLocationInterface {}

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
  const LatLng openGround = LatLng(40.55885, 41.00088);
  const LatLng insideDrawing = LatLng(40.00005, 41.00005);

  late _Auth auth;
  late _Registry registry;
  late _Officials officials;
  late _Drawings drawings;
  late _Persons persons;
  late StreamController<Either<BaseException, List<OfficialParcelEntity>>>
  officialStream;
  late MapCubit cubit;

  setUpAll(() {
    registerFallbackValue(openGround);
    registerFallbackValue(record);
    registerFallbackValue(member);
  });

  setUp(() async {
    auth = _Auth();
    registry = _Registry();
    officials = _Officials();
    drawings = _Drawings();
    persons = _Persons();
    officialStream = StreamController();
    when(() => auth.currentMember).thenReturn(member);
    when(() => officials.watchAll()).thenAnswer((_) => officialStream.stream);
    when(() => drawings.watchAll()).thenAnswer(
      (_) => Stream.value(
        Right(<DrawnParcelEntity>[
          testDrawing('drawn', const <OwnershipValueObject>[]),
        ]),
      ),
    );
    when(() => persons.watchAll())
        .thenAnswer((_) => Stream.value(const Right(<PersonEntity>[])));
    cubit = MapCubit(
      WatchMapUseCase(officials, drawings, persons),
      QueryParcelAtUseCase(auth, registry, officials),
      RefreshParcelUseCase(auth, registry, officials),
      SaveDrawingUseCase(auth, drawings),
      DeleteDrawingUseCase(auth, drawings),
      LocateDeviceUseCase(_Location()),
      auth,
    )..start();
    officialStream.add(const Right(<OfficialParcelEntity>[]));
    await pumpEventQueue();
  });

  tearDown(() async {
    await cubit.close();
    await officialStream.close();
  });

  test('one tap on ground nobody looked up queries the registry', () async {
    when(() => registry.fetchAt(any())).thenAnswer((_) async => Right(record));
    when(
      () => officials.saveRecord(
        any(),
        actor: any(named: 'actor'),
        isRefresh: any(named: 'isRefresh'),
      ),
    ).thenAnswer((_) async => Right(record.key));

    cubit.tap(openGround, metersPerPixel: 1);
    await pumpEventQueue();

    verify(() => registry.fetchAt(openGround)).called(1);
    verify(() => officials.saveRecord(record, actor: member, isRefresh: false))
        .called(1);
  });

  test(
    'a tap inside a stored drawing selects it without the registry',
    () async {
      cubit.tap(insideDrawing, metersPerPixel: 1);
      await pumpEventQueue();

      expect((cubit.state as MapReady).selection, isA<MapHitDrawn>());
      verifyNever(() => registry.fetchAt(any()));
    },
  );

  test('a refused lookup is reported and leaves the map usable', () async {
    when(() => registry.fetchAt(any())).thenAnswer(
      (_) async =>
          Left(QuotaExceededException(cause: RegistryRefusesWebCause())),
    );

    cubit.tap(openGround, metersPerPixel: 1);
    await pumpEventQueue();

    final MapReady state = cubit.state as MapReady;
    expect(state.exception, isA<QuotaExceededException>());
    expect(state.querying, isFalse);
  });

  test('while drawing, a tap adds a corner instead of querying', () async {
    cubit
      ..startDrawing()
      ..tap(openGround, metersPerPixel: 1);
    await pumpEventQueue();

    expect((cubit.state as MapReady).drawing!.draft.corners, <LatLng>[
      openGround,
    ]);
    verifyNever(() => registry.fetchAt(any()));
  });
}
