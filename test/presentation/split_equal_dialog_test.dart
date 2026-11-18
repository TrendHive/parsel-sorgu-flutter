import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/map/rule/geo_rules.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';
import 'package:parcel_atlas/domain/person/value_object/share_value_object.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/presentation/map/dialog/split_equal_dialog.dart';

import '../support/fakes.dart';

void main() {
  testWidgets('an equal split answers the direction the member turned to', (
    WidgetTester tester,
  ) async {
    final DrawnParcelEntity drawing = testDrawing(
      'Tarla',
      const <OwnershipValueObject>[
        OwnershipValueObject(personId: 'father', share: ShareValueObject.whole),
      ],
    );
    final MapSnapshotReadModel snapshot = MapSnapshotReadModel(
      officials: const <OfficialParcelEntity>[],
      drawings: <DrawnParcelEntity>[drawing],
      persons: testFamily,
    );
    ({int pieces, List<PersonEntity>? heirs, double bearingDegrees})? answer;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: ParcelInfoLocalKeys.localizationsDelegates,
        supportedLocales: ParcelInfoLocalKeys.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () async => answer = await SplitEqualDialog.open(
              context,
              drawing: drawing,
              snapshot: snapshot,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final double start =
        GeoRules.suggestedCutBearing(drawing.outline.corners).roundToDouble() %
        GeoRules.halfTurnDegrees;

    await tester.tap(find.byIcon(Icons.rotate_right));
    await tester.tap(find.byIcon(Icons.rotate_right));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Split equally'));
    await tester.pumpAndSettle();

    expect(answer?.pieces, 4);
    expect(answer?.heirs?.map((PersonEntity p) => p.id), <String>[
      'a',
      'b',
      'c',
      'd',
    ]);
    expect(answer?.bearingDegrees, (start + 2) % GeoRules.halfTurnDegrees);
  });
}
