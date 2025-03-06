import 'package:core/base/base_model.dart';
import 'package:core/constants.dart';
import 'package:latlong2/latlong.dart';

class ParcelInfoModel extends BaseModel {
  LatLng point =
      const LatLng(CoreConstants.zeroDouble, CoreConstants.zeroDouble);

  int cityID = CoreConstants.zero;
  String cityName = CoreConstants.empty;
  int districtID = CoreConstants.zero;
  String districtName = CoreConstants.empty;
  int neighborhoodID = CoreConstants.zero;
  String neighborhoodName = CoreConstants.empty;
  String locationString = CoreConstants.empty;
  String status = CoreConstants.empty;
  String groundStatus = CoreConstants.empty;
  String parcelID = CoreConstants.empty;
  String summary = CoreConstants.empty;
  double area = CoreConstants.zeroDouble;
  String blockID = CoreConstants.empty;
  String mapSheetID = CoreConstants.empty;
  String kind = CoreConstants.empty;

  String type = CoreConstants.empty;
  List<List<List<double>>> coordinates = [];

  LatLng location =
      const LatLng(CoreConstants.zeroDouble, CoreConstants.zeroDouble);
}
