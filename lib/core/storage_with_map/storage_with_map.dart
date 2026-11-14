import 'dart:async';
import 'dart:convert';

import 'package:parcel_atlas/core/base/base_storage.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/core/storage/storage.dart';

class StorageWithMap {
  final BaseStorage _storage = Storage();

  FutureOr<Map<String, dynamic>> read({required String key}) async {
    final value = await _storage.read(key: key);
    try {
      return jsonDecode(value ?? CoreConstants.empty) as Map<String, dynamic>;
    } catch (e) {
      return CoreConstants.emptyMap;
    }
  }

  Future<void> write({
    required String key,
    required Map<String, dynamic> map,
  }) => _storage.write(key: key, value: jsonEncode(map));

  Future<void> delete({required String key}) => _storage.delete(key: key);

  Future<bool> containsKey({required String key}) =>
      _storage.containsKey(key: key);
}
