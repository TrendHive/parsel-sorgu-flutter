import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/application/di/injection.dart';
import 'package:parcel_atlas/application/person/cubit/holdings_cubit.dart';
import 'package:parcel_atlas/domain_ui/widgets/scaffold/parcel_info_scaffold.dart';
import 'package:parcel_atlas/presentation/holdings/body/holdings_body.dart';

/// Everything that reaches one person: where each parcel is, its
/// area, the share, the owned area, and the totals.
class HoldingsPage extends StatelessWidget {
  const HoldingsPage({super.key, required this.personId});

  final String personId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HoldingsCubit>(
      create: (_) => getIt<HoldingsCubit>()..start(personId: personId),
      child: const ParcelInfoScaffold(body: HoldingsBody()),
    );
  }
}
