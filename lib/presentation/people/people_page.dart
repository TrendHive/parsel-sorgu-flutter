import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/application/di/injection.dart';
import 'package:parcel_atlas/application/person/cubit/persons_cubit.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/domain_ui/widgets/scaffold/parcel_info_scaffold.dart';
import 'package:parcel_atlas/domain_ui/widgets/text/parcel_info_text.dart';
import 'package:parcel_atlas/presentation/people/body/people_body.dart';

/// Parcel owners — people and groups. Not sign-in accounts: these are who
/// the parcels belong to.
class PeoplePage extends StatelessWidget {
  const PeoplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PersonsCubit>(
      create: (_) => getIt<PersonsCubit>()..start(),
      child: ParcelInfoScaffold(
        appBar: AppBar(
          title: ParcelInfoText(ParcelInfoLocalKeys.of(context).peopleTitle),
        ),
        body: const PeopleBody(),
      ),
    );
  }
}
