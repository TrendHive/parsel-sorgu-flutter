import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/constants.dart';

class Info {
  final String label;
  final String value;
  Info({
    this.label = DomainConstants.labelDummy,
    this.value = CoreConstants.hyphen,
  });
}
