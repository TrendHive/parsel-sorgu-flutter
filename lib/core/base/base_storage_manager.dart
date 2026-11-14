abstract class BaseStorageManager<T> {
  void setValue(T value);

  Future<T> getValue();

  void clearValue();
}
