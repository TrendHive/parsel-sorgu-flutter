import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/application/di/injection.dart';
import 'package:parcel_atlas/application/person/cubit/holdings_cubit.dart';
import 'package:parcel_atlas/domain/person/enum/holder_kind_enum.dart';
import 'package:parcel_atlas/domain_ui/widgets/scaffold/parcel_info_scaffold.dart';
import 'package:parcel_atlas/presentation/holdings/body/holdings_body.dart';

/// Everything one person or one group holds: where each parcel is, its
/// area, the share, the owned area, and the totals.
class HoldingsPage extends StatelessWidget {
  const HoldingsPage({super.key, required this.kind, required this.id});

  final HolderKindEnum kind;

  final String id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HoldingsCubit>(
      create: (_) => getIt<HoldingsCubit>()..start(kind: kind, id: id),
      child: ParcelInfoScaffold(body: HoldingsBody(kind: kind)),
    );
  }
}
