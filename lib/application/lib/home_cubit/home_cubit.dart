import 'package:application/parcel_get/usecase/parcel_get_usecase.dart';
import 'package:core/base/base_exception.dart';
import 'package:domain/package/model/package_model.dart';
import 'package:domain/parcel_info/model/parcel_info_model.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infrastructure/location/location_manager.dart';
import 'package:infrastructure/utility/package_utils.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  List<BaseException> exceptionList = [];

  PackageModel packageModel = PackageModel();
  ParcelInfoModel parcelInfoModel = ParcelInfoModel();

  ParcelGetUseCase parcelGetUseCase = ParcelGetUseCase();

  Future<void> getPackageInfo() async {
    emit(HomeLoading());
    await PackageUtils().init();
    packageModel.appName = PackageUtils().appName;
    packageModel.packageName = PackageUtils().packageName;
    packageModel.version = PackageUtils().version;
    packageModel.buildNumber = PackageUtils().buildNumber;
    Position positon = await LocationManager().determinePosition();
    parcelInfoModel.location = LatLng(positon.latitude, positon.longitude);
    emit(HomeStart());
    return;
  }

  Future<void> getParcelInfo({required LatLng point}) async {
    emit(HomeLoading());
    parcelInfoModel.point = point;
    Either<BaseException, ParcelInfoModel> result =
        await parcelGetUseCase.execute(parcelInfoModel);
    result.fold((left) {
      exceptionList.add(result.left);
      emit(HomeError());
    }, (right) {
      emit(HomeParcelInfoFound());
    });
    return;
  }
}
