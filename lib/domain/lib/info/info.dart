import 'package:core/constants.dart';
import 'package:domain/constants.dart';

class Info {
  final String label;
  final String value;
  Info({
    this.label = DomainConstants.labelDummy,
    this.value = CoreConstants.hyphen,
  });
}
