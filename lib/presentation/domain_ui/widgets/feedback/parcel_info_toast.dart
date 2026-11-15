import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';

/// A short message at the bottom of the screen — a confirmation, or why
/// something did not work (`isError` colours it).
class ParcelInfoToast {
  ParcelInfoToast._();

  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(
      context,
    );
    if (messenger == null) return;
    final ColorScheme colors = Theme.of(context).colorScheme;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: CoreConstants.toastDuration,
          backgroundColor: isError ? colors.error : null,
          content: ParcelInfoText(
            message,
            style: TextStyle(color: isError ? colors.onError : null),
          ),
        ),
      );
  }
}
