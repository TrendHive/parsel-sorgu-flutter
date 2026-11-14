import 'package:parcel_atlas/core/base/base_read_model.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain/person/entity/person_group_entity.dart';
import 'package:parcel_atlas/domain/person/value_object/share_value_object.dart';

/// One parcel on a holder's list: the [drawing], the registry parcel it
/// corrects ([official], for where it is), the [share] held, and the group
/// it comes through ([viaGroup]) when it is not held directly.
///
/// [area] is the drawn parcel's exact area; [ownedArea] the part the share
/// stands for.
final class HoldingLineReadModel extends BaseReadModel {
  const HoldingLineReadModel({
    required this.drawing,
    required this.official,
    required this.share,
    required this.viaGroup,
  });

  final DrawnParcelEntity drawing;

  final OfficialParcelEntity? official;

  final ShareValueObject share;

  final PersonGroupEntity? viaGroup;

  double get area => drawing.outline.areaSquareMeters;

  double get ownedArea => area * share.fraction;

  @override
  List<Object?> get props => <Object?>[
    drawing.id,
    drawing.updated.at,
    share,
    viaGroup?.id,
  ];
}
