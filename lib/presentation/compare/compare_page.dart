import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/application/di/injection.dart';
import 'package:parcel_atlas/application/drawing/cubit/compare_cubit.dart';
import 'package:parcel_atlas/presentation/compare/body/compare_body.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/scaffold/parcel_info_scaffold.dart';

/// The parcels put aside on the map, compared: real against deed area, per
/// parcel and per owner.
class ComparePage extends StatelessWidget {
  const ComparePage({super.key, required this.ids});

  final List<String> ids;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CompareCubit>(
      create: (_) => getIt<CompareCubit>()..start(ids: ids),
      child: const ParcelInfoScaffold(body: CompareBody()),
    );
  }
}
