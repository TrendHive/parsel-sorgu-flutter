import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/application/activity/cubit/activity_cubit.dart';
import 'package:parcel_atlas/domain/activity/entity/activity_entity.dart';
import 'package:parcel_atlas/domain/activity/enum/activity_action_enum.dart';
import 'package:parcel_atlas/presentation/domain_ui/copy/activity_copy.dart';
import 'package:parcel_atlas/presentation/domain_ui/copy/exception_copy.dart';
import 'package:parcel_atlas/presentation/domain_ui/dialog/confirm/confirm_dialog.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_format.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/feedback/parcel_info_toast.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/layout/parcel_info_readable_width.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';

/// One line per change: "`member` `did what`", then the record and the time.
///
/// A line that remembers its record has an undo button: after a yes it
/// undoes the whole change the line belongs to (every piece of a split,
/// say). A line written by an undo says so.
class ActivityBody extends StatelessWidget {
  const ActivityBody({super.key});

  static IconData _icon(ActivityActionEnum action) => switch (action) {
    ActivityActionEnum.queried => Icons.travel_explore,
    ActivityActionEnum.refreshed => Icons.sync,
    ActivityActionEnum.created => Icons.add_circle_outline,
    ActivityActionEnum.updated => Icons.edit_outlined,
    ActivityActionEnum.deleted => Icons.delete_outline,
  };

  static const String _separator = ' · ';

  @override
  Widget build(BuildContext context) {
    final l10n = ParcelInfoLocalKeys.of(context);
    final ParcelInfoFormat format = ParcelInfoFormat(l10n);
    return BlocConsumer<ActivityCubit, ActivityState>(
      listenWhen: (ActivityState previous, ActivityState next) =>
          next is ActivityReady &&
          (previous is! ActivityReady || previous.messageId != next.messageId),
      listener: (BuildContext context, ActivityState state) {
        if (state is! ActivityReady) return;
        if (state.exception != null) {
          ParcelInfoToast.show(
            context,
            ExceptionCopy.of(l10n, state.exception!),
            isError: true,
          );
        } else if (state.undone) {
          ParcelInfoToast.show(context, l10n.noticeUndone);
        }
      },
      builder: (BuildContext context, ActivityState state) => switch (state) {
        ActivityLoading() => const Center(child: CircularProgressIndicator()),
        ActivityFailed(:final exception) => Center(
          child: ParcelInfoText(ExceptionCopy.of(l10n, exception)),
        ),
        ActivityReady(:final List<ActivityEntity> entries) =>
          entries.isEmpty
              ? Center(child: ParcelInfoText(l10n.activityEmpty))
              : ParcelInfoReadableWidth(
                  child: ListView.separated(
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (BuildContext context, int index) {
                      final ActivityEntity entry = entries[index];
                      return ListTile(
                        leading: Icon(_icon(entry.action)),
                        title: ParcelInfoText(
                          '${entry.stamp.memberName} ${ActivityCopy.action(l10n, entry.action)}',
                        ),
                        subtitle: ParcelInfoText(
                          '${ActivityCopy.target(l10n, entry.target)}: ${entry.label}\n'
                          '${format.date(entry.stamp.at)}'
                          '${entry.isUndo ? '$_separator${l10n.undoBadge}' : ''}',
                        ),
                        isThreeLine: true,
                        trailing: entry.changeId == null
                            ? null
                            : IconButton(
                                tooltip: l10n.undoButton,
                                icon: const Icon(Icons.undo),
                                onPressed: () async {
                                  final ActivityCubit cubit = context
                                      .read<ActivityCubit>();
                                  if (await ConfirmDialog.askUndo(
                                    context,
                                    label: entry.label,
                                  )) {
                                    await cubit.undo(entry.changeId!);
                                  }
                                },
                              ),
                      );
                    },
                  ),
                ),
      },
    );
  }
}
