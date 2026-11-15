import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';

/// "Last changed by … · date" — small, at the foot of a panel.
class MapAuditLine extends StatelessWidget {
  const MapAuditLine(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ParcelInfoText(text, style: Theme.of(context).textTheme.bodySmall);
  }
}
