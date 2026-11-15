import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/application/person/cubit/persons_cubit.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/read_model/holdings_read_model.dart';
import 'package:parcel_atlas/domain/person/rule/family_rules.dart';
import 'package:parcel_atlas/domain_ui/copy/exception_copy.dart';
import 'package:parcel_atlas/domain_ui/dialog/confirm/confirm_dialog.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_dimens.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_format.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/domain_ui/widgets/feedback/parcel_info_toast.dart';
import 'package:parcel_atlas/domain_ui/widgets/layout/parcel_info_readable_width.dart';
import 'package:parcel_atlas/domain_ui/widgets/text/parcel_info_text.dart';
import 'package:parcel_atlas/presentation/people/dialog/person_dialog.dart';
import 'package:parcel_atlas/presentation/router/parcel_info_router.dart';

/// The family tree: each person under their parent, indented by generation.
///
/// A row shows how many parcels and how many square metres reach the person,
/// and opens their holdings page; the pencil edits, the "+" adds a child
/// under them, the bin deletes (main account only).
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
        PersonsReady() => ParcelInfoReadableWidth(child: _tree(context, state)),
      },
    );
  }

  Widget _tree(BuildContext context, PersonsReady state) {
    final l10n = ParcelInfoLocalKeys.of(context);
    final MapSnapshotReadModel snapshot = state.snapshot;
    final Set<String> ids = <String>{
      for (final PersonEntity p in snapshot.persons) p.id,
    };
    final List<PersonEntity> roots = snapshot.persons
        .where((PersonEntity p) => !ids.contains(p.parentId))
        .toList();
    return Stack(
      children: <Widget>[
        if (snapshot.persons.isEmpty)
          Center(
            child: ParcelInfoText(l10n.noPeople, textAlign: TextAlign.center),
          )
        else
          ListView(
            padding: const EdgeInsets.only(bottom: _fabSpace),
            children: <Widget>[
              for (final PersonEntity root in roots)
                ..._branch(context, state, root, CoreConstants.zero),
            ],
          ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(_fabMargin),
            child: FloatingActionButton.extended(
              onPressed: () => _edit(context, state),
              icon: const Icon(Icons.person_add_alt),
              label: ParcelInfoText(l10n.addPersonButton),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _branch(
    BuildContext context,
    PersonsReady state,
    PersonEntity person,
    int depth,
  ) => <Widget>[
    _tile(context, state, person, depth),
    if (depth < FamilyRules.maxGenerations)
      for (final PersonEntity child in state.snapshot.childrenOf(person.id))
        ..._branch(context, state, child, depth + CoreConstants.one),
  ];

  Widget _tile(
    BuildContext context,
    PersonsReady state,
    PersonEntity person,
    int depth,
  ) {
    final l10n = ParcelInfoLocalKeys.of(context);
    final ParcelInfoFormat format = ParcelInfoFormat(l10n);
    final PersonsCubit cubit = context.read<PersonsCubit>();
    final HoldingsReadModel holdings = state.snapshot.holdingsOfPerson(
      person.id,
    );
    final bool passes = FamilyRules.passes(state.snapshot.persons, person);
    return ListTile(
      contentPadding: EdgeInsets.only(
        left: ParcelInfoDimens.treeIndent * depth + _fabMargin,
        right: _fabMargin,
      ),
      leading: Icon(
        passes ? Icons.account_tree_outlined : Icons.person_outline,
      ),
      title: ParcelInfoText(person.name),
      subtitle: ParcelInfoText(
        <String>[
          l10n.parcelCount(holdings.parcelCount),
          format.area(holdings.ownedArea),
          if (passes) l10n.passedOnBadge,
        ].join(_separator),
      ),
      onTap: () => context.push(ParcelInfoRouter.holdingsOf(person.id)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            tooltip: l10n.addChildButton,
            icon: const Icon(Icons.add),
            onPressed: () => _edit(context, state, parentId: person.id),
          ),
          IconButton(
            tooltip: l10n.edit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _edit(context, state, existing: person),
          ),
          if (state.member?.canDelete ?? false)
            IconButton(
              tooltip: l10n.delete,
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                if (await ConfirmDialog.ask(context, name: person.name)) {
                  await cubit.deletePerson(person);
                }
              },
            ),
        ],
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    PersonsReady state, {
    PersonEntity? existing,
    String? parentId,
  }) async {
    final PersonsCubit cubit = context.read<PersonsCubit>();
    final List<PersonEntity> persons = state.snapshot.persons;
    final ({String name, String? parentId, bool passesToChildren, String note})?
    input = await PersonDialog.open(
      context,
      parents: existing == null
          ? persons
          : persons
                .where(
                  (PersonEntity p) => FamilyRules.canBeParent(
                    persons,
                    childId: existing.id,
                    parentId: p.id,
                  ),
                )
                .toList(),
      name: existing?.name ?? CoreConstants.empty,
      parentId: existing?.parentId ?? parentId,
      passesToChildren: existing?.passesToChildren ?? false,
      note: existing?.note ?? CoreConstants.empty,
    );
    if (input == null) return;
    await cubit.savePerson(
      name: input.name,
      parentId: input.parentId,
      passesToChildren: input.passesToChildren,
      note: input.note,
      existing: existing,
    );
  }

  static const String _separator = ' · ';
  static const double _fabSpace = 96;
  static const double _fabMargin = 16;
}
