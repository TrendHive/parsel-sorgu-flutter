import 'package:parcel_atlas/core/base/base_value_object.dart';
import 'package:parcel_atlas/core/base/base_value_validator.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/person/validator/proper_fraction_validator.dart';

/// A share of a parcel as a title deed writes it: [numerator] / [denominator]
/// ("1/4").
///
/// Kept as two integers, never a double, so shares add exactly — three
/// shares of 1/3 make 1, not 0.9999 — and always print as the deed does.
/// Every result is reduced: 2/8 is stored and shown as 1/4.
///
/// [whole] is the entire parcel and [none] nothing. [plus] adds two shares,
/// [dividedBy] splits one equally (a group's share among its members),
/// [compareTo] orders them, and [fraction] is the share as a number for
/// display or a bar chart only.
///
/// [tryParse] reads what a member types: "1/4", "3/8", or "1" for the whole
/// parcel; anything else — or a share that is not between nothing and the
/// whole — is null.
final class ShareValueObject
    extends BaseValueObject<({int numerator, int denominator})>
    implements Comparable<ShareValueObject> {
  const ShareValueObject._(super.value);

  factory ShareValueObject(int numerator, int denominator) {
    final int divisor = _gcd(numerator.abs(), denominator.abs());
    return divisor == CoreConstants.zero
        ? const ShareValueObject._((numerator: 0, denominator: 1))
        : ShareValueObject._((
            numerator: numerator ~/ divisor,
            denominator: denominator ~/ divisor,
          ));
  }

  static ShareValueObject? tryParse(String text) {
    final List<String> parts = text
        .replaceAll(CoreConstants.space, CoreConstants.empty)
        .split(CoreConstants.slash);
    final int? numerator = int.tryParse(parts.first);
    final int? denominator = parts.length == CoreConstants.one
        ? CoreConstants.one
        : parts.length == CoreConstants.two
        ? int.tryParse(parts.last)
        : null;
    if (numerator == null || denominator == null) return null;
    final ShareValueObject share = ShareValueObject(numerator, denominator);
    return share.isValid ? share : null;
  }

  static const ShareValueObject whole = ShareValueObject._((
    numerator: 1,
    denominator: 1,
  ));

  static const ShareValueObject none = ShareValueObject._((
    numerator: 0,
    denominator: 1,
  ));

  @override
  List<BaseValueValidator<({int numerator, int denominator})>> get validators =>
      const <BaseValueValidator<({int numerator, int denominator})>>[
        ProperFractionValidator(),
      ];

  int get numerator => value.numerator;

  int get denominator => value.denominator;

  double get fraction => numerator / denominator;

  bool get isWhole => numerator == denominator;

  ShareValueObject plus(ShareValueObject other) => ShareValueObject(
    numerator * other.denominator + other.numerator * denominator,
    denominator * other.denominator,
  );

  ShareValueObject dividedBy(int parts) => parts <= CoreConstants.zero
      ? none
      : ShareValueObject(numerator, denominator * parts);

  @override
  int compareTo(ShareValueObject other) =>
      (numerator * other.denominator).compareTo(other.numerator * denominator);

  static int _gcd(int a, int b) => b == CoreConstants.zero ? a : _gcd(b, a % b);
}
