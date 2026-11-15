import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/application/auth/cubit/sign_in_cubit.dart';
import 'package:parcel_atlas/application/di/injection.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/scaffold/parcel_info_scaffold.dart';
import 'package:parcel_atlas/presentation/sign_in/body/sign_in_body.dart';

/// The only page a signed-out device can reach. There is no sign-up: the
/// family's accounts are fixed.
class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignInCubit>(
      create: (_) => getIt<SignInCubit>(),
      child: const ParcelInfoScaffold(body: SignInBody()),
    );
  }
}
