import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/presentation/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';

/// One labelled fact in a panel: "Deed area   165,22 m²".
class MapInfoRow extends StatelessWidget {
  const MapInfoRow({super.key, required this.label, required this.value});

  final String label;

  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: BaseDimens.padding.xxSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(child: ParcelInfoText(label, style: text.bodyMedium)),
          SizedBox(width: BaseDimens.width.small),
          Expanded(
            child: ParcelInfoText(
              value,
              textAlign: TextAlign.end,
              style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
