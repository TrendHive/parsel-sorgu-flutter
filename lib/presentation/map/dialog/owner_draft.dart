import 'package:flutter/widgets.dart';
import 'package:parcel_atlas/domain/person/enum/holder_kind_enum.dart';

/// One editable owner line in the save dialog: the holder and the text of
/// the share as typed, so a half-typed "1/" is not lost on rebuild.
class OwnerDraft {
  OwnerDraft({
    required this.kind,
    required this.holderId,
    required String share,
  }) : share = TextEditingController(text: share);

  final HolderKindEnum kind;

  final String holderId;

  final TextEditingController share;
}
