// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Parcel Atlas';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Try again';

  @override
  String get confirmDeleteTitle => 'Delete?';

  @override
  String confirmDeleteBody(String name) {
    return '$name will be deleted permanently. This cannot be undone.';
  }

  @override
  String get signInTitle => 'Sign in';

  @override
  String get signInSubtitle =>
      'Sign in with the username and password you were given.';

  @override
  String get usernameLabel => 'Username';

  @override
  String get passwordLabel => 'Password';

  @override
  String get signInButton => 'Sign in';

  @override
  String get layerOfficial => 'Official parcels';

  @override
  String get layerDrawn => 'Real boundaries';

  @override
  String get baseSatellite => 'Satellite';

  @override
  String get baseStreet => 'Map';

  @override
  String get menuPeople => 'People';

  @override
  String get menuActivity => 'History';

  @override
  String get signOut => 'Sign out';

  @override
  String get myLocation => 'My location';

  @override
  String get newDrawing => 'New drawing';

  @override
  String get noParcelStoredTitle => 'No stored parcel here';

  @override
  String get noParcelStoredBody =>
      'Querying the official registry uses one of today\'s few lookups.';

  @override
  String get queryRegistryButton => 'Query the official registry';

  @override
  String get querying => 'Querying…';

  @override
  String officialParcelTitle(String block, String parcel) {
    return 'Block $block · Parcel $parcel';
  }

  @override
  String get officialBadge => 'Official record';

  @override
  String get drawnBadge => 'Real boundary';

  @override
  String get cityLabel => 'Province';

  @override
  String get districtLabel => 'District';

  @override
  String get neighborhoodLabel => 'Neighbourhood / village';

  @override
  String get localityLabel => 'Locality';

  @override
  String get qualityLabel => 'Use';

  @override
  String get sheetLabel => 'Map sheet';

  @override
  String get landStatusLabel => 'Land status';

  @override
  String get registryAreaLabel => 'Deed area';

  @override
  String get inactiveParcel =>
      'The registry lists this parcel as inactive (historical).';

  @override
  String get refreshButton => 'Refresh from the registry';

  @override
  String get drawRealButton => 'Draw the real boundary';

  @override
  String get officialReadOnlyNote =>
      'Official information cannot be edited; it is only refreshed from the registry.';

  @override
  String queriedBy(String name, String date) {
    return 'First queried by $name · $date';
  }

  @override
  String refreshedBy(String name, String date) {
    return 'Last refreshed by $name · $date';
  }

  @override
  String get correctionsTitle => 'Real boundaries of this parcel';

  @override
  String get measuredAreaLabel => 'Measured area';

  @override
  String get perimeterLabel => 'Perimeter';

  @override
  String get edgesLabel => 'Side lengths';

  @override
  String get linkedOfficialLabel => 'Official parcel it corrects';

  @override
  String areaDifference(String difference, String percent) {
    return 'Difference from the deed: $difference ($percent)';
  }

  @override
  String get ownersTitle => 'Owners';

  @override
  String get noOwners => 'No owners yet.';

  @override
  String sharesTotal(String total) {
    return 'Total share: $total';
  }

  @override
  String get sharesIncomplete =>
      'Shares do not add up to 1 — some owners may be missing.';

  @override
  String get editShape => 'Edit shape';

  @override
  String get editDetails => 'Edit details';

  @override
  String createdBy(String name, String date) {
    return 'Created by $name · $date';
  }

  @override
  String updatedBy(String name, String date) {
    return 'Last changed by $name · $date';
  }

  @override
  String get noteLabel => 'Note';

  @override
  String viaGroup(String group) {
    return 'via $group';
  }

  @override
  String get drawingHint =>
      'Tap the map to add a corner. Drag corners to move them; use + on an edge to insert one.';

  @override
  String get crosshairHint =>
      'Move the map until the crosshair is on the spot, then add a corner.';

  @override
  String drawingCorners(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count corners',
      one: '1 corner',
      zero: 'No corners',
    );
    return '$_temp0';
  }

  @override
  String get undo => 'Undo';

  @override
  String get redo => 'Redo';

  @override
  String get deleteCorner => 'Delete corner';

  @override
  String get crosshairMode => 'Crosshair';

  @override
  String get addCornerHere => 'Add corner here';

  @override
  String get finishDrawing => 'Finish';

  @override
  String get cancelDrawing => 'Discard drawing';

  @override
  String get saveDrawingTitle => 'Save drawing';

  @override
  String get nameLabel => 'Name';

  @override
  String drawingNameDefault(String label) {
    return '$label real boundary';
  }

  @override
  String get addOwner => 'Add owner';

  @override
  String get shareLabel => 'Share';

  @override
  String get shareHint => 'e.g. 1/4';

  @override
  String get invalidShare => 'Enter a valid share (e.g. 1/4).';

  @override
  String get pickOwnerTitle => 'Choose a person or group';

  @override
  String get peopleTitle => 'People and groups';

  @override
  String get peopleTab => 'People';

  @override
  String get groupsTab => 'Groups';

  @override
  String get addPersonButton => 'Add person';

  @override
  String get addGroupButton => 'Add group';

  @override
  String get personDialogTitle => 'Person';

  @override
  String get groupDialogTitle => 'Group';

  @override
  String get groupMembersLabel => 'Members';

  @override
  String parcelCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parcels',
      one: '1 parcel',
      zero: 'No parcels',
    );
    return '$_temp0';
  }

  @override
  String memberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
      zero: 'No members',
    );
    return '$_temp0';
  }

  @override
  String get noPeople => 'No people yet. Add parcel owners here.';

  @override
  String get noGroups =>
      'No groups yet. Group people who share the same places.';

  @override
  String get holdingsParcels => 'Parcels';

  @override
  String get holdingsTotalArea => 'Total parcel area';

  @override
  String get holdingsOwnedArea => 'Owned area';

  @override
  String get showOnMap => 'Show on map';

  @override
  String get holdingsEmpty => 'No parcels assigned.';

  @override
  String get groupMembersTitle => 'Group members';

  @override
  String get memberOfGroups => 'Member of';

  @override
  String perMemberShare(String share) {
    return '$share each';
  }

  @override
  String get activityTitle => 'Change history';

  @override
  String get activityEmpty => 'No changes yet.';

  @override
  String get actionQueried => 'queried from the registry';

  @override
  String get actionRefreshed => 'refreshed from the registry';

  @override
  String get actionCreated => 'created';

  @override
  String get actionUpdated => 'changed';

  @override
  String get actionDeleted => 'deleted';

  @override
  String get targetOfficial => 'Official parcel';

  @override
  String get targetDrawn => 'Real boundary';

  @override
  String get targetPerson => 'Person';

  @override
  String get targetGroup => 'Group';

  @override
  String get noticeFromStore =>
      'This parcel is already stored — no lookup was spent.';

  @override
  String get noticeQueried => 'Parcel fetched from the registry and saved.';

  @override
  String get noticeRefreshed => 'Parcel refreshed from the registry.';

  @override
  String get noticeDrawingSaved => 'Drawing saved.';

  @override
  String get noticeDrawingDeleted => 'Drawing deleted.';

  @override
  String get noticeSaved => 'Saved.';

  @override
  String get errorUnknown => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork =>
      'No internet connection, or the server is not answering.';

  @override
  String get errorBadResponse => 'The registry gave an unexpected answer.';

  @override
  String get errorQuota =>
      'The registry\'s daily lookup limit is reached. Stored parcels keep working; new lookups can be made tomorrow.';

  @override
  String get errorNoParcel => 'The registry has no parcel at this point.';

  @override
  String get errorInvalidCredentials => 'Wrong username or password.';

  @override
  String get errorNotMember => 'This account is not on the family\'s list.';

  @override
  String get errorAdminOnly => 'Only the main account can do this.';

  @override
  String get errorNotSignedIn => 'Please sign in first.';

  @override
  String get errorTooFewCorners => 'An area needs at least 3 corners.';

  @override
  String get errorRecordMissing => 'This record was deleted on another device.';

  @override
  String get errorSharesExceed =>
      'Each share must be between 0 and 1, and together they may not exceed 1.';

  @override
  String get errorEmptyField => 'This field cannot be empty.';

  @override
  String squareMeters(String value) {
    return '$value m²';
  }

  @override
  String meters(String value) {
    return '$value m';
  }
}
