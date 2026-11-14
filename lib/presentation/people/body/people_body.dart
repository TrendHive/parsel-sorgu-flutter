import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/application/person/cubit/persons_cubit.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/entity/person_group_entity.dart';
import 'package:parcel_atlas/domain/person/enum/holder_kind_enum.dart';
import 'package:parcel_atlas/domain/person/read_model/holdings_read_model.dart';
import 'package:parcel_atlas/domain_ui/copy/exception_copy.dart';
import 'package:parcel_atlas/domain_ui/dialog/confirm/confirm_dialog.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_format.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/domain_ui/widgets/feedback/parcel_info_toast.dart';
import 'package:parcel_atlas/domain_ui/widgets/layout/parcel_info_readable_width.dart';
import 'package:parcel_atlas/domain_ui/widgets/text/parcel_info_text.dart';
import 'package:parcel_atlas/presentation/people/dialog/group_dialog.dart';
import 'package:parcel_atlas/presentation/people/dialog/person_dialog.dart';
import 'package:parcel_atlas/presentation/router/parcel_info_router.dart';

/// People and groups in two tabs. Each row shows how many parcels and how
/// many square metres the holder owns, and opens their holdings page; the
/// pencil edits, the bin deletes (main account only).
class PeopleBody extends StatelessWidget {
  const PeopleBody({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = ParcelInfoLocalKeys.of(context);
    return BlocConsumer<PersonsCubit, PersonsState>(
      listenWhen: (PersonsState previous, PersonsState next) =>
          next is PersonsReady &&
          (previous is! PersonsReady || previous.messageId != next.messageId),
      listener: (BuildContext context, PersonsState state) {
        if (state is! PersonsReady) return;
        if (state.exception != null) {
          ParcelInfoToast.show(
            context,
            ExceptionCopy.of(l10n, state.exception!),
            isError: true,
          );
        } else if (state.saved) {
          ParcelInfoToast.show(context, l10n.noticeSaved);
        }
      },
      builder: (BuildContext context, PersonsState state) => switch (state) {
        PersonsLoading() => const Center(child: CircularProgressIndicator()),
        PersonsFailed(:final exception) => Center(
          child: ParcelInfoText(ExceptionCopy.of(l10n, exception)),
        ),
        PersonsReady() => ParcelInfoReadableWidth(child: _tabs(context, state)),
      },
    );
  }

  Widget _tabs(BuildContext context, PersonsReady state) {
    final l10n = ParcelInfoLocalKeys.of(context);
    final PersonsCubit cubit = context.read<PersonsCubit>();
    final bool canDelete = state.member?.canDelete ?? false;
    final MapSnapshotReadModel snapshot = state.snapshot;
    return DefaultTabController(
      length: _tabCount,
      child: Column(
        children: <Widget>[
          TabBar(
            tabs: <Widget>[
              Tab(text: l10n.peopleTab),
              Tab(text: l10n.groupsTab),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: <Widget>[
                _list(
                  context,
                  empty: l10n.noPeople,
                  addLabel: l10n.addPersonButton,
                  onAdd: () async {
                    final ({String name, String note})? input =
                        await PersonDialog.open(context);
                    if (input != null) {
                      await cubit.savePerson(
                        name: input.name,
                        note: input.note,
                      );
                    }
                  },
                  tiles: <Widget>[
                    for (final PersonEntity person in snapshot.persons)
                      _tile(
                        context,
                        icon: Icons.person_outline,
                        title: person.name,
                        holdings: snapshot.holdingsOfPerson(person.id),
                        onOpen: () => context.push(
                          ParcelInfoRouter.holdingsOf(
                            HolderKindEnum.person,
                            person.id,
                          ),
                        ),
                        onEdit: () async {
                          final ({String name, String note})? input =
                              await PersonDialog.open(
                                context,
                                name: person.name,
                                note: person.note,
                              );
                          if (input != null) {
                            await cubit.savePerson(
                              name: input.name,
                              note: input.note,
                              existing: person,
                            );
                          }
                        },
                        onDelete: canDelete
                            ? () async {
                                if (await ConfirmDialog.ask(
                                  context,
                                  name: person.name,
                                )) {
                                  await cubit.deletePerson(person);
                                }
                              }
                            : null,
                      ),
                  ],
                ),
                _list(
                  context,
                  empty: l10n.noGroups,
                  addLabel: l10n.addGroupButton,
                  onAdd: () async {
                    final ({String name, List<String> memberIds, String note})?
                    input = await GroupDialog.open(
                      context,
                      persons: snapshot.persons,
                    );
                    if (input != null) {
                      await cubit.saveGroup(
                        name: input.name,
                        memberIds: input.memberIds,
                        note: input.note,
                      );
                    }
                  },
                  tiles: <Widget>[
                    for (final PersonGroupEntity group in snapshot.groups)
                      _tile(
                        context,
                        icon: Icons.groups_outlined,
                        title: group.name,
                        extra: l10n.memberCount(group.memberIds.length),
                        holdings: snapshot.holdingsOfGroup(group.id),
                        onOpen: () => context.push(
                          ParcelInfoRouter.holdingsOf(
                            HolderKindEnum.group,
                            group.id,
                          ),
                        ),
                        onEdit: () async {
                          final ({
                            String name,
                            List<String> memberIds,
                            String note,
                          })?
                          input = await GroupDialog.open(
                            context,
                            persons: snapshot.persons,
                            name: group.name,
                            memberIds: group.memberIds,
                            note: group.note,
                          );
                          if (input != null) {
                            await cubit.saveGroup(
                              name: input.name,
                              memberIds: input.memberIds,
                              note: input.note,
                              existing: group,
                            );
                          }
                        },
                        onDelete: canDelete
                            ? () async {
                                if (await ConfirmDialog.ask(
                                  context,
                                  name: group.name,
                                )) {
                                  await cubit.deleteGroup(group);
                                }
                              }
                            : null,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(
    BuildContext context, {
    required String empty,
    required String addLabel,
    required VoidCallback onAdd,
    required List<Widget> tiles,
  }) => Stack(
    children: <Widget>[
      if (tiles.isEmpty)
        Center(child: ParcelInfoText(empty, textAlign: TextAlign.center))
      else
        ListView(
          padding: const EdgeInsets.only(bottom: _fabSpace),
          children: tiles,
        ),
      Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.all(_fabMargin),
          child: FloatingActionButton.extended(
            heroTag: addLabel,
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: ParcelInfoText(addLabel),
          ),
        ),
      ),
    ],
  );

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required HoldingsReadModel holdings,
    required VoidCallback onOpen,
    required VoidCallback onEdit,
    required VoidCallback? onDelete,
    String? extra,
  }) {
    final l10n = ParcelInfoLocalKeys.of(context);
    final ParcelInfoFormat format = ParcelInfoFormat(l10n);
    return ListTile(
      leading: Icon(icon),
      title: ParcelInfoText(title),
      subtitle: ParcelInfoText(
        <String>[
          ?extra,
          l10n.parcelCount(holdings.parcelCount),
          format.area(holdings.ownedArea),
        ].join(' · '),
      ),
      onTap: onOpen,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            tooltip: l10n.edit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEdit,
          ),
          if (onDelete != null)
            IconButton(
              tooltip: l10n.delete,
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }

  static const int _tabCount = 2;
  static const double _fabSpace = 96;
  static const double _fabMargin = 16;
}
