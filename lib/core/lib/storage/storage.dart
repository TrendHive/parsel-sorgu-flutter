import 'dart:async';

import 'package:core/base/base_storage.dart';
import 'package:core/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Storage extends BaseStorage {
  static const IOSOptions _iosOptions = IOSOptions.defaultOptions;
  static const AndroidOptions _androidOptions =
      AndroidOptions(encryptedSharedPreferences: true);
  static const LinuxOptions _linuxOptions = LinuxOptions.defaultOptions;
  static const WindowsOptions _windowsOptions = WindowsOptions.defaultOptions;
  static const WebOptions _webOptions = WebOptions.defaultOptions;
  static const MacOsOptions _macOsOptions = MacOsOptions.defaultOptions;

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    iOptions: _iosOptions,
    aOptions: _androidOptions,
    lOptions: _linuxOptions,
    wOptions: _windowsOptions,
    webOptions: _webOptions,
    mOptions: _macOsOptions,
  );

  @override
  FutureOr<String?> read({required String key}) {
    try {
      return _storage.read(key: key);
    } catch (e) {
      return CoreConstants.empty;
    }
  }

  @override
  Future<void> write({
    required String key,
    required String value,
  }) =>
      _storage.write(
        key: key,
        value: value,
      );

  @override
  Future<void> delete({required String key}) => _storage.delete(key: key);

  @override
  Future<Map<String, String>> readAll() => _storage.readAll();

  @override
  Future<void> deleteAll() => _storage.deleteAll();

  @override
  Future<bool> containsKey({required String key}) =>
      _storage.containsKey(key: key);
}
