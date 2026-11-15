import 'package:parcel_atlas/core/base/base_read_model.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/value_object/share_value_object.dart';

/// One parcel on a holder's list: the [drawing], the registry parcel it
/// corrects ([official], for where it is), the [share] that reaches the
/// holder, and the ancestor it comes from ([via]) when it is inherited.
///
/// [passedOn] marks a share that has gone on to the holder's children: it
/// is listed for the record, but is no longer the holder's own.
///
/// [area] is the drawn parcel's exact area; [ownedArea] the part the share
/// stands for.
final class HoldingLineReadModel extends BaseReadModel {
  const HoldingLineReadModel({
    required this.drawing,
    required this.official,
    required this.share,
    required this.via,
    required this.passedOn,
  });

  final DrawnParcelEntity drawing;

  final OfficialParcelEntity? official;

  final ShareValueObject share;

  final PersonEntity? via;

  final bool passedOn;

  double get area => drawing.outline.areaSquareMeters;

  double get ownedArea => area * share.fraction;

  @override
  List<Object?> get props => <Object?>[
    drawing.id,
    drawing.updated.at,
    share,
    via?.id,
    passedOn,
  ];
}
