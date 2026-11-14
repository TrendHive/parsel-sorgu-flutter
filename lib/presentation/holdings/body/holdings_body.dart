import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/application/person/cubit/holdings_cubit.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/entity/person_group_entity.dart';
import 'package:parcel_atlas/domain/person/enum/holder_kind_enum.dart';
import 'package:parcel_atlas/domain/person/read_model/holding_line_read_model.dart';
import 'package:parcel_atlas/domain/person/read_model/holdings_read_model.dart';
import 'package:parcel_atlas/domain_ui/copy/exception_copy.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_color.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_format.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/domain_ui/widgets/layout/parcel_info_readable_width.dart';
import 'package:parcel_atlas/domain_ui/widgets/text/parcel_info_text.dart';
import 'package:parcel_atlas/presentation/router/parcel_info_router.dart';

/// Totals first — parcels, total area, owned area — then one card per parcel
/// with where it is, its area, the share and what that share stands for, and
/// "show on map". A group lists its members; a person their groups, and each
/// parcel says when it comes through a group.
class HoldingsBody extends StatelessWidget {
  const HoldingsBody({super.key, required this.kind});

  final HolderKindEnum kind;

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
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar.large(title: ParcelInfoText(state.title)),
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
                    l10n.holdingsOwnedArea,
                    format.area(holdings.ownedArea),
                  ),
                ],
              ),
              if (state.members.isNotEmpty) ...<Widget>[
                SizedBox(height: BaseDimens.height.small),
                ParcelInfoText(l10n.groupMembersTitle, style: text.titleMedium),
                Wrap(
                  spacing: BaseDimens.margin.medium,
                  children: <Widget>[
                    for (final PersonEntity person in state.members)
                      ActionChip(
                        avatar: const Icon(Icons.person_outline),
                        label: ParcelInfoText(person.name),
                        onPressed: () => context.push(
                          ParcelInfoRouter.holdingsOf(
                            HolderKindEnum.person,
                            person.id,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              if (state.groups.isNotEmpty) ...<Widget>[
                SizedBox(height: BaseDimens.height.small),
                ParcelInfoText(l10n.memberOfGroups, style: text.titleMedium),
                Wrap(
                  spacing: BaseDimens.margin.medium,
                  children: <Widget>[
                    for (final PersonGroupEntity group in state.groups)
                      ActionChip(
                        avatar: const Icon(Icons.groups_outlined),
                        label: ParcelInfoText(group.name),
                        onPressed: () => context.push(
                          ParcelInfoRouter.holdingsOf(
                            HolderKindEnum.group,
                            group.id,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              SizedBox(height: BaseDimens.height.small),
              if (holdings.lines.isEmpty) ParcelInfoText(l10n.holdingsEmpty),
              for (final HoldingLineReadModel line in holdings.lines)
                _line(context, line, format, state.members.length),
            ],
          ),
        ),
      ],
    );
  }

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
    int memberCount,
  ) {
    final l10n = ParcelInfoLocalKeys.of(context);
    final String place = <String>[
      line.official?.record.neighborhoodName ?? CoreConstants.empty,
      line.official?.label ?? CoreConstants.empty,
    ].where((String part) => part.isNotEmpty).join(' · ');
    final List<String> share = <String>[
      '${l10n.shareLabel}: ${format.share(line.share)}',
      if (line.viaGroup != null) l10n.viaGroup(line.viaGroup!.name),
      if (kind == HolderKindEnum.group && memberCount > CoreConstants.zero)
        l10n.perMemberShare(format.share(line.share.dividedBy(memberCount))),
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
            share.join(' · '),
          ].join('\n'),
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
}
