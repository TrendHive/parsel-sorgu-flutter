import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/domain/map/enum/camera_move_enum.dart';
import 'package:parcel_atlas/domain/map/rule/map_rules.dart';

void main() {
  const ({LatLng southWest, LatLng northEast}) screen = (
    southWest: LatLng(40, 41),
    northEast: LatLng(40.01, 41.01),
  );
  List<LatLng> square(double lat, double lng) => <LatLng>[
    LatLng(lat, lng),
    LatLng(lat, lng + 0.001),
    LatLng(lat + 0.001, lng + 0.001),
    LatLng(lat + 0.001, lng),
  ];

  test('a tapped parcel already on screen does not move the map', () {
    expect(
      MapRules.cameraMove(visible: screen, target: square(40.005, 41.005)),
      CameraMoveEnum.stay,
    );
  });

  test('a parcel half on screen slides into view without zooming', () {
    expect(
      MapRules.cameraMove(visible: screen, target: square(40.0095, 41.005)),
      CameraMoveEnum.pan,
    );
  });

  test('a parcel off screen is framed', () {
    expect(
      MapRules.cameraMove(visible: screen, target: square(40.1, 41.1)),
      CameraMoveEnum.frame,
    );
  });
}
