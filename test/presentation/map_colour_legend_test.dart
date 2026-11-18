import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_colour_legend.dart';

import '../support/fakes.dart';

void main() {
  const Size phone = Size(360, 800);

  Future<void> pump(WidgetTester tester, {required bool open}) async {
    tester.view
      ..physicalSize = phone
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: ParcelInfoLocalKeys.localizationsDelegates,
        supportedLocales: ParcelInfoLocalKeys.supportedLocales,
        locale: const Locale('en'),
        home: MediaQuery(
          data: const MediaQueryData(
            size: phone,
            textScaler: TextScaler.linear(3),
          ),
          child: Scaffold(
            body: Align(
              alignment: Alignment.bottomLeft,
              child: MapColourLegend(
                initiallyOpen: open,
                branches: <PersonEntity>[
                  for (int i = 0; i < 8; i++) testPerson('Owner number $i'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('with large text on a phone the colour key folds away instead of '
      'covering the map', (WidgetTester tester) async {
    await pump(tester, open: false);
    expect(
      tester.getSize(find.byType(MapColourLegend)).height,
      lessThan(phone.height * 0.15),
    );

    await tester.tap(find.byIcon(Icons.palette_outlined));
    await tester.pumpAndSettle();
    final Finder box = find.byWidgetPredicate(
      (Widget w) =>
          w is ConstrainedBox &&
          w.constraints.maxWidth == ParcelInfoDimens.legendMaxWidth,
    );
    expect(
      tester.getSize(box).height,
      lessThanOrEqualTo(phone.height * ParcelInfoDimens.legendMaxHeightFactor),
    );
    expect(tester.takeException(), isNull);
  });
}
