import 'dart:io' show Platform;

import 'package:core/constants.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceUtils {
  static final DeviceUtils _singleton = DeviceUtils._internal();

  factory DeviceUtils() {
    return _singleton;
  }

  DeviceUtils._internal();

  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  AndroidDeviceInfo? androidInfo;
  IosDeviceInfo? iosInfo;
  MacOsDeviceInfo? macOsDeviceInfo;
  WindowsDeviceInfo? windowsDeviceInfo;
  WebBrowserInfo? webBrowserInfo;
  LinuxDeviceInfo? linuxDeviceInfo;

  Future<void> init() async {
    if (Platform.isAndroid) {
      androidInfo = await deviceInfoPlugin.androidInfo;
    }
    if (Platform.isIOS) {
      iosInfo = await deviceInfoPlugin.iosInfo;
    }
    if (Platform.isMacOS) {
      macOsDeviceInfo = await deviceInfoPlugin.macOsInfo;
    }
    if (Platform.isWindows) {
      windowsDeviceInfo = await deviceInfoPlugin.windowsInfo;
    }
    if (Platform.isFuchsia) {
      webBrowserInfo = await deviceInfoPlugin.webBrowserInfo;
    }
    if (Platform.isLinux) {
      linuxDeviceInfo = await deviceInfoPlugin.linuxInfo;
    }
  }

  late String brand = getBrand();
  late String model = getModel();
  late String sdk = getSDK();
  late String osVersion = getOSVersion();
  late String manufacturer = getManufacturer();
  late String product = getProduct();

  String getBrand() {
    if (Platform.isAndroid) {
      return androidInfo?.brand ?? CoreConstants.empty;
    } else if (Platform.isIOS) {
      return Platform.localeName;
    } else if (Platform.isMacOS) {
      return Platform.localeName;
    } else if (Platform.isWindows) {
      return Platform.localeName;
    } else if (Platform.isFuchsia) {
      return webBrowserInfo?.browserName.name ?? CoreConstants.empty;
    } else if (Platform.isLinux) {
      return linuxDeviceInfo?.prettyName ?? CoreConstants.empty;
    } else {
      return CoreConstants.empty;
    }
  }

  String getModel() {
    if (Platform.isAndroid) {
      return androidInfo?.model ?? CoreConstants.empty;
    } else if (Platform.isIOS) {
      return iosInfo?.model ?? CoreConstants.empty;
    } else if (Platform.isMacOS) {
      return macOsDeviceInfo?.model ?? CoreConstants.empty;
    } else if (Platform.isWindows) {
      return windowsDeviceInfo?.productName ?? CoreConstants.empty;
    } else if (Platform.isFuchsia) {
      return CoreConstants.empty;
    } else if (Platform.isLinux) {
      return linuxDeviceInfo?.variant ?? CoreConstants.empty;
    } else {
      return CoreConstants.empty;
    }
  }

  String getSDK() {
    if (Platform.isAndroid) {
      return androidInfo?.version.sdkInt.toString() ?? CoreConstants.empty;
    } else if (Platform.isIOS) {
      return iosInfo?.utsname.version ?? CoreConstants.empty;
    } else if (Platform.isMacOS) {
      return macOsDeviceInfo?.kernelVersion ?? CoreConstants.empty;
    } else if (Platform.isWindows) {
      return windowsDeviceInfo?.csdVersion ?? CoreConstants.empty;
    } else if (Platform.isFuchsia) {
      return webBrowserInfo?.appVersion ?? CoreConstants.empty;
    } else if (Platform.isLinux) {
      return linuxDeviceInfo?.versionId ?? CoreConstants.empty;
    } else {
      return CoreConstants.empty;
    }
  }

  String getOSVersion() {
    if (Platform.isAndroid) {
      return androidInfo?.version.release ?? CoreConstants.empty;
    } else if (Platform.isIOS) {
      return iosInfo?.systemVersion ?? CoreConstants.empty;
    } else if (Platform.isMacOS) {
      return macOsDeviceInfo != null
          ? "${macOsDeviceInfo!.majorVersion}${CoreConstants.dot}${macOsDeviceInfo!.minorVersion}${CoreConstants.dot}${macOsDeviceInfo!.patchVersion}"
          : CoreConstants.empty;
    } else if (Platform.isWindows) {
      return windowsDeviceInfo?.displayVersion ?? CoreConstants.empty;
    } else if (Platform.isFuchsia) {
      return webBrowserInfo?.vendor ?? CoreConstants.empty;
    } else if (Platform.isLinux) {
      return linuxDeviceInfo?.version ?? CoreConstants.empty;
    } else {
      return CoreConstants.empty;
    }
  }

  String getManufacturer() {
    if (Platform.isAndroid) {
      return androidInfo?.manufacturer ?? CoreConstants.empty;
    } else if (Platform.isIOS) {
      return iosInfo?.utsname.sysname ?? CoreConstants.empty;
    } else if (Platform.isMacOS) {
      return Platform.localHostname;
    } else if (Platform.isWindows) {
      return windowsDeviceInfo?.productName ?? CoreConstants.empty;
    } else if (Platform.isFuchsia) {
      return webBrowserInfo?.platform ?? CoreConstants.empty;
    } else if (Platform.isLinux) {
      return linuxDeviceInfo?.name ?? CoreConstants.empty;
    } else {
      return CoreConstants.empty;
    }
  }

  String getProduct() {
    if (Platform.isAndroid) {
      return androidInfo?.product ?? CoreConstants.empty;
    } else if (Platform.isIOS) {
      return iosInfo?.name ?? CoreConstants.empty;
    } else if (Platform.isMacOS) {
      return macOsDeviceInfo?.computerName ?? CoreConstants.empty;
    } else if (Platform.isWindows) {
      return windowsDeviceInfo?.productId ?? CoreConstants.empty;
    } else if (Platform.isFuchsia) {
      return webBrowserInfo?.product ?? CoreConstants.empty;
    } else if (Platform.isLinux) {
      return linuxDeviceInfo?.name ?? CoreConstants.empty;
    } else {
      return CoreConstants.empty;
    }
  }
}
