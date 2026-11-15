import 'package:flutter_test/flutter_test.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/window_size_class_enum.dart';

void main() {
  test('a phone, a tablet and a desktop window get Material size classes', () {
    expect(WindowSizeClassEnum.of(360), WindowSizeClassEnum.compact);
    expect(WindowSizeClassEnum.of(599.9), WindowSizeClassEnum.compact);
    expect(WindowSizeClassEnum.of(600), WindowSizeClassEnum.medium);
    expect(WindowSizeClassEnum.of(840), WindowSizeClassEnum.expanded);
    expect(WindowSizeClassEnum.of(1280), WindowSizeClassEnum.large);
    expect(WindowSizeClassEnum.of(1920), WindowSizeClassEnum.extraLarge);
  });

  test('the side panel starts at expanded, not before', () {
    expect(
      WindowSizeClassEnum.medium.isAtLeast(WindowSizeClassEnum.expanded),
      isFalse,
    );
    expect(
      WindowSizeClassEnum.large.isAtLeast(WindowSizeClassEnum.expanded),
      isTrue,
    );
  });
}
