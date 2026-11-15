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
  String get menuPeople => 'Family';

  @override
  String get menuActivity => 'History';

  @override
  String get signOut => 'Sign out';

  @override
  String get myLocation => 'My location';

  @override
  String get newDrawing => 'New drawing';

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
  String get pickOwnerTitle => 'Choose a person';

  @override
  String get peopleTitle => 'Family tree';

  @override
  String get addPersonButton => 'Add person';

  @override
  String get personDialogTitle => 'Person';

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
  String get noPeople =>
      'No people yet. Add the family, starting from the eldest ancestor.';

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

  @override
  String get pickOwnerEmpty =>
      'Nobody to add. Add people on the Family page first.';

  @override
  String childCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count children',
      one: '1 child',
    );
    return '$_temp0';
  }

  @override
  String get parentLabel => 'Parent';

  @override
  String get parentNone => 'None (top of the tree)';

  @override
  String get passesToChildrenLabel => 'Share passed to children';

  @override
  String get passesToChildrenHint =>
      'When on, this person\'s shares are split equally among their children.';

  @override
  String passedToChildren(String names, String share) {
    return '$names · $share each';
  }

  @override
  String get passedOnBadge => 'passed to children';

  @override
  String get addChildButton => 'Add child';

  @override
  String get childrenTitle => 'Children';

  @override
  String get childrenInheritTitle => 'Heirs (children)';

  @override
  String get holdingsPassedArea => 'Area left to heirs';

  @override
  String viaAncestor(String name) {
    return 'from $name';
  }

  @override
  String get errorFamilyLoop =>
      'A person cannot be the child of their own descendant.';

  @override
  String get errorRegistryRefusesWeb =>
      'The registry does not accept lookups from this website. Query new parcels from the desktop or mobile app; stored parcels show here too.';

  @override
  String get searchParcel => 'Find by block / parcel';

  @override
  String get searchTitle => 'Find a parcel';

  @override
  String get searchNeighbourhood => 'Neighbourhood';

  @override
  String get searchNeighbourhoodCode => 'Neighbourhood code';

  @override
  String get searchOther => 'Another neighbourhood (enter its code)';

  @override
  String get searchHint =>
      'The list holds the neighbourhoods of parcels already looked up. For a new neighbourhood, tap one of its parcels on the map first, or enter its code.';

  @override
  String get blockLabel => 'Block';

  @override
  String get parcelNumberLabel => 'Parcel';

  @override
  String get searchButton => 'Find';

  @override
  String get colourBy => 'Colour by family';

  @override
  String get colourOff => 'No colouring';

  @override
  String colourLevel(int level, String names) {
    return 'Generation $level: $names';
  }

  @override
  String get colourShared => 'Shared';

  @override
  String get colourUnassigned => 'No owner';

  @override
  String get assignOwner => 'Assign owner';

  @override
  String get assignOwnerTitle => 'Whose is it?';

  @override
  String get assignOwnerHint =>
      'Tap a person to choose them. Use the arrow to go down to their children; if you choose someone whose share passed on, their children show as equal holders.';

  @override
  String get showChildren => 'Go to children';

  @override
  String get treeBack => 'Up one generation';

  @override
  String get splitButton => 'Split in two';

  @override
  String get splitEqualButton => 'Split equally';

  @override
  String get splitHint =>
      'Tap two points for the cut; the line runs through both. Points snap to corners and sides.';

  @override
  String get splitMissesHint =>
      'This line does not divide the parcel. Choose the two points again.';

  @override
  String splitReady(String first, String second) {
    return 'Two pieces: $first and $second';
  }

  @override
  String get confirmSplit => 'Split and save';

  @override
  String get splitEqualTitle => 'Split equally';

  @override
  String splitEqualToChildren(String name, int count) {
    return 'To the children of $name: $count equal pieces';
  }

  @override
  String get splitEqualCount => 'Number of pieces';

  @override
  String get splitEqualByCount =>
      'Equal pieces by number (owners stay the same)';

  @override
  String get splitEqualNote =>
      'The parcel is cut into pieces of equal area along its long axis. You can adjust each piece\'s corners afterwards.';

  @override
  String get errorDrawingOverlaps =>
      'This drawing covers part of another drawing. Move the corners close to the neighbour\'s boundary; they snap onto it.';

  @override
  String get errorSplitMisses =>
      'The parcel could not be split. Check the cut line or the number of pieces.';
}
