import 'package:core/base/base_model.dart';
import 'package:core/constants.dart';
import 'package:domain/constants.dart';
import 'package:domain/parcel_info/model/parcel_info_model.dart';
import 'package:latlong2/latlong.dart';

class ParcelInfoListModel extends BaseModel {
  LatLng point =
      const LatLng(CoreConstants.zeroDouble, CoreConstants.zeroDouble);

  List<ParcelInfoModel> parcelInfoList = [];

  LatLng location = const LatLng(
      DomainConstants.istanbulLatitude, DomainConstants.istanbulLongitude);
}
