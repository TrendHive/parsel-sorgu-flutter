import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_dimens.dart';

/// Keeps a page's content at a readable width on a large window — "neither
/// text nor boxes should take up the full screen width" — and centred, while
/// a phone still gets the full width.
class ParcelInfoReadableWidth extends StatelessWidget {
  const ParcelInfoReadableWidth({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: ParcelInfoDimens.readableWidth,
        ),
        child: child,
      ),
    );
  }
}
