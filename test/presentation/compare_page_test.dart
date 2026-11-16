import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parcel_atlas/application/drawing/cubit/compare_cubit.dart';
import 'package:parcel_atlas/application/map/usecase/watch_map_usecase.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/drawing/interface/drawn_parcel_repository_interface.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain/parcel/interface/official_parcel_repository_interface.dart';
import 'package:parcel_atlas/domain/person/interface/person_repository_interface.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';
import 'package:parcel_atlas/domain/person/value_object/share_value_object.dart';
import 'package:parcel_atlas/presentation/compare/body/compare_body.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';

import '../support/fakes.dart';

class _Officials extends Mock implements OfficialParcelRepositoryInterface {}

class _Drawings extends Mock implements DrawnParcelRepositoryInterface {}

class _Persons extends Mock implements PersonRepositoryInterface {}

void main() {
  testWidgets('the comparison page lists owners and parcels on a phone', (
    WidgetTester tester,
  ) async {
    tester.view
      ..physicalSize = const Size(360, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final OfficialParcelEntity deed = testOfficial('1');
    final _Officials officials = _Officials();
    final _Drawings drawings = _Drawings();
    final _Persons persons = _Persons();
    when(() => officials.watchAll())
        .thenAnswer((_) => Stream.value(Right(<OfficialParcelEntity>[deed])));
    when(() => drawings.watchAll()).thenAnswer(
      (_) => Stream.value(
        Right(<DrawnParcelEntity>[
          testDrawing('Tarla', const <OwnershipValueObject>[
            OwnershipValueObject(
              personId: 'father',
              share: ShareValueObject.whole,
            ),
          ], officialParcelId: deed.id),
        ]),
      ),
    );
    when(() => persons.watchAll())
        .thenAnswer((_) => Stream.value(Right(testFamily)));

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: ParcelInfoLocalKeys.localizationsDelegates,
        supportedLocales: ParcelInfoLocalKeys.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: BlocProvider<CompareCubit>(
            create: (_) =>
                CompareCubit(WatchMapUseCase(officials, drawings, persons))
                  ..start(ids: <String>[deed.id]),
            child: const CompareBody(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('father'), findsOneWidget);
    expect(find.text('Tarla'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
