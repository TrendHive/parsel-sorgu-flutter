import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/application/di/injection.dart';
import 'package:parcel_atlas/application/map/cubit/map_cubit.dart';
import 'package:parcel_atlas/domain_ui/widgets/scaffold/parcel_info_scaffold.dart';
import 'package:parcel_atlas/presentation/map/body/map_body.dart';

/// The home of the app: the family's parcels on aerial imagery.
///
/// [focusId] selects and frames one record on arrival — how "show on map"
/// from a holdings page lands on the right parcel.
class MapPage extends StatelessWidget {
  const MapPage({super.key, this.focusId});

  final String? focusId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MapCubit>(
      create: (_) => getIt<MapCubit>()..start(focusId: focusId),
      child: const ParcelInfoScaffold(body: MapBody()),
    );
  }
}
