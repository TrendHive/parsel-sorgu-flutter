import 'package:parcel_atlas/core/base/base_read_model.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';

/// How a drawn boundary compares with the registry parcel it corrects.
///
/// [drawnArea] is computed from the drawing's exact corners.
/// [registryArea] is the registry's own figure, the one on the title deed.
/// [difference] is drawn minus registry (positive: the real parcel is
/// larger), and [differencePercent] the same relative to the registry.
/// When the registry gives no figure, the area of its outline stands in.
final class ParcelComparisonReadModel extends BaseReadModel {
  const ParcelComparisonReadModel({
    required this.drawnArea,
    required this.registryArea,
  });

  factory ParcelComparisonReadModel.of(
    DrawnParcelEntity drawing,
    OfficialParcelEntity official,
  ) => ParcelComparisonReadModel(
    drawnArea: drawing.outline.areaSquareMeters,
    registryArea:
        official.record.registryAreaSquareMeters ??
        official.record.outline.areaSquareMeters,
  );

  final double drawnArea;

  final double registryArea;

  double get difference => drawnArea - registryArea;

  double get differencePercent => registryArea == CoreConstants.zeroDouble
      ? CoreConstants.zeroDouble
      : difference / registryArea * _percent;

  static const double _percent = 100;

  @override
  List<Object?> get props => <Object?>[drawnArea, registryArea];
}
