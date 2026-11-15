import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/presentation/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_color.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/container/parcel_info_container.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';

class ErrorDialogBuilder extends StatelessWidget {
  final String message;

  const ErrorDialogBuilder({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ParcelInfoColor.transparent,
      child: Center(
        child: ParcelInfoContainer(
          width: MediaQuery.of(context).size.width * 4 / 5,
          height: MediaQuery.of(context).size.height * 2 / 3,
          color: ParcelInfoColor.white,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BaseDimens.radius.large),
            color: ParcelInfoColor.white,
          ),
          margin: EdgeInsets.symmetric(horizontal: BaseDimens.margin.xxxLarge),
          padding: EdgeInsets.all(BaseDimens.padding.large),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: ParcelInfoColor.dangerButtonLight),
              ParcelInfoText(message),
            ],
          ),
        ),
      ),
    );
  }
}
