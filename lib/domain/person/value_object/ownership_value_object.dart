import 'package:parcel_atlas/core/base/base_value_object.dart';
import 'package:parcel_atlas/core/base/base_value_validator.dart';
import 'package:parcel_atlas/domain/person/value_object/share_value_object.dart';

/// One line of a parcel's ownership: who it is recorded on ([personId]) and
/// how much ([share]).
///
/// The line names the person the land is recorded on — often an ancestor.
/// Who holds it today follows from the family tree, so recording a parcel on
/// a grandfather is enough for every heir to see their part.
final class OwnershipValueObject
    extends BaseValueObject<({String personId, ShareValueObject share})> {
  const OwnershipValueObject({
    required String personId,
    required ShareValueObject share,
  }) : super((personId: personId, share: share));

  @override
  List<BaseValueValidator<({String personId, ShareValueObject share})>>
  get validators =>
      const <BaseValueValidator<({String personId, ShareValueObject share})>>[];

  String get personId => value.personId;

  ShareValueObject get share => value.share;
}
