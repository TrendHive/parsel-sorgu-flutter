import 'package:core/base/base_storage_manager.dart';
import 'package:core/constants.dart';
import 'package:core/storage/storage.dart';

class FCMTokenManager extends BaseStorageManager<String> {
  final String _key = "parcel_info_fcm_token_key";
  final Storage _storage = Storage();
  @override
  void clearValue() {
    _storage.delete(key: _key);
  }

  @override
  Future<String> getValue() async {
    try {
      String token = await _storage.read(key: _key) ?? CoreConstants.empty;
      return token;
    } catch (e) {
      String token = CoreConstants.empty;
      return token;
    }
  }

  @override
  void setValue(String value) {
    _storage.write(
      key: _key,
      value: value,
    );
  }
}
