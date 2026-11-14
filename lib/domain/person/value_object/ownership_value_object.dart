import 'package:parcel_atlas/core/base/base_value_object.dart';
import 'package:parcel_atlas/core/base/base_value_validator.dart';
import 'package:parcel_atlas/domain/person/enum/holder_kind_enum.dart';
import 'package:parcel_atlas/domain/person/value_object/share_value_object.dart';

/// One line of a parcel's ownership: who holds it ([kind] and [holderId])
/// and how much ([share]).
///
/// A group is stored as the group, not as its members at the time, so when
/// the group changes every parcel it holds follows — four siblings who
/// inherit everything together are kept in one place.
final class OwnershipValueObject
    extends
        BaseValueObject<
          ({HolderKindEnum kind, String holderId, ShareValueObject share})
        > {
  const OwnershipValueObject({
    required HolderKindEnum kind,
    required String holderId,
    required ShareValueObject share,
  }) : super((kind: kind, holderId: holderId, share: share));

  @override
  List<
    BaseValueValidator<
      ({HolderKindEnum kind, String holderId, ShareValueObject share})
    >
  >
  get validators =>
      const <
        BaseValueValidator<
          ({HolderKindEnum kind, String holderId, ShareValueObject share})
        >
      >[];

  HolderKindEnum get kind => value.kind;

  String get holderId => value.holderId;

  ShareValueObject get share => value.share;

  bool holds(HolderKindEnum holderKind, String id) =>
      kind == holderKind && holderId == id;
}
