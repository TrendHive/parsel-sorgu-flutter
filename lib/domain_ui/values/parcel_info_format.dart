import 'package:intl/intl.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/person/value_object/share_value_object.dart';
import 'package:parcel_atlas/domain_ui/values/l10n/app_localizations.dart';

/// How numbers, dates and shares are written, in the reader's language.
///
/// [area] and [length] use two decimals and the locale's separators
/// ("1.234,56 m²" in Turkish). [share] writes a fraction as a deed does —
/// "1/4", or "1/1" for the whole. [percent] signs a difference. [date] is day,
/// month, year and time.
class ParcelInfoFormat {
  ParcelInfoFormat(this._l10n)
    : _number = NumberFormat(_pattern, _l10n.localeName),
      _date = DateFormat(_datePattern, _l10n.localeName);

  final AppLocalizations _l10n;

  final NumberFormat _number;

  final DateFormat _date;

  static const String _pattern = '#,##0.00';
  static const String _datePattern = 'd MMM y HH:mm';
  static const String _plus = '+';
  static const String _percentSign = '%';

  String area(double squareMeters) =>
      _l10n.squareMeters(_number.format(squareMeters));

  String length(double meters) => _l10n.meters(_number.format(meters));

  String signedArea(double squareMeters) =>
      '${squareMeters > CoreConstants.zero ? _plus : CoreConstants.empty}${area(squareMeters)}';

  String percent(double value) =>
      '${value > CoreConstants.zero ? _plus : CoreConstants.empty}${_number.format(value)}$_percentSign';

  String share(ShareValueObject share) =>
      '${share.numerator}${CoreConstants.slash}${share.denominator}';

  String date(DateTime time) => _date.format(time.toLocal());
}
