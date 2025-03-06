import 'package:application/home_cubit/home_cubit.dart';
import 'package:core/constants.dart';
import 'package:domain/constants.dart';
import 'package:domain/info/info.dart';
import 'package:domain_ui/dialog/error/error_dialog.dart';
import 'package:domain_ui/dialog/info/info_dialog.dart';
import 'package:domain_ui/values/parcel_info_local_keys.dart';
import 'package:domain_ui/widgets/scaffold/parcel_info_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:presentation/home/body/home_body.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  InfoDialog? infoDialog;
  ErrorDialog? errorDialog;

  showInfoDialog() {
    infoDialog?.dismiss();
    infoDialog = InfoDialog(context,
        title: ParcelInfoLocalKeys.of(context)!.infoDialogParcelInfoTitle,
        infoList: [
          Info(
            label: ParcelInfoLocalKeys.of(context)!.infoLabelCity,
            value: context.read<HomeCubit>().parcelInfoModel.cityName,
          ),
          Info(
            label: ParcelInfoLocalKeys.of(context)!.infoLabelDistrict,
            value: context.read<HomeCubit>().parcelInfoModel.districtName,
          ),
          Info(
            label: ParcelInfoLocalKeys.of(context)!.infoLabelNeighborhood,
            value: context.read<HomeCubit>().parcelInfoModel.neighborhoodName,
          ),
          Info(
            label: ParcelInfoLocalKeys.of(context)!.infoLabelLocation,
            value: context.read<HomeCubit>().parcelInfoModel.locationString,
          ),
          Info(
            label: ParcelInfoLocalKeys.of(context)!.infoLabelStatus,
            value: context.read<HomeCubit>().parcelInfoModel.status,
          ),
          Info(
            label: ParcelInfoLocalKeys.of(context)!.infoLabelGroundStatus,
            value: context.read<HomeCubit>().parcelInfoModel.groundStatus,
          ),
          Info(
            label: ParcelInfoLocalKeys.of(context)!.infoLabelSummary,
            value: context.read<HomeCubit>().parcelInfoModel.summary,
          ),
          Info(
            label: ParcelInfoLocalKeys.of(context)!.infoLabelArea,
            value: context.read<HomeCubit>().parcelInfoModel.area.toString(),
          ),
          Info(
            label: ParcelInfoLocalKeys.of(context)!.infoLabelKind,
            value: context.read<HomeCubit>().parcelInfoModel.kind,
          ),
          Info(
            label: ParcelInfoLocalKeys.of(context)!.infoLabelParcelNumber,
            value: context.read<HomeCubit>().parcelInfoModel.parcelID,
          ),
          Info(
            label: ParcelInfoLocalKeys.of(context)!.infoLabelBlockNumber,
            value: context.read<HomeCubit>().parcelInfoModel.blockID,
          ),
          Info(
            label: ParcelInfoLocalKeys.of(context)!.infoLabelMapSheetNumber,
            value: context.read<HomeCubit>().parcelInfoModel.mapSheetID,
          ),
        ]);
    infoDialog?.show();
  }

  showErrorDialog() {
    errorDialog?.dismiss();
    errorDialog = ErrorDialog(
      context,
      message:
          context.read<HomeCubit>().exceptionList.lastOrNull?.cause?.cause ??
              CoreConstants.empty,
    );
    errorDialog?.show();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state is HomeParcelInfoFound) {
          showInfoDialog();
        }
        if (state is HomeError) {
          showErrorDialog();
        }
      },
      builder: (context, state) {
        return ParcelInfoScaffold(
          body: HomeBody(
            packageName: context.read<HomeCubit>().packageModel.packageName,
            urlTemplate: DomainConstants.urlTemplate,
            onTap: (TapPosition tapPosition, LatLng point) =>
                context.read<HomeCubit>().getParcelInfo(point: point),
            initialCenter: context.read<HomeCubit>().parcelInfoModel.location,
          ),
        );
      },
    );
  }
}
