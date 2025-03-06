import 'package:package_info_plus/package_info_plus.dart';

class PackageUtils {
  static final PackageUtils _singleton = PackageUtils._internal();

  factory PackageUtils() {
    return _singleton;
  }

  PackageUtils._internal();
  
  late PackageInfo packageInfo;


  Future<void> init() async {
    packageInfo = await PackageInfo.fromPlatform();
  }

  late String appName = packageInfo.appName;
  late String packageName = packageInfo.packageName;
  late String version = packageInfo.version;
  late String buildNumber = packageInfo.buildNumber;
}
