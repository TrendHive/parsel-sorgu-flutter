import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/base/base_value_object.dart';
import 'package:parcel_atlas/core/base/base_value_validator.dart';
import 'package:parcel_atlas/core/validator/not_blank_validator.dart';
import 'package:parcel_atlas/domain/input/enum/input_field_enum.dart';
import 'package:parcel_atlas/domain/person/validator/shares_within_whole_validator.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';

/// What a member says about a drawing when saving it: its name, the parcel it
/// corrects, its owners' shares and a note.
///
/// The name is required, every share must be a proper fraction and together
/// they may not exceed the whole parcel; less than the whole is allowed,
/// because an owner may still be unknown.
final class DrawingDetailsValueObject
    extends BaseValueObject<DrawingDetailsFields> {
  const DrawingDetailsValueObject(super.value);

  @override
  List<BaseValueValidator<DrawingDetailsFields>> get validators =>
      const <BaseValueValidator<DrawingDetailsFields>>[];

  @override
  Either<BaseException, DrawingDetailsFields> get valueObject =>
      NotBlankValidator(InputFieldEnum.drawingName.name)
          .validate(value.name)
          .then(
            (_) => const SharesWithinWholeValidator().validate(value.owners),
          )
          .map((_) => value);

  String get name => value.name.trim();

  String? get officialParcelId => value.officialParcelId;

  List<OwnershipValueObject> get owners => value.owners;

  String get note => value.note.trim();
}

/// The fields of a [DrawingDetailsValueObject], named.
typedef DrawingDetailsFields = ({
  String name,
  String? officialParcelId,
  List<OwnershipValueObject> owners,
  String note,
});
