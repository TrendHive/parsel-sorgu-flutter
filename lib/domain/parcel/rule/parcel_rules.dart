import 'package:parcel_atlas/core/constants.dart';

/// How a registry parcel is named and recognised.
///
/// [keyOf] is a parcel's identity in the family's store: neighbourhood, block
/// and parcel number, which together name exactly one parcel in the country.
/// Querying the same parcel from two phones lands on the same record instead
/// of creating two — the store, not the registry, is the source of truth for
/// everything the family adds.
///
/// [labelOf] is how a parcel is written everywhere a person reads it:
/// "114/1".
///
/// [activeStatus] is the registry's `durum` for a parcel that is in force; any
/// other value is a historical one, shown dimmed.
abstract final class ParcelRules {
  static const String activeStatus = '1';

  static String keyOf({
    required int neighborhoodId,
    required String block,
    required String parcel,
  }) => <Object>[neighborhoodId, block, parcel]
      .join(CoreConstants.hyphen)
      .replaceAll(CoreConstants.slash, CoreConstants.hyphen);

  static String labelOf({required String block, required String parcel}) =>
      '$block${CoreConstants.slash}$parcel';
}
