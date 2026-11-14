import 'package:either_dart/either.dart';
import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/base/base_value_validator.dart';
import 'package:parcel_atlas/core/cause/too_few_corners_cause.dart';
import 'package:parcel_atlas/core/exception/validation_exception.dart';
import 'package:parcel_atlas/domain/map/rule/map_rules.dart';

/// Passes a ring with enough distinct corners to enclose an area.
///
/// A closing corner that repeats the first is not counted, so a triangle
/// stored closed (four points, last = first) passes and two taps do not.
final class MinCornersValidator extends BaseValueValidator<List<LatLng>> {
  const MinCornersValidator();

  @override
  Either<BaseException, List<LatLng>> validate(List<LatLng> value) =>
      value.toSet().length < MapRules.minimumCorners
      ? Left(ValidationException(cause: TooFewCornersCause()))
      : Right(value);
}
