import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/application/person/cubit/holdings_cubit.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/read_model/holding_line_read_model.dart';
import 'package:parcel_atlas/domain/person/read_model/holdings_read_model.dart';
import 'package:parcel_atlas/presentation/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/copy/exception_copy.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_color.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_format.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/layout/parcel_info_readable_width.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';
import 'package:parcel_atlas/presentation/router/parcel_info_router.dart';

/// Totals first — parcels, total area, owned area — then the person's place
/// in the tree (parent and children, each a link), then one card per parcel
/// with where it is, its area, the share that reaches the person, the
/// ancestor it comes from, and "show on map".
class HoldingsBody extends StatelessWidget {
  const HoldingsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = ParcelInfoLocalKeys.of(context);
    return BlocBuilder<HoldingsCubit, HoldingsState>(
      builder: (BuildContext context, HoldingsState state) => switch (state) {
        HoldingsLoading() => const Center(child: CircularProgressIndicator()),
        HoldingsFailed(:final exception) => Center(
          child: ParcelInfoText(ExceptionCopy.of(l10n, exception)),
        ),
        HoldingsReady() => ParcelInfoReadableWidth(
          child: _ready(context, state),
        ),
      },
    );
  }

  Widget _ready(BuildContext context, HoldingsReady state) {
    final l10n = ParcelInfoLocalKeys.of(context);
    final ParcelInfoFormat format = ParcelInfoFormat(l10n);
    final TextTheme text = Theme.of(context).textTheme;
    final HoldingsReadModel holdings = state.holdings;
    final PersonEntity? parent = state.parent;
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar.large(title: ParcelInfoText(state.person.name)),
        SliverPadding(
          padding: EdgeInsets.all(BaseDimens.padding.xxxxMedium),
          sliver: SliverList.list(
            children: <Widget>[
              Wrap(
                spacing: BaseDimens.margin.medium,
                runSpacing: BaseDimens.margin.medium,
                children: <Widget>[
                  _total(
                    context,
                    l10n.holdingsParcels,
                    '${holdings.parcelCount}',
                  ),
                  _total(
                    context,
                    l10n.holdingsTotalArea,
                    format.area(holdings.totalArea),
                  ),
                  _total(
                    context,
                    state.passedOn
                        ? l10n.holdingsPassedArea
                        : l10n.holdingsOwnedArea,
                    format.area(holdings.ownedArea),
                  ),
                ],
              ),
              if (parent != null) ...<Widget>[
                SizedBox(height: BaseDimens.height.small),
                ParcelInfoText(l10n.parentLabel, style: text.titleMedium),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _chip(context, parent),
                ),
              ],
              if (state.children.isNotEmpty) ...<Widget>[
                SizedBox(height: BaseDimens.height.small),
                ParcelInfoText(
                  state.passedOn
                      ? l10n.childrenInheritTitle
                      : l10n.childrenTitle,
                  style: text.titleMedium,
                ),
                Wrap(
                  spacing: BaseDimens.margin.medium,
                  children: <Widget>[
                    for (final PersonEntity child in state.children)
                      _chip(context, child),
                  ],
                ),
              ],
              SizedBox(height: BaseDimens.height.small),
              if (holdings.lines.isEmpty) ParcelInfoText(l10n.holdingsEmpty),
              for (final HoldingLineReadModel line in holdings.lines)
                _line(context, line, format),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(BuildContext context, PersonEntity person) => ActionChip(
    avatar: const Icon(Icons.person_outline),
    label: ParcelInfoText(person.name),
    onPressed: () => context.push(ParcelInfoRouter.holdingsOf(person.id)),
  );

  Widget _total(BuildContext context, String label, String value) {
    final TextTheme text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(BaseDimens.padding.xxMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ParcelInfoText(label, style: text.bodyMedium),
            ParcelInfoText(value, style: text.headlineSmall),
          ],
        ),
      ),
    );
  }

  Widget _line(
    BuildContext context,
    HoldingLineReadModel line,
    ParcelInfoFormat format,
  ) {
    final l10n = ParcelInfoLocalKeys.of(context);
    final String place = <String>[
      line.official?.record.neighborhoodName ?? CoreConstants.empty,
      line.official?.label ?? CoreConstants.empty,
    ].where((String part) => part.isNotEmpty).join(_separator);
    final List<String> share = <String>[
      '${l10n.shareLabel}: ${format.share(line.share)}',
      if (line.via != null) l10n.viaAncestor(line.via!.name),
      if (line.passedOn) l10n.passedOnBadge,
    ];
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.edit_location_alt_outlined,
          color: ParcelInfoColor.drawnStroke,
        ),
        title: ParcelInfoText(line.drawing.name),
        subtitle: ParcelInfoText(
          <String>[
            if (place.isNotEmpty) place,
            '${format.area(line.area)} → ${format.area(line.ownedArea)}',
            share.join(_separator),
          ].join(CoreConstants.nextLine),
        ),
        isThreeLine: true,
        trailing: IconButton(
          tooltip: l10n.showOnMap,
          icon: const Icon(Icons.map_outlined),
          onPressed: () =>
              context.go(ParcelInfoRouter.mapFocused(line.drawing.id)),
        ),
      ),
    );
  }

  static const String _separator = ' · ';
}
