import 'package:application/home_cubit/home_cubit.dart';
import 'package:domain_ui/widgets/scaffold/parcel_info_scaffold.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:presentation/router/parcel_info_router.dart';
import 'package:presentation/splash/body/splash_body.dart';

class SplashPage extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const SplashPage({super.key, required this.onThemeToggle});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state is HomeStart) {
          context.go(ParcelInfoRouter.homePath.path());
        }
      },
      builder: (context, state) {
        return ParcelInfoScaffold(
          body: SplashBody(onThemeToggle: widget.onThemeToggle),
        );
      },
    );
  }
}
