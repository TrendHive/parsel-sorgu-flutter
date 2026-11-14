import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/domain_ui/widgets/scaffold/parcel_info_scaffold.dart';
import 'package:parcel_atlas/presentation/splash/body/splash_body.dart';

/// Shown only while the stored sign-in is being restored — usually a blink.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ParcelInfoScaffold(body: SplashBody());
  }
}
