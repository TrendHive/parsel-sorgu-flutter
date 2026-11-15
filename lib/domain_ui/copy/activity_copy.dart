import 'package:parcel_atlas/domain/activity/enum/activity_action_enum.dart';
import 'package:parcel_atlas/domain/activity/enum/activity_target_enum.dart';
import 'package:parcel_atlas/domain_ui/values/l10n/app_localizations.dart';

/// Words for an activity line: what was done and to what kind of record.
class ActivityCopy {
  ActivityCopy._();

  static String action(AppLocalizations l10n, ActivityActionEnum action) =>
      switch (action) {
        ActivityActionEnum.queried => l10n.actionQueried,
        ActivityActionEnum.refreshed => l10n.actionRefreshed,
        ActivityActionEnum.created => l10n.actionCreated,
        ActivityActionEnum.updated => l10n.actionUpdated,
        ActivityActionEnum.deleted => l10n.actionDeleted,
      };

  static String target(AppLocalizations l10n, ActivityTargetEnum target) =>
      switch (target) {
        ActivityTargetEnum.officialParcel => l10n.targetOfficial,
        ActivityTargetEnum.drawnParcel => l10n.targetDrawn,
        ActivityTargetEnum.person => l10n.targetPerson,
      };
}
