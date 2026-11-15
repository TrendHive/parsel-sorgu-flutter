import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/application/activity/cubit/activity_cubit.dart';
import 'package:parcel_atlas/application/di/injection.dart';
import 'package:parcel_atlas/presentation/activity/body/activity_body.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/scaffold/parcel_info_scaffold.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';

/// Who changed what, and when — every member's changes, newest first.
class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ActivityCubit>(
      create: (_) => getIt<ActivityCubit>()..start(),
      child: ParcelInfoScaffold(
        appBar: AppBar(
          title: ParcelInfoText(ParcelInfoLocalKeys.of(context).activityTitle),
        ),
        body: const ActivityBody(),
      ),
    );
  }
}
