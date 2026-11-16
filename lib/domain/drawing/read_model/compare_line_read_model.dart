import 'package:parcel_atlas/core/base/base_read_model.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';

/// One parcel in a comparison: its real boundary ([drawing]) and the
/// registry parcel it belongs to ([official]) — either may be missing.
///
/// [realArea] is the drawing's exact area, or null when nobody drew it.
/// [registryArea] is the part of the deed area that falls to this drawing:
/// the registry's figure, divided among the parcel's real boundaries in
/// proportion to their areas when it was split; null without a registry
/// parcel.
final class CompareLineReadModel extends BaseReadModel {
  const CompareLineReadModel({
    required this.drawing,
    required this.official,
    required this.realArea,
    required this.registryArea,
  });

  final DrawnParcelEntity? drawing;

  final OfficialParcelEntity? official;

  final double? realArea;

  final double? registryArea;

  double? get difference => realArea == null || registryArea == null
      ? null
      : realArea! - registryArea!;

  @override
  List<Object?> get props => <Object?>[
    drawing?.id,
    drawing?.updated.at,
    official?.id,
    realArea,
    registryArea,
  ];
}
