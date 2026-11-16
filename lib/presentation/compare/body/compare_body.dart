import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/application/drawing/cubit/compare_cubit.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/drawing/read_model/compare_line_read_model.dart';
import 'package:parcel_atlas/domain/drawing/read_model/compare_owner_read_model.dart';
import 'package:parcel_atlas/domain/drawing/read_model/compare_table_read_model.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';
import 'package:parcel_atlas/presentation/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/copy/exception_copy.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/l10n/app_localizations.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_color.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_format.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/layout/parcel_info_readable_width.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';
import 'package:parcel_atlas/presentation/router/parcel_info_router.dart';

/// Totals first — real and deed area of everything compared — then one row
/// per owner (real, deed, difference), then one card per parcel with its
/// owners, its areas and "show on map".
class CompareBody extends StatelessWidget {
  const CompareBody({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = ParcelInfoLocalKeys.of(context);
    return BlocBuilder<CompareCubit, CompareState>(
      builder: (BuildContext context, CompareState state) => switch (state) {
        CompareLoading() => const Center(child: CircularProgressIndicator()),
        CompareFailed(:final exception) => Center(
          child: ParcelInfoText(ExceptionCopy.of(l10n, exception)),
        ),
        CompareReady(:final CompareTableReadModel table) =>
          ParcelInfoReadableWidth(child: _ready(context, table)),
      },
    );
  }

  Widget _ready(BuildContext context, CompareTableReadModel table) {
    final AppLocalizations l10n = ParcelInfoLocalKeys.of(context);
    final ParcelInfoFormat format = ParcelInfoFormat(l10n);
    final TextTheme text = Theme.of(context).textTheme;
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar.large(title: ParcelInfoText(l10n.compareTitle)),
        SliverPadding(
          padding: EdgeInsets.all(BaseDimens.padding.xxxxMedium),
          sliver: SliverList.list(
            children: <Widget>[
              if (table.lines.isEmpty)
                ParcelInfoText(l10n.compareEmpty)
              else ...<Widget>[
                ParcelInfoText(
                  _areas(
                    l10n,
                    format,
                    real: table.realTotal,
                    registry: table.registryTotal,
                  ),
                  style: text.titleMedium,
                ),
                SizedBox(height: BaseDimens.height.small),
                ParcelInfoText(l10n.compareByOwner, style: text.titleMedium),
                for (final CompareOwnerReadModel owner in table.owners)
                  Card(
                    child: ListTile(
                      leading: Icon(
                        owner.person == null
                            ? Icons.help_outline
                            : Icons.person_outline,
                      ),
                      title: ParcelInfoText(
                        owner.person?.name ?? l10n.colourUnassigned,
                      ),
                      subtitle: ParcelInfoText(
                        _areas(
                          l10n,
                          format,
                          real: owner.realArea,
                          registry: owner.registryArea,
                        ),
                      ),
                      onTap: owner.person == null
                          ? null
                          : () => context.push(
                              ParcelInfoRouter.holdingsOf(owner.person!.id),
                            ),
                    ),
                  ),
                SizedBox(height: BaseDimens.height.small),
                ParcelInfoText(l10n.compareParcels, style: text.titleMedium),
                for (final CompareLineReadModel line in table.lines)
                  _line(context, table, line, format),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _areas(
    AppLocalizations l10n,
    ParcelInfoFormat format, {
    required double? real,
    required double? registry,
  }) => <String>[
    '${l10n.compareReal}: ${real == null ? l10n.compareNotDrawn : format.area(real)}',
    '${l10n.compareRegistry}: ${registry == null ? l10n.compareNoRegistry : format.area(registry)}',
    if (real != null && registry != null)
      '${l10n.compareDifference}: ${format.signedArea(real - registry)}',
  ].join(_separator);

  Widget _line(
    BuildContext context,
    CompareTableReadModel table,
    CompareLineReadModel line,
    ParcelInfoFormat format,
  ) {
    final AppLocalizations l10n = ParcelInfoLocalKeys.of(context);
    final String title =
        line.drawing?.name ?? line.official?.label ?? CoreConstants.empty;
    final String place = <String>[
      line.official?.record.neighborhoodName ?? CoreConstants.empty,
      line.official?.label ?? CoreConstants.empty,
    ].where((String part) => part.isNotEmpty).join(_separator);
    final String owners = <String>[
      for (final OwnershipValueObject owner
          in line.drawing?.owners ?? const <OwnershipValueObject>[])
        '${_nameOf(table, owner.personId)} ${format.share(owner.share)}',
    ].join(_separator);
    final String id = line.drawing?.id ?? line.official!.id;
    return Card(
      child: ListTile(
        leading: Icon(
          line.drawing == null
              ? Icons.gavel_outlined
              : Icons.edit_location_alt_outlined,
          color: line.drawing == null
              ? ParcelInfoColor.officialStroke
              : ParcelInfoColor.drawnStroke,
        ),
        title: ParcelInfoText(title),
        subtitle: ParcelInfoText(
          <String>[
            if (place.isNotEmpty) place,
            _areas(
              l10n,
              format,
              real: line.realArea,
              registry: line.registryArea,
            ),
            if (owners.isEmpty) l10n.colourUnassigned else owners,
          ].join(CoreConstants.nextLine),
        ),
        isThreeLine: true,
        trailing: IconButton(
          tooltip: l10n.showOnMap,
          icon: const Icon(Icons.map_outlined),
          onPressed: () => context.go(ParcelInfoRouter.mapFocused(id)),
        ),
      ),
    );
  }

  String _nameOf(CompareTableReadModel table, String personId) {
    for (final CompareOwnerReadModel owner in table.owners) {
      if (owner.person?.id == personId) return owner.person!.name;
    }
    return personId;
  }

  static const String _separator = ' · ';
}
