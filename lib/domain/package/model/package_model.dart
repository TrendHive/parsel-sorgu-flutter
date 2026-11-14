import 'package:parcel_atlas/core/base/base_model.dart';
import 'package:parcel_atlas/core/constants.dart';

class PackageModel extends BaseModel {
  String appName = CoreConstants.empty;
  String packageName = CoreConstants.empty;
  String version = CoreConstants.empty;
  String buildNumber = CoreConstants.empty;
}
