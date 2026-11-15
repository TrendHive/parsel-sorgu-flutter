import 'package:flutter/widgets.dart';

/// One editable owner line in the save dialog: the person and the text of
/// the share as typed, so a half-typed "1/" is not lost on rebuild.
class OwnerDraft {
  OwnerDraft({required this.personId, required String share})
    : share = TextEditingController(text: share);

  final String personId;

  final TextEditingController share;
}
