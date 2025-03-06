import 'dart:async';

abstract class BaseStorage {
  FutureOr<String?> read({required String key});

  Future<void> write({
    required String key,
    required String value,
  });

  Future<void> delete({required String key});

  Future<Map<String, String>> readAll();

  Future<void> deleteAll();

  Future<bool> containsKey({required String key});
}
